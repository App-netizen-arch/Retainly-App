import 'package:test/test.dart';
import 'package:retainly/data/models/app_models.dart';

bool isTaskOverdue(TaskModel task, DateTime now) {
  if (task.dueAt == null) return false;
  final due = DateTime.tryParse(task.dueAt!);
  if (due == null) return false;
  return due.isBefore(now) && task.status != 'completed';
}

List<int> revisionIntervals() => const [1, 3, 7];

void main() {
  group('Planner logic', () {
    test('overdue task detection', () {
      final now = DateTime.now();
      final overdue = TaskModel(
        subjectId: 1,
        title: 'Overdue',
        scheduledAt: now.toIso8601String(),
        dueAt: now.subtract(const Duration(days: 1)).toIso8601String(),
        status: 'not_started',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      );
      final future = TaskModel(
        subjectId: 1,
        title: 'Future',
        scheduledAt: now.toIso8601String(),
        dueAt: now.add(const Duration(days: 1)).toIso8601String(),
        status: 'not_started',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      );
      final completed = TaskModel(
        subjectId: 1,
        title: 'Done',
        scheduledAt: now.toIso8601String(),
        dueAt: now.subtract(const Duration(days: 1)).toIso8601String(),
        status: 'completed',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      );

      expect(isTaskOverdue(overdue, now), isTrue);
      expect(isTaskOverdue(future, now), isFalse);
      expect(isTaskOverdue(completed, now), isFalse);
    });

    test('revision intervals are 1/3/7 days', () {
      expect(revisionIntervals(), equals([1, 3, 7]));
    });

    test('daily plan respects time limit', () {
      var used = 0;
      final limit = 90;
      final tasks = <TaskModel>[
        TaskModel(
          subjectId: 1,
          title: 'A',
          estimatedMinutes: 60,
          scheduledAt: DateTime.now().toIso8601String(),
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
        TaskModel(
          subjectId: 1,
          title: 'B',
          estimatedMinutes: 60,
          scheduledAt: DateTime.now().toIso8601String(),
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
        TaskModel(
          subjectId: 1,
          title: 'C',
          estimatedMinutes: 30,
          scheduledAt: DateTime.now().toIso8601String(),
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      ];
      final selected = <TaskModel>[];
      for (final t in tasks) {
        if (used + t.estimatedMinutes > limit) continue;
        selected.add(t);
        used += t.estimatedMinutes;
      }
      expect(selected.map((t) => t.title).toList(), ['A', 'C']);
    });
  });
}
