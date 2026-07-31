import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/database_provider.dart';
import '../../services/ai_service.dart';

class AiSidebarPanel extends ConsumerStatefulWidget {
  const AiSidebarPanel({super.key});

  @override
  ConsumerState<AiSidebarPanel> createState() => _AiSidebarPanelState();
}

class _AiSidebarPanelState extends ConsumerState<AiSidebarPanel> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _loading = false;

  static const _presets = [
    _AiPreset(
      label: 'Explain this topic',
      prompt: 'Explain the topic in simple English and simple Urdu/roman Urdu. Keep it concise and aligned with Matric syllabus.',
    ),
    _AiPreset(
      label: 'Break into sub-tasks',
      prompt: 'Break the current chapter into 3-5 actionable sub-tasks with estimated minutes each. Format as a minimum viable study plan.',
    ),
    _AiPreset(
      label: 'Quiz me',
      prompt: 'Generate 5 multiple-choice questions from my subjects and chapters. Include answers and brief explanations.',
    ),
    _AiPreset(
      label: 'Flashcards',
      prompt: 'Create 5 flashcards from my subjects and chapters. Format: Question / Answer.',
    ),
    _AiPreset(
      label: 'Study plan',
      prompt: 'Create a 3-day study schedule for my subjects and chapters. Respect realistic daily study hours.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(const _ChatMessage(
      text: 'Ask me anything about your subjects. I can help explain concepts, suggest study plans, or quiz you.',
      fromUser: false,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String?> _buildSubjectContext() async {
    try {
      final db = await ref.read(databaseRepositoryProvider.future);
      final subjects = await db.getSubjects();
      final allChapters = await db.getAllChapters();
      if (subjects.isEmpty) return 'No subjects added yet.';

      final buffer = StringBuffer();
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
          final weakChapters = subjectChapters
              .where((c) => c.isWeakTopic)
              .toList();
          if (weakChapters.isNotEmpty) {
            buffer.writeln(
              '  Weak topics: ${weakChapters.map((c) => c.title).join(', ')}',
            );
          }
        }
      }
      return buffer.toString();
    } catch (_) {
      return 'No subject information available.';
    }
  }

  Future<void> _sendMessage() async {
    final question = _controller.text.trim();
    if (question.isEmpty || _loading) return;
    setState(() {
      _messages.add(_ChatMessage(text: question, fromUser: true));
      _loading = true;
    });
    _controller.clear();

    final service = AIService();
    final consent = await service.hasAiConsent();
    if (!consent) {
      setState(() {
        _loading = false;
        _messages.add(const _ChatMessage(
          text: 'AI assistance requires consent. Please enable it in Settings first.',
          fromUser: false,
        ));
      });
      return;
    }
    final accepted = await service.hasAcceptedCostWarning();
    if (!accepted) {
      setState(() {
        _loading = false;
        _messages.add(const _ChatMessage(
          text: 'Please accept the AI cost warning in Settings before using AI features.',
          fromUser: false,
        ));
      });
      return;
    }

    final subjectContext = await _buildSubjectContext();
    final answer = await service.askAiAboutSubject(
      'local_user',
      question,
      subjectContext: subjectContext,
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
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'AI Study Assistant',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Text(
                  'Ask questions about your subjects',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
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
                                : () async {
                                    final question = preset.prompt;
                                    setState(() {
                                      _messages.add(_ChatMessage(
                                        text: question,
                                        fromUser: true,
                                      ));
                                      _loading = true;
                                    });
                                    final service = AIService();
                                    final consent = await service.hasAiConsent();
                                    final accepted = await service
                                        .hasAcceptedCostWarning();
                                    if (!consent || !accepted) {
                                      setState(() => _loading = false);
                                      return;
                                    }
                                    final subjectContext =
                                        await _buildSubjectContext();
                                    final answer =
                                        await service.askAiAboutSubject(
                                      'local_user',
                                      question,
                                      subjectContext: subjectContext,
                                    );
                                    setState(() {
                                      _loading = false;
                                      _messages.add(_ChatMessage(
                                        text:
                                            answer ?? 'No response received.',
                                        fromUser: false,
                                      ));
                                    });
                                  },
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
                        hintText: 'Ask about your subjects...',
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
