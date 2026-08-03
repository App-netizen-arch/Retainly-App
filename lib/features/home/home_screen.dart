import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/database_provider.dart';
import '../../data/models/app_models.dart';
import '../../services/ai_service.dart';
import 'ai_sidebar_panel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Now'),
        leading: Builder(
          builder:
               (ctx) => IconButton(
                 icon: Container(
                   width: 36,
                   height: 36,
                   decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     gradient: LinearGradient(
                       colors: [
                         Theme.of(context).colorScheme.primary,
                         Theme.of(context).colorScheme.tertiary,
                       ],
                     ),
                   ),
                   child: Icon(
                     Icons.auto_awesome,
                     size: 20,
                     color: Theme.of(context).colorScheme.onPrimary,
                   ),
                 ),
                 tooltip: 'Open AI assistant',
                 onPressed: () async {
                  final service = AIService();
                  final consented = await service.hasAiConsent();
                  final accepted = await service.hasAcceptedAiPolicy();
                  if (!consented || !accepted) {
                    if (!ctx.mounted) return;
                    final proceed = await showDialog<bool>(
                      context: ctx,
                      builder:
                          (dctx) => AlertDialog(
                            title: const Text('AI Assistant Policy'),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'This AI study assistant uses online AI services to answer questions, generate quizzes, and create flashcards.',
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
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
                                  if (ctx.mounted) {
                                    Navigator.pop(dctx, true);
                                    Scaffold.of(ctx).openDrawer();
                                  }
                                },
                                child: const Text('Accept & Continue'),
                              ),
                            ],
                          ),
                    );
                    if (!ctx.mounted) return;
                    if (proceed != true && ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'You must accept the AI policy to use the assistant.',
                          ),
                        ),
                      );
                    }
                    return;
                  }
                  if (ctx.mounted) {
                    Scaffold.of(ctx).openDrawer();
                  }
                },
              ),
        ),
        actions: [
           IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => GoRouter.of(context).push('/search'),
          ),
        ],
      ),
      drawer: const AiSidebarPanel(),
      body: dashboardAsync.when(
        data: (data) {
          final examDate = data['examDate'] as String?;
          final recommended = data['recommended'] as TaskModel?;
          final selectedToday = data['selectedToday'] as List<TaskModel>;
          final overflowToday = data['overflowToday'] as List<TaskModel>;
          final revisions = data['revisions'] as List<RevisionItemModel>;
          final revisionTitles = data['revisionTitles'] as Map<int, String>;
          final dailyMinutes = data['dailyMinutes'] as int;
          final totalMinutes = data['totalMinutes'] as int;
          final completedChapters = data['completedChapters'] as int;
          final totalChapters = data['totalChapters'] as int;
          final insight = data['insight'] as String?;
          final nextAction = data['nextAction'] as String? ?? '';

          final selectedMinutes = selectedToday.fold<int>(
            0,
            (sum, t) => sum + t.estimatedMinutes,
          );

          String countdownText = 'No exam date set';
          if (examDate != null && examDate.isNotEmpty) {
            final exam = DateTime.tryParse(examDate);
            if (exam != null) {
              final now = DateTime.now();
              final diff = exam.difference(now);
              if (diff.isNegative) {
                countdownText = 'Exam has passed';
              } else if (diff.inDays == 0) {
                countdownText = 'Exam is today';
              } else {
                countdownText = '${diff.inDays} days remaining';
              }
            }
          }

          final minimumViableDay = data['minimumViableDay'] as TaskModel?;

          if (recommended == null &&
              selectedToday.isEmpty &&
              overflowToday.isEmpty &&
              revisions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No tasks recommended yet. Add subjects and chapters in Subjects, then plan tasks in Planner to build your study plan.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.celebration_outlined, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Exam Countdown',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              countdownText,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (recommended != null) ...[
                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Recommended next task',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    recommended.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${recommended.estimatedMinutes} min',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _recommendationLabel(
                                      recommended,
                                      dailyMinutes,
                                    ),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ),
                            Semantics(
                              label: 'Start ${recommended.title}',
                              child: ElevatedButton(
                                onPressed:
                                    recommended.id != null
                                        ? () => GoRouter.of(context).push(
                                          '/focus',
                                          extra: {'taskId': recommended.id},
                                        )
                                        : null,
                                child: const Text('Start'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (minimumViableDay != null && overflowToday.isNotEmpty) ...[
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Minimum viable day',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Focus on one manageable task: ${minimumViableDay.title} (${minimumViableDay.estimatedMinutes} min).',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed:
                              minimumViableDay.id != null
                                  ? () => GoRouter.of(context).push(
                                    '/focus',
                                    extra: {'taskId': minimumViableDay.id},
                                  )
                                  : null,
                          child: const Text('Start this task'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                'Today\u2019s focus plan ($selectedMinutes / $dailyMinutes min used)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (selectedToday.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No tasks scheduled for today. Add a task from the planner.',
                    ),
                  ),
                )
              else
                ...selectedToday.map(
                  (t) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(t.title),
                      subtitle: Text('${t.estimatedMinutes} min'),
                      trailing: ElevatedButton(
                        onPressed:
                            t.id != null
                                ? () => GoRouter.of(
                                  context,
                                ).push('/focus', extra: {'taskId': t.id})
                                : null,
                        child: const Text('Start'),
                      ),
                    ),
                  ),
                ),
              if (overflowToday.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Overflow (${overflowToday.length} tasks beyond daily limit)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...overflowToday.map(
                  (t) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: ListTile(
                      title: Text(t.title),
                      subtitle: Text('${t.estimatedMinutes} min'),
                      trailing: ElevatedButton(
                        onPressed:
                            t.id != null
                                ? () => GoRouter.of(
                                  context,
                                ).push('/focus', extra: {'taskId': t.id})
                                : null,
                        child: const Text('Start'),
                      ),
                    ),
                  ),
                ),
              ],
              if (revisions.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Due for revision',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...revisions.map(
                  (r) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: ListTile(
                      leading: const Icon(Icons.refresh),
                      title: Text(
                        revisionTitles[r.chapterId] ?? 'Chapter ${r.chapterId}',
                      ),
                      subtitle: Text('Due: ${r.dueAt}'),
                      trailing: TextButton(
                        onPressed: () => GoRouter.of(context).push('/revision'),
                        child: const Text('Revise'),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'AI Quick Actions',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Online AI (Internet Required)',
                            style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _AiActionChip(
                              label: 'What to do now',
                              icon: Icons.psychology,
                              onTap: () async {
                                try {
                                  final service = AIService();
                                  final gate = await service.checkAiGate('local_user');
                                  if (gate != null) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        SnackBar(
                                          content: Text(gate),
                                          duration: const Duration(seconds: 4),
                                        ),
                                      );
                                    return;
                                  }
                                  final db = await ref.read(
                                    databaseRepositoryProvider.future,
                                  );
                                  final subjects = await db.getSubjects();
                                  final contextStr =
                                      subjects.isEmpty
                                          ? 'No subjects yet.'
                                          : subjects
                                              .map((s) => s.name)
                                              .join(', ');
                                  final answer = await service.askAiAboutSubject(
                                    'local_user',
                                    'Based on my subjects ($contextStr), what should I study right now?',
                                  );
                                  if (!context.mounted) return;
                                  final messenger = ScaffoldMessenger.of(context);
                                  messenger.hideCurrentSnackBar();
                                  final display =
                                      answer != null && answer.startsWith('AI_ERROR:')
                                          ? answer.substring('AI_ERROR:'.length).trim()
                                          : (answer ?? 'Could not generate a suggestion.');
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(display),
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                                } catch (_) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Something went wrong. Please retry.',
                                        ),
                                        duration: Duration(seconds: 4),
                                      ),
                                    );
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            _AiActionChip(
                              label: 'Quiz me',
                              icon: Icons.quiz,
                              onTap: () async {
                                try {
                                  final service = AIService();
                                  final gate = await service.checkAiGate('local_user');
                                  if (gate != null) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        SnackBar(
                                          content: Text(gate),
                                          duration: const Duration(seconds: 4),
                                        ),
                                      );
                                    return;
                                  }
                                  final db = await ref.read(
                                    databaseRepositoryProvider.future,
                                  );
                                  final subjects = await db.getSubjects();
                                  final contextStr =
                                      subjects.isEmpty
                                          ? 'my subjects'
                                          : subjects
                                              .map((s) => s.name)
                                              .join(', ');
                                  final answer = await service.askAiAboutSubject(
                                    'local_user',
                                    'Generate a short quiz for my subjects: $contextStr',
                                  );
                                  if (!context.mounted) return;
                                  final messenger = ScaffoldMessenger.of(context);
                                  messenger.hideCurrentSnackBar();
                                  final display =
                                      answer != null && answer.startsWith('AI_ERROR:')
                                          ? answer.substring('AI_ERROR:'.length).trim()
                                          : (answer ?? 'Could not generate a quiz.');
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(display),
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                                } catch (_) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Something went wrong. Please retry.',
                                        ),
                                        duration: Duration(seconds: 4),
                                      ),
                                    );
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            _AiActionChip(
                              label: 'Flashcards',
                              icon: Icons.style,
                              onTap: () async {
                                try {
                                  final service = AIService();
                                  final gate = await service.checkAiGate('local_user');
                                  if (gate != null) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        SnackBar(
                                          content: Text(gate),
                                          duration: const Duration(seconds: 4),
                                        ),
                                      );
                                    return;
                                  }
                                  final db = await ref.read(
                                    databaseRepositoryProvider.future,
                                  );
                                  final subjects = await db.getSubjects();
                                  final contextStr =
                                      subjects.isEmpty
                                          ? 'my subjects'
                                          : subjects
                                              .map((s) => s.name)
                                              .join(', ');
                                  if (!context.mounted) return;
                                  GoRouter.of(context).push(
                                    '/ai/flashcards',
                                    extra: {
                                      'sourceText': 'Create 5 flashcards for my subjects: $contextStr',
                                      'sourceTitle': 'AI Flashcards - $contextStr',
                                    },
                                  );
                                } catch (_) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Something went wrong. Please retry.',
                                        ),
                                        duration: Duration(seconds: 4),
                                      ),
                                    );
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            _AiActionChip(
                              label: 'Study plan',
                              icon: Icons.calendar_today,
                              onTap: () async {
                                try {
                                  final service = AIService();
                                  final gate = await service.checkAiGate('local_user');
                                  if (gate != null) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        SnackBar(
                                          content: Text(gate),
                                          duration: const Duration(seconds: 4),
                                        ),
                                      );
                                    return;
                                  }
                                  final db = await ref.read(
                                    databaseRepositoryProvider.future,
                                  );
                                  final subjects = await db.getSubjects();
                                  final contextStr =
                                      subjects.isEmpty
                                          ? 'my subjects'
                                          : subjects
                                              .map((s) => s.name)
                                              .join(', ');
                                  final answer = await service.askAiAboutSubject(
                                    'local_user',
                                    'Create a 3-day study plan for my subjects: $contextStr',
                                  );
                                  if (!context.mounted) return;
                                  final messenger = ScaffoldMessenger.of(context);
                                  messenger.hideCurrentSnackBar();
                                  final display =
                                      answer != null && answer.startsWith('AI_ERROR:')
                                          ? answer.substring('AI_ERROR:'.length).trim()
                                          : (answer ?? 'Could not generate a study plan.');
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(display),
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                                } catch (_) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Something went wrong. Please retry.',
                                        ),
                                        duration: Duration(seconds: 4),
                                      ),
                                    );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _StatChip(
                              icon: Icons.timer,
                              label: 'Study time',
                              value: '$totalMinutes min',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatChip(
                              icon: Icons.check_circle,
                              label: 'Chapters',
                              value: '$completedChapters / $totalChapters',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Study-time learning',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      if (nextAction.isNotEmpty)
                        Semantics(
                          label: 'Next action suggestion',
                          child: Card(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
Icon(
    Icons.tips_and_updates,
    color: Theme.of(context).colorScheme.tertiary,
),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(nextAction)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (insight != null && insight.isNotEmpty)
                        Text(insight)
                      else
                        const Text(
                          'Complete more sessions to see duration insights.',
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (e, _) =>
                Center(child: Text('Something went wrong. Please try again.')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => GoRouter.of(context).push('/planner'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

String _recommendationLabel(TaskModel task, int dailyMinutes) {
  final now = DateTime.now();
  if (task.dueAt != null) {
    final diff = DateTime.parse(task.dueAt!).difference(now).inDays;
    if (diff < 0) return 'Overdue — prioritize this task';
    if (diff == 0) return 'Due today — focus on this';
    if (diff <= 3) return 'Due in $diff days — start soon';
  }
  if (task.priority >= 3) return 'High priority task';
  if (task.estimatedMinutes <= dailyMinutes) {
    return 'Fits within your daily limit';
  }
  return 'Consider breaking this into smaller steps';
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _AiActionChip extends StatelessWidget {
  const _AiActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
