import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/database_provider.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/database_repository.dart';
import '../../core/utils/planner_utils.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  String _viewMode = 'day';
  DateTime _weekStart = DateTime.now().subtract(
    Duration(days: DateTime.now().weekday - 1),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dbAsync = ref.watch(databaseRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => GoRouter.of(context).push('/search'),
          ),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'day', label: Text('Day')),
              ButtonSegment(value: 'week', label: Text('Week')),
            ],
            selected: {_viewMode},
            onSelectionChanged: (Set<String> selection) {
              setState(() {
                _viewMode = selection.first;
                if (_viewMode == 'week') {
                  _weekStart = DateTime.now().subtract(
                    Duration(days: DateTime.now().weekday - 1),
                  );
                }
              });
            },
          ),
        ],
      ),
      body: dbAsync.when(
        data: (db) {
          if (_viewMode == 'day') {
            return _buildDayView(context, db);
          }
          return _buildWeekView(context, db);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Something went wrong. Please try again.')),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'reschedule',
            onPressed: () async {
              final dbAsync = ref.read(databaseRepositoryProvider);
              if (dbAsync.isLoading) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Loading database...')),
                  );
                }
                return;
              }
              final db = dbAsync.value;
              if (db == null) return;
              final pending = await db.getAllPendingTasks();
              final nowUtc = DateTime.now().toUtc();
              final overdue =
                  pending.where((t) {
                    if (t.dueAt == null) return false;
                    final due = DateTime.parse(t.dueAt!);
                    return due.isBefore(nowUtc) && t.status != 'completed';
                  }).toList();
              if (overdue.isEmpty) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No missed tasks to reschedule'),
                    ),
                  );
                }
                return;
              }
              if (context.mounted) {
                GoRouter.of(context).push('/reschedule', extra: overdue);
              }
            },
            child: const Icon(Icons.autorenew),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => GoRouter.of(context).push('/tasks/add'),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildDayView(BuildContext context, DatabaseRepository db) {
    final selectedDate = ref.watch(selectedDateProvider);
    final tasksAsync = ref.watch(tasksForDateProvider(selectedDate));
    return tasksAsync.when(
      data: (tasks) {
        final profileAsync = ref.watch(userProfileProvider);
        final dailyMinutes = profileAsync.value?.dailyStudyMinutes ?? 120;
        final selected = planTasksWithLimit(
          db,
          tasks,
          dailyMinutes,
          date: selectedDate,
        );
        final selectedIds = selected.map((t) => t.id).toSet();
        final overflow =
            tasks.where((t) => !selectedIds.contains(t.id)).toList();

        return Column(
          children: [
            SizedBox(
              height: 72,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: 14,
                itemBuilder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index));
                  final isSelected = isSameDay(date, selectedDate);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(selectedDateProvider.notifier).setDate(date);
                        }
                      },
                      label: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatDayLabel(date),
                            style: const TextStyle(fontSize: 11),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '${date.day}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            date.month.toString(),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _buildTaskList(context, selected, overflow, dailyMinutes),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildWeekView(BuildContext context, DatabaseRepository db) {
    final weekDays = List.generate(7, (index) {
      final day = _weekStart.add(Duration(days: index));
      return DateTime(day.year, day.month, day.day);
    });
    final weekStart = weekDays.first;
    final weekEnd = weekDays.last;

    return FutureBuilder<List<TaskModel>>(
      future: db.getTasksForDateRange(weekStart, weekEnd),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final allTasks = snapshot.data!;
        final profileAsync = ref.watch(userProfileProvider);
        final dailyMinutes = profileAsync.value?.dailyStudyMinutes ?? 120;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: weekDays.length,
          itemBuilder: (context, index) {
            final date = weekDays[index];
            final tasks = allTasks.where((t) {
              final scheduled = DateTime.tryParse(t.scheduledAt);
              if (scheduled == null) return false;
              final taskDay = DateTime(
                scheduled.year,
                scheduled.month,
                scheduled.day,
              );
              return taskDay == date;
            }).toList();
            final totalMinutes = tasks.fold<int>(
              0,
              (sum, t) => sum + t.estimatedMinutes,
            );
            final isToday = isSameDay(date, DateTime.now());

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color:
                  isToday
                      ? Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.3)
                      : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          DateFormat('EEE, MMM d').format(date),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Text(
                          '$totalMinutes / $dailyMinutes min',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (tasks.isEmpty)
                      const Text(
                        'No tasks',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      ...tasks.map(
                        (t) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Checkbox(
                                value: t.status == 'completed',
                                onChanged: (v) async {
                                  if (v == null || t.id == null) return;
                                  await db.updateTask(t.id!, {
                                    'status': v ? 'completed' : 'not_started',
                                    'updated_at':
                                        DateTime.now().toIso8601String(),
                                  });
                                  ref.invalidate(tasksForDateProvider(date));
                                  ref.invalidate(todayTasksProvider);
                                },
                              ),
                              Expanded(
                                child: Text(
                                  t.title,
                                  style: TextStyle(
                                    decoration:
                                        t.status == 'completed'
                                            ? TextDecoration.lineThrough
                                            : null,
                                  ),
                                ),
                              ),
                              Text('${t.estimatedMinutes} min'),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    List<TaskModel> selected,
    List<TaskModel> overflow,
    int dailyMinutes,
  ) {
    final tasks = [...selected, ...overflow];
    final selectedDate = ref.read(selectedDateProvider);
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          'No tasks for ${formatDayLabel(selectedDate)}. Tap + to add a study task.',
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (selected.isNotEmpty) ...[
          Text(
            'Plan (${selected.length} tasks)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ..._buildTaskCards(context, selected),
        ],
        if (overflow.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Overflow (${overflow.length} tasks beyond daily limit)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ..._buildTaskCards(context, overflow),
        ],
      ],
    );
  }

  List<Widget> _buildTaskCards(BuildContext context, List<TaskModel> tasks) {
    final selectedDate = ref.read(selectedDateProvider);
    return tasks.map((task) {
      final tags = <String>[];
      if (task.isPastPaper) tags.add('Past Paper');
      final originalEstimate = task.originalEstimatedMinutes;
      final isRevised =
          originalEstimate != null && originalEstimate != task.estimatedMinutes;
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: Text(task.title),
          subtitle: Text(
            '${task.estimatedMinutes} min • ${_taskTypeLabel(task.type)}${tags.isNotEmpty ? " • ${tags.join(', ')}" : ""}${isRevised ? ' • Revised' : ''}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isRevised)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$originalEstimate→${task.estimatedMinutes}',
                    style: const TextStyle(fontSize: 10, color: Colors.orange),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.autorenew, color: Colors.orange),
                onPressed:
                    task.id != null
                        ? () async {
                          final newDate = DateTime.now();
                          await ref
                              .read(databaseRepositoryProvider)
                              .value
                              ?.updateTask(task.id!, {
                                'scheduled_at': newDate.toIso8601String(),
                                'is_rescheduled': 1,
                              });
                          ref.invalidate(todayTasksProvider);
                          ref.invalidate(allPendingTasksProvider);
                          ref.invalidate(dashboardProvider);
                          ref.invalidate(tasksForDateProvider(selectedDate));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Task rescheduled to today'),
                              ),
                            );
                          }
                        }
                        : null,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed:
                    task.id != null
                        ? () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: const Text('Delete Plan'),
                                  content: const Text(
                                    'Are you sure you want to delete this plan? This action cannot be undone.',
                                  ),
                                   actions: [
                                     TextButton(
                                       onPressed:
                                           () => Navigator.pop(ctx, false),
                                       child: const Text('Cancel'),
                                     ),
                                     FilledButton.icon(
                                       onPressed: () => Navigator.pop(ctx, true),
                                       icon: const Icon(Icons.delete_outline),
                                       label: const Text('Delete'),
                                       style: FilledButton.styleFrom(
                                         backgroundColor:
                                             Theme.of(context).colorScheme.error,
                                       ),
                                     ),
                                   ],
                                ),
                          );
                          if (confirmed != true) return;
                          try {
                            await ref
                                .read(databaseRepositoryProvider)
                                .value
                                ?.deleteTask(task.id!);
                            ref.invalidate(todayTasksProvider);
                            ref.invalidate(allPendingTasksProvider);
                            ref.invalidate(dueRevisionsProvider);
                            ref.invalidate(dashboardProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Plan deleted')),
                              );
                            }
                          } on Exception catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to delete: ${e.toString()}',
                                  ),
                                ),
                              );
                            }
                          }
                        }
                        : null,
              ),
              Checkbox(
                value: task.status == 'completed',
                onChanged: (v) async {
                  if (v == null || task.id == null) return;
                  try {
                    final newStatus =
                        v
                            ? 'completed'
                            : (task.completedMinutes > 0
                                ? 'in_progress'
                                : 'not_started');
                    await ref
                        .read(databaseRepositoryProvider)
                        .value
                        ?.updateTask(task.id!, {
                          'status': newStatus,
                          if (v) 'completed_minutes': task.estimatedMinutes,
                          'updated_at': DateTime.now().toIso8601String(),
                        });
                    ref.invalidate(todayTasksProvider);
                    ref.invalidate(allPendingTasksProvider);
                    ref.invalidate(dashboardProvider);
                    ref.invalidate(tasksForDateProvider(selectedDate));
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Updated')));
                    }
                  } on Exception catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update: ${e.toString()}'),
                        ),
                      );
                    }
                  }
                },
              ),
              ElevatedButton(
                onPressed:
                    task.id != null
                        ? () => GoRouter.of(
                          context,
                        ).push('/focus', extra: {'taskId': task.id})
                        : null,
                child: const Text('Start'),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  String _taskTypeLabel(String type) {
    switch (type) {
      case 'homework':
        return 'Homework';
      case 'revision':
        return 'Revision';
      case 'past_paper':
        return 'Past Paper';
      case 'practical':
        return 'Practical';
      default:
        return 'Custom';
    }
  }
}
