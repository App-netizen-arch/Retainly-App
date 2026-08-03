import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/database_provider.dart';
import '../../data/models/app_models.dart';

class RescheduleScreen extends ConsumerStatefulWidget {
  final List<TaskModel> tasks;

  const RescheduleScreen({super.key, required this.tasks});

  @override
  ConsumerState<RescheduleScreen> createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends ConsumerState<RescheduleScreen> {
  late List<TaskModel> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = widget.tasks.map((t) => t).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dbAsync = ref.watch(databaseRepositoryProvider);
    final today = DateTime.now().toIso8601String();

    return Scaffold(
      appBar: AppBar(title: const Text('Reschedule Tasks')),
      body: dbAsync.when(
        data: (db) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final current = _tasks[index];
              final changed = current.scheduledAt != today;
              return Card(
                color:
                    changed
                        ? Theme.of(context).colorScheme.surfaceContainerHighest
                        : null,
                child: ListTile(
                  title: Text(current.title),
                  subtitle: Text(
                    'Remaining: ${current.estimatedMinutes - current.completedMinutes} min'
                    '${changed ? ' • Rescheduled → today' : ''}',
                  ),
                  trailing: IconButton(
                     icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                     tooltip: 'Delete task',
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: const Text('Delete Task'),
                              content: const Text(
                                'Are you sure you want to delete this task? This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                      );
                      if (confirmed != true) return;
                      if (current.id != null) {
                        await db.deleteTask(current.id!);
                      }
                      setState(() => _tasks.removeAt(index));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Task deleted')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed:
              _tasks.isEmpty
                  ? null
                  : () async {
                    final db = ref.read(databaseRepositoryProvider).value;
                    if (db != null) {
                      for (final task in _tasks) {
                        await db.updateTask(task.id!, {
                          'scheduled_at': today,
                          'is_rescheduled': 1,
                        });
                      }
                    }
                    ref.invalidate(todayTasksProvider);
                    ref.invalidate(allPendingTasksProvider);
                    ref.invalidate(dashboardProvider);
                    if (context.mounted && GoRouter.of(context).canPop()) {
                      GoRouter.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Rescheduled ${_tasks.length} task(s) to today',
                          ),
                        ),
                      );
                    }
                  },
          child: Text('Confirm Reschedule (${_tasks.length})'),
        ),
      ),
    );
  }
}
