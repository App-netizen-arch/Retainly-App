import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/local_ai_repository.dart';
import '../../services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.conversationId});

  final int? conversationId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final LocalAiRepository _repository = LocalAiRepository();
  final TextEditingController _composer = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int? _conversationId;
  List<Map<String, Object?>> _messages = [];
  bool _loading = false;
  bool _initialized = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _composer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      final requestedId = widget.conversationId;
      int conversationId;
      if (requestedId == null ||
          await _repository.getConversation(requestedId) == null) {
        conversationId = await _repository.createConversation();
      } else {
        conversationId = requestedId;
      }
      if (!mounted) return;
      setState(() {
        _conversationId = conversationId;
        _initialized = true;
      });
      await _loadMessages();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Could not open local chat history. Please restart Retainly.';
        _initialized = true;
      });
    }
  }

  Future<void> _loadMessages() async {
    final id = _conversationId;
    if (id == null) return;
    final rows = await _repository.getMessages(id);
    if (!mounted) return;
    setState(() => _messages = rows);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage() async {
    final question = _composer.text.trim();
    final conversationId = _conversationId;
    if (question.isEmpty || _loading || conversationId == null) return;

    _composer.clear();
    setState(() => _loading = true);
    try {
      await _repository.addMessage(
        conversationId: conversationId,
        role: 'user',
        content: question,
      );
      await _loadMessages();

      final previousRows = _messages
          .where((row) => row['role'] == 'user' || row['role'] == 'assistant')
          .toList();
      if (previousRows.isNotEmpty &&
          previousRows.last['role'] == 'user' &&
          previousRows.last['content'] == question) {
        previousRows.removeLast();
      }
      final history = previousRows
          .skip(previousRows.length > 12 ? previousRows.length - 12 : 0)
          .map((row) => <String, String>{
                'role': row['role'] as String,
                'content': row['content'] as String,
              })
          .toList();

      final memoryRows = await _repository.retrieveRelevantMemories(question);
      final memoryContext = memoryRows
          .map((row) => '[${row['category']}] ${row['content']}')
          .join('\n');
      final bookContext = await _repository.buildTextbookContext(question);

      final answer = await AIService().askAiAboutSubject(
        'local_user',
        question,
        conversationHistory: history,
        relevantMemoryContext: memoryContext,
        retrievedBookContext: bookContext,
      );
      final displayAnswer = _friendlyAnswer(answer);
      await _repository.addMessage(
        conversationId: conversationId,
        role: 'assistant',
        content: displayAnswer,
      );
      await _loadMessages();
    } catch (_) {
      await _repository.addMessage(
        conversationId: conversationId,
        role: 'assistant',
        content: 'I could not complete this request. Your message is still saved on this device. Check your Groq key, online-AI consent and internet connection, then try again.',
      );
      await _loadMessages();
    } finally {
      if (mounted) setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  String _friendlyAnswer(String? answer) {
    if (answer == null || answer.trim().isEmpty) {
      return 'No response was received. Check your connection and Groq account settings.';
    }
    if (answer.startsWith('AI_ERROR:')) {
      return answer.substring('AI_ERROR:'.length).trim();
    }
    return answer;
  }

  Future<void> _startNewChat() async {
    final id = await _repository.createConversation();
    if (!mounted) return;
    setState(() {
      _conversationId = id;
      _messages = [];
      _loadError = null;
    });
  }

  Future<void> _showHistory() async {
    final conversations = await _repository.getConversations();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * 0.68,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Your chats', style: Theme.of(sheetContext).textTheme.titleLarge),
                    ),
                    IconButton(
                      tooltip: 'Start new chat',
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _startNewChat();
                      },
                      icon: const Icon(Icons.add_comment_outlined),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: conversations.isEmpty
                    ? const Center(child: Text('Your saved conversations will appear here.'))
                    : ListView.builder(
                        itemCount: conversations.length,
                        itemBuilder: (context, index) {
                          final row = conversations[index];
                          final id = row['id'] as int;
                          return ListTile(
                            leading: const Icon(Icons.chat_bubble_outline),
                            title: Text(row['title'] as String? ?? 'New chat', maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(row['updated_at'] as String? ?? '', maxLines: 1),
                            onTap: () async {
                              Navigator.pop(sheetContext);
                              if (!mounted) return;
                              setState(() {
                                _conversationId = id;
                                _messages = [];
                              });
                              await _loadMessages();
                            },
                            trailing: IconButton(
                              tooltip: 'Delete conversation',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                await _repository.deleteConversation(id);
                                if (mounted) Navigator.pop(sheetContext);
                                if (_conversationId == id) {
                                  await _startNewChat();
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveMemory(String content) async {
    final controller = TextEditingController(text: content);
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Save to local memory?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This will be stored only in Retainly on this device. You can inspect, edit or delete it in Memory settings.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Memory'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Save memory')),
        ],
      ),
    );
    final value = controller.text.trim();
    controller.dispose();
    if (approved != true || value.isEmpty) return;
    await _repository.saveMemory(
      content: value,
      category: 'learning note',
      sourceConversationId: _conversationId,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to local memory.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Retainly AI'),
            Text('Groq-powered • Local chat history', style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Textbook library',
            onPressed: () => context.push('/books'),
            icon: const Icon(Icons.menu_book_outlined),
          ),
          IconButton(
            tooltip: 'Local memory',
            onPressed: () => context.push('/ai/memory'),
            icon: const Icon(Icons.psychology_alt_outlined),
          ),
          IconButton(
            tooltip: 'Chat history',
            onPressed: _showHistory,
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: 'New chat',
            onPressed: _startNewChat,
            icon: const Icon(Icons.add_comment_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: !_initialized
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_loadError!)))
              : Column(
                  children: [
                    Expanded(
                      child: _messages.isEmpty
                          ? _WelcomePanel(onPrompt: (prompt) {
                              _composer.text = prompt;
                              _sendMessage();
                            })
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(14, 16, 14, 20),
                              itemCount: _messages.length + (_loading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _messages.length) {
                                  return const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                                    ),
                                  );
                                }
                                final row = _messages[index];
                                final isUser = row['role'] == 'user';
                                final text = row['content'] as String? ?? '';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 18),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                                    children: [
                                      if (!isUser) Padding(
                                        padding: const EdgeInsets.only(right: 8, top: 2),
                                        child: CircleAvatar(
                                          radius: 17,
                                          backgroundColor: colors.primaryContainer,
                                          child: Icon(Icons.auto_awesome, size: 18, color: colors.onPrimaryContainer),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          constraints: const BoxConstraints(maxWidth: 760),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: isUser ? colors.primaryContainer : colors.surfaceContainerHighest.withValues(alpha: 0.6),
                                            borderRadius: BorderRadius.circular(18),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              if (isUser)
                                                SelectableText(text)
                                              else
                                                MarkdownBody(
                                                  data: text,
                                                  selectable: true,
                                                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
                                                ),
                                              if (!isUser)
                                                Align(
                                                  alignment: Alignment.centerRight,
                                                  child: TextButton.icon(
                                                    onPressed: () => _saveMemory(text),
                                                    icon: const Icon(Icons.bookmark_add_outlined, size: 17),
                                                    label: const Text('Remember'),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Online AI sends your question and relevant context to Groq. Chat history and saved memories stay on this device.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _composer,
                                    minLines: 1,
                                    maxLines: 6,
                                    textCapitalization: TextCapitalization.sentences,
                                    decoration: const InputDecoration(
                                      hintText: 'Ask about a topic or your textbooks…',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    onSubmitted: (_) => _sendMessage(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filled(
                                  tooltip: 'Send message',
                                  onPressed: _loading ? null : _sendMessage,
                                  icon: const Icon(Icons.arrow_upward),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({required this.onPrompt});

  final ValueChanged<String> onPrompt;

  static const prompts = [
    'Explain this topic in simple Urdu and English.',
    'Create five practice questions from my current chapter.',
    'What should I revise first today?',
    'Explain a textbook passage and show the source page.',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, size: 42, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 14),
              Text('What are we learning today?', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('Your conversations are saved locally. Add memories explicitly, and import a textbook to make its pages searchable.', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              for (final prompt in prompts)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: () => onPrompt(prompt),
                    style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft, padding: const EdgeInsets.all(14)),
                    child: Text(prompt),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
