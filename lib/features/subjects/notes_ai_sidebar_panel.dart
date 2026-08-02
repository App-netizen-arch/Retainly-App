import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/database_provider.dart';
import '../../services/ai_service.dart';

class NotesAiSidebarPanel extends ConsumerStatefulWidget {
  const NotesAiSidebarPanel({super.key});

  @override
  ConsumerState<NotesAiSidebarPanel> createState() =>
      _NotesAiSidebarPanelState();
}

class _NotesAiSidebarPanelState extends ConsumerState<NotesAiSidebarPanel> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _loading = false;

  static const _presets = [
    _AiPreset(
      label: 'Summarize all notes',
      prompt: 'Summarize all my notes. List the key topics and concepts covered.',
    ),
    _AiPreset(
      label: 'What needs revision',
      prompt: 'Based on my notes and subjects, which topics should I revise first?',
    ),
    _AiPreset(
      label: 'Create study plan',
      prompt: 'Create a short study plan for my notes and subjects for the next 3 days.',
    ),
    _AiPreset(
      label: 'Quiz me from notes',
      prompt: 'Generate 5 quiz questions from my notes and subjects. Include answers.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(const _ChatMessage(
      text: 'I can read your notes and help you study. Ask me to summarize, quiz you, or build a plan.',
      fromUser: false,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String?> _buildNotesContext() async {
    try {
      final db = await ref.read(databaseRepositoryProvider.future);
      final notes = await db.getAllResources();
      final customNotes = notes.where((n) => n.folder == 'Custom Notes').toList();
      final subjects = await db.getSubjects();
      final allChapters = await db.getAllChapters();

      final buffer = StringBuffer();
      buffer.writeln('User notes and resources:');
      if (customNotes.isEmpty) {
        buffer.writeln('  No custom notes imported.');
      } else {
        for (final note in customNotes) {
          buffer.writeln('  - ${note.title} (${note.type})');
        }
      }
      buffer.writeln('Subjects and chapters:');
      if (subjects.isEmpty) {
        buffer.writeln('  No subjects added yet.');
      } else {
        for (final subject in subjects) {
          buffer.writeln('Subject: ${subject.name}');
          final subjectChapters = allChapters
              .where((c) => c.subjectId == subject.id)
              .toList();
          if (subjectChapters.isEmpty) {
            buffer.writeln('  Chapters: none yet');
          } else {
            buffer.writeln(
              '  Chapters: ${subjectChapters.map((c) => c.title).join(', ')}',
            );
          }
        }
      }
      return buffer.toString();
    } on Exception catch (_) {
      return 'No notes or subject information available.';
    }
  }

  Future<void> _sendMessage({String? presetPrompt}) async {
    final question = presetPrompt ?? _controller.text.trim();
    if (question.isEmpty || _loading) return;

    final service = AIService();
    final consented = await service.hasAiConsent();
    final accepted = await service.hasAcceptedAiPolicy();
    if (!consented || !accepted) {
      if (!mounted) return;
      final proceed = await showDialog<bool>(
        context: context,
        builder:
            (dctx) => AlertDialog(
              title: const Text('AI Assistant Policy'),
              content: const SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'This AI study assistant uses online AI services to answer questions, generate quizzes, and create flashcards.',
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Key points:\n'
                      '• AI content is a draft only — you must review before adding to your study plan.\n'
                      '• Responses are based on your uploaded subjects and chapters.\n'
                      '• We do not store personal data in AI requests.\n'
                      '• AI may occasionally make mistakes; always verify with your textbook.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dctx, false),
                  child: const Text('Decline'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await service.acceptAiPolicy();
                    await service.setAiConsent(true);
                    await service.acceptCostWarning();
                    if (mounted) {
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: const Text('Accept & Continue'),
                ),
              ],
            ),
      );
      if (proceed != true) {
        setState(() {
          _loading = false;
        });
        return;
      }
    }

    setState(() {
      _messages.add(_ChatMessage(text: question, fromUser: true));
      _loading = true;
    });
    _controller.clear();

    final notesContext = await _buildNotesContext();
    final answer = await service.askAiAboutSubject(
      'local_user',
      question,
      subjectContext: notesContext,
    );

    setState(() {
      _loading = false;
      _messages.add(
        _ChatMessage(
          text: answer ?? 'No response received.',
          fromUser: false,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI Notes Assistant',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final preset in _presets)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            label: Text(preset.label),
                            onPressed: _loading
                                ? null
                                : () => _sendMessage(presetPrompt: preset.prompt),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                final msg = _messages[index];
                final isUser = msg.fromUser;
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.65,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: isUser ? Colors.white : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask about your notes...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _loading ? null : _sendMessage,
                    icon: const Icon(Icons.send),
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

class _ChatMessage {
  final String text;
  final bool fromUser;
  const _ChatMessage({required this.text, required this.fromUser});
}

class _AiPreset {
  final String label;
  final String prompt;
  const _AiPreset({required this.label, required this.prompt});
}
