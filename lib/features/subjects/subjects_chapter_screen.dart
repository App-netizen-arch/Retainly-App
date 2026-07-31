import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/database_provider.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/database_repository.dart';
import '../../data/database_helper.dart';

class SubjectsChapterScreen extends ConsumerStatefulWidget {
  const SubjectsChapterScreen({super.key, required this.subjectId});

  final int subjectId;

  @override
  ConsumerState<SubjectsChapterScreen> createState() =>
      _SubjectsChapterScreenState();
}

class _SubjectsChapterScreenState extends ConsumerState<SubjectsChapterScreen> {
  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final dbAsync = ref.watch(databaseRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Chapters')),
      body: dbAsync.when(
        data:
            (db) => FutureBuilder<List<ChapterModel>>(
              future: db.getChaptersBySubject(widget.subjectId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final chapters = snapshot.data!;
                if (chapters.isEmpty) {
                  return const Center(child: Text('No chapters yet. Chapters are created when you set up subjects.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    return Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: chapter.status == 'completed',
                          onChanged: (v) async {
                            if (v == null || chapter.id == null) return;
                            try {
                              await db.setChapterCompletion(chapter.id!, v);
                              if (v == true) {
                                final now = DateTime.now();
                                final dbRepo = db;
                                final sm2Intervals = _sm2InitialIntervals();
                                for (var i = 0; i < sm2Intervals.length; i++) {
                                  final interval = sm2Intervals[i];
                                  final existing = await dbRepo
                                      .getRevisionItemsByChapterAndInterval(
                                        chapter.id!,
                                        interval,
                                      );
                                  if (existing.isEmpty) {
                                    await dbRepo.insertRevisionItem(
                                      RevisionItemModel(
                                        chapterId: chapter.id!,
                                        dueAt:
                                            now
                                                .add(Duration(days: interval))
                                                .toIso8601String(),
                                        intervalDays: interval,
                                        status: 'pending',
                                        createdAt: now.toIso8601String(),
                                        easeFactor: 2.5,
                                        repetitions: i,
                                      ),
                                    );
                                  }
                                }
                              } else {
                                await db.deleteRevisionItemsByChapter(
                                  chapter.id!,
                                );
                              }
                              if (context.mounted) {
                                setState(() {});
                              }
                            } on Exception catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to update: ${e.toString()}',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        title: Text(chapter.title),
                        subtitle: Text(
                          [
                            '${chapter.estimatedMinutes} min',
                            if (chapter.contentSource != null)
                              'Source: ${chapter.contentSource}',
                            if (chapter.contentVersion != null)
                              'v${chapter.contentVersion}',
                            if (chapter.confidence != null &&
                                chapter.confidence! < 50)
                              'Low confidence',
                            if (chapter.contentTier != 'official')
                              'Tier: ${chapter.contentTier}',
                            if (chapter.reviewDate != null &&
                                DateTime.tryParse(
                                      chapter.reviewDate!,
                                    )?.isBefore(DateTime.now()) ==
                                    true)
                              '⚠ Past due',
                          ].join(' • '),
                        ),
                        trailing: Semantics(
                          button: true,
                          label: 'Chapter options for ${chapter.title}',
                          child: PopupMenuButton<String>(
                            onSelected: (v) async {
                              if (v == 'edit' && chapter.id != null) {
                                await _editChapter(context, db, chapter);
                              } else if (v == 'weak' && chapter.id != null) {
                                await db.toggleWeakTopic(
                                  chapter.id!,
                                  !(chapter.confidence != null &&
                                      chapter.confidence! < 50),
                                );
                                if (mounted) setState(() {});
                              } else if (v == 'report' && chapter.id != null) {
                                await _reportChapterError(context, chapter.id!);
                              }
                            },
                            itemBuilder:
                                (ctx) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit content info'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'weak',
                                    child: Text('Mark as weak topic'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'report',
                                    child: Text('Report error'),
                                  ),
                                ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Something went wrong. Please try again.')),
      ),
    );
  }

  Future<void> _editChapter(
    BuildContext context,
    DatabaseRepository db,
    ChapterModel chapter,
  ) async {
    final sourceController = TextEditingController(
      text: chapter.contentSource ?? '',
    );
    final versionController = TextEditingController(
      text: chapter.contentVersion ?? '',
    );
    final reviewController = TextEditingController(
      text: chapter.reviewDate ?? '',
    );
    String contentTier = chapter.contentTier;
    if (!mounted) return;
    await showDialog<bool>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return AlertDialog(
                title: const Text('Chapter content info'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: sourceController,
                        decoration: const InputDecoration(
                          labelText: 'Content source',
                        ),
                      ),
                      TextField(
                        controller: versionController,
                        decoration: const InputDecoration(labelText: 'Version'),
                      ),
                      TextField(
                        controller: reviewController,
                        decoration: const InputDecoration(
                          labelText: 'Review date',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('Content Tier'),
                      DropdownButtonFormField<String>(
                        initialValue: contentTier,
                        items: const [
                          DropdownMenuItem(
                            value: 'official',
                            child: Text('Official'),
                          ),
                          DropdownMenuItem(
                            value: 'student',
                            child: Text('Student'),
                          ),
                          DropdownMenuItem(
                            value: 'ai-generated',
                            child: Text('AI Generated'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            contentTier = v;
                            setDialogState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (chapter.id == null) return;
                      await db.updateChapter(chapter.id!, {
                        'content_source':
                            sourceController.text.trim().isEmpty
                                ? null
                                : sourceController.text.trim(),
                        'content_version':
                            versionController.text.trim().isEmpty
                                ? null
                                : versionController.text.trim(),
                        'review_date':
                            reviewController.text.trim().isEmpty
                                ? null
                                : reviewController.text.trim(),
                        'content_tier': contentTier,
                      });
                      if (ctx.mounted) Navigator.pop(ctx, true);
                      if (mounted) setState(() {});
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          ),
    );
  }

  List<int> _sm2InitialIntervals() => const [1, 3, 7];

  Future<void> _reportChapterError(BuildContext context, int chapterId) async {
    final controller = TextEditingController();
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Report error in chapter'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'What looks wrong?'),
              maxLines: 4,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Send'),
              ),
            ],
          ),
    );
    if (confirmed != true || controller.text.trim().isEmpty) return;
    await DatabaseHelper.instance.insertBackupRecord({
      'created_at': DateTime.now().toIso8601String(),
      'destination': 'chapter:error:$chapterId',
      'status': controller.text.trim(),
    });
    if (mounted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Report submitted. Thank you.')),
      );
    }
  }
}
