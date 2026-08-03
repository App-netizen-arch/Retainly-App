import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/database_provider.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/database_repository.dart';

class RevisionScreen extends ConsumerStatefulWidget {
  const RevisionScreen({super.key});

  @override
  ConsumerState<RevisionScreen> createState() => _RevisionScreenState();
}

class _RevisionScreenState extends ConsumerState<RevisionScreen> {
  Future<List<MapEntry<RevisionItemModel, String?>>>? _revisionFuture;

  @override
  void initState() {
    super.initState();
    _revisionFuture = _loadRevisionsWithTitles(
      ref.read(databaseRepositoryProvider).value!,
    );
  }

  Future<void> _showRevisionDialog(
    DatabaseRepository db,
    RevisionItemModel item,
    BuildContext context,
    WidgetRef ref,
    String? chapterTitle,
  ) async {
    int confidence = 50;
    int sm2Rating = 2;

    await showDialog<void>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return AlertDialog(
                title: Text(chapterTitle ?? 'Chapter ${item.chapterId}'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Confidence (0-100)'),
                      Slider(
                        value: confidence.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 20,
                        label: '$confidence',
                        onChanged: (v) {
                          confidence = v.round();
                          setDialogState(() {});
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('SM-2 Rating'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _Sm2RatingButton(
                            label: 'Again',
                            color: Theme.of(context).colorScheme.error,
                            selected: sm2Rating == 0,
                            onTap: () {
                              sm2Rating = 0;
                              setDialogState(() {});
                            },
                          ),
                          _Sm2RatingButton(
                            label: 'Hard',
                            color: Theme.of(context).colorScheme.secondary,
                            selected: sm2Rating == 1,
                            onTap: () {
                              sm2Rating = 1;
                              setDialogState(() {});
                            },
                          ),
                          _Sm2RatingButton(
                            label: 'Good',
                            color: Theme.of(context).colorScheme.primary,
                            selected: sm2Rating == 2,
                            onTap: () {
                              sm2Rating = 2;
                              setDialogState(() {});
                            },
                          ),
                          _Sm2RatingButton(
                            label: 'Easy',
                            color: Theme.of(context).colorScheme.tertiary,
                            selected: sm2Rating == 3,
                            onTap: () {
                              sm2Rating = 3;
                              setDialogState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await db.recordRevisionFeedback(
                        item.id!,
                        confidence,
                        'completed',
                      );
                      ref.invalidate(dueRevisionsProvider);
                      ref.invalidate(todayTasksProvider);
                      ref.invalidate(allPendingTasksProvider);
                      if (context.mounted) {
                        final messenger = ScaffoldMessenger.of(context);
                        messenger.hideCurrentSnackBar();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Revision recorded (confidence: $confidence)',
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          ),
    );
  }

  Future<void> _markDone(
    DatabaseRepository db,
    RevisionItemModel item,
    BuildContext context,
    WidgetRef ref,
    String? chapterTitle,
  ) async {
    await _showRevisionDialog(db, item, context, ref, chapterTitle);
  }

  Future<void> _needMorePractice(
    DatabaseRepository db,
    RevisionItemModel item,
    BuildContext context,
    WidgetRef ref,
  ) async {
    final chapter = await db.getChapterById(item.chapterId);
    if (chapter != null) {
      final existing = await db.getTasksByChapter(chapter.id!);
      final hasDuplicate = existing.any(
        (t) => t.title == '${chapter.title} - revision',
      );
      if (!hasDuplicate) {
        final newTask = TaskModel(
          subjectId: chapter.subjectId,
          chapterId: chapter.id,
          title: '${chapter.title} - revision',
          type: 'revision',
          scheduledAt: DateTime.now().toIso8601String(),
          estimatedMinutes: chapter.estimatedMinutes,
          priority: 3,
          status:
              chapter.status == 'in_progress' ? 'in_progress' : 'not_started',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
        await db.insertTask(newTask);
        ref.invalidate(todayTasksProvider);
        ref.invalidate(allPendingTasksProvider);
      }
    }
    await db.recordRevisionFeedback(item.id!, 0, 'completed');
    ref.invalidate(dueRevisionsProvider);
    if (context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Added to planner as high-priority revision task'),
        ),
      );
    }
  }

  Future<void> _postpone(
    DatabaseRepository db,
    RevisionItemModel item,
    BuildContext context,
    WidgetRef ref,
  ) async {
    final newDue = DateTime.now().add(const Duration(days: 1));
    await db.updateRevisionItem(item.id!, {
      'due_at': newDue.toIso8601String(),
      'interval_days': item.intervalDays + 1,
    });
    ref.invalidate(dueRevisionsProvider);
    if (context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Postponed to ${DateFormat('MMM d, y').format(newDue)}',
          ),
        ),
      );
    }
  }

  Future<List<MapEntry<RevisionItemModel, String?>>> _loadRevisionsWithTitles(
    DatabaseRepository db,
  ) async {
    final items = await db.getDueRevisions();
    final results = <MapEntry<RevisionItemModel, String?>>[];
    for (final item in items) {
      final chapter = await db.getChapterById(item.chapterId);
      results.add(MapEntry(item, chapter?.title));
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final dbAsync = ref.watch(databaseRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Revision Queue')),
      body: dbAsync.when(
        data:
            (db) => FutureBuilder<List<MapEntry<RevisionItemModel, String?>>>(
              future: _revisionFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      children: [
                        const Text('Something went wrong. Please try again.'),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (context.mounted) {
                              ref.invalidate(databaseRepositoryProvider);
                            }
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data!;
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'No revisions due. Complete chapters to generate revision items.',
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index].key;
                    final chapterTitle = items[index].value;
                    return Card(
                      child: ListTile(
                        title: Text(
                          chapterTitle ?? 'Chapter ${item.chapterId}',
                        ),
                        subtitle: Text(
                          'Due: ${DateFormat('MMM d, y').format(DateTime.parse(item.dueAt))}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => _postpone(db, item, context, ref),
                              child: const Text('Postpone'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await _needMorePractice(db, item, context, ref);
                              },
                              child: const Text('Need more practice'),
                            ),
                            TextButton(
                              onPressed:
                                  () => _markDone(
                                    db,
                                    item,
                                    context,
                                    ref,
                                    chapterTitle,
                                  ),
                              child: const Text('Done'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (e, _) =>
                Center(child: Text('Something went wrong. Please try again.')),
      ),
    );
  }
}

class _Sm2RatingButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _Sm2RatingButton({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? color.withValues(alpha: 0.2) : null,
        side: BorderSide(color: color),
      ),
      child: Text(label),
    );
  }
}
