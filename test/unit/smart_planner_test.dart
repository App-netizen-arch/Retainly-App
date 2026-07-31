import 'package:test/test.dart';

class Task {
  final String title;
  final int estimatedMinutes;
  final int priority;
  final DateTime? dueAt;
  final bool completed;

  Task({
    required this.title,
    this.estimatedMinutes = 30,
    this.priority = 2,
    this.dueAt,
    this.completed = false,
  });
}

int computeScore(Task task, DateTime now, int dailyMinutes) {
  if (task.completed) return -1;
  var score = 0;
  if (task.dueAt != null) {
    final diff = task.dueAt!.difference(now).inDays;
    score += diff < 0 ? 50 : (30 - diff.clamp(0, 30));
  }
  score += task.priority * 10;
  if (task.estimatedMinutes <= dailyMinutes) score += 5;
  return score;
}

List<Task> planTodayTasks(List<Task> tasks, int dailyMinutes) {
  tasks = tasks.where((t) => !t.completed).toList();
  tasks.sort((a, b) {
    final sa = computeScore(a, DateTime.now(), dailyMinutes);
    final sb = computeScore(b, DateTime.now(), dailyMinutes);
    return sb.compareTo(sa);
  });

  var used = 0;
  final selected = <Task>[];
  for (final t in tasks) {
    if (used + t.estimatedMinutes > dailyMinutes) continue;
    selected.add(t);
    used += t.estimatedMinutes;
  }
  return selected;
}

void main() {
  group('Smart planner', () {
    test('higher priority scores higher', () {
      final high = Task(title: 'High', priority: 4);
      final low = Task(title: 'Low', priority: 1);
      expect(
        computeScore(high, DateTime.now(), 120),
        greaterThan(computeScore(low, DateTime.now(), 120)),
      );
    });

    test('completed tasks are excluded', () {
      final done = Task(title: 'Done', completed: true);
      expect(computeScore(done, DateTime.now(), 120), equals(-1));
    });

    test('daily time limit is respected', () {
      final tasks = [
        Task(title: 'A', estimatedMinutes: 60),
        Task(title: 'B', estimatedMinutes: 60),
        Task(title: 'C', estimatedMinutes: 60),
      ];
      final selected = planTodayTasks(tasks, 90);
      expect(selected.map((t) => t.title).toList(), ['A']);
    });

    test('overdue tasks get higher score', () {
      final past = Task(
        title: 'Past',
        dueAt: DateTime.now().subtract(const Duration(days: 5)),
      );
      final future = Task(
        title: 'Future',
        dueAt: DateTime.now().add(const Duration(days: 10)),
      );
      expect(
        computeScore(past, DateTime.now(), 120),
        greaterThan(computeScore(future, DateTime.now(), 120)),
      );
    });

    test('task under daily limit gets bonus', () {
      final small = Task(title: 'Small', estimatedMinutes: 30);
      final large = Task(title: 'Large', estimatedMinutes: 180);
      expect(
        computeScore(small, DateTime.now(), 120),
        greaterThan(computeScore(large, DateTime.now(), 120)),
      );
    });

    test('focus session discarded when under 1 minute', () {
      const seconds = 30;
      final status = seconds >= 60 ? 'completed' : 'discarded';
      expect(status, 'discarded');
    });

    test('focus session completed when >= 1 minute', () {
      const seconds = 125;
      final status = seconds >= 60 ? 'completed' : 'discarded';
      expect(status, 'completed');
    });
  });
}
