import '../../data/repositories/database_repository.dart';
import '../../data/models/app_models.dart';

int _busyMinutesForDate(DateTime date, List<TaskModel> tasks) {
  final dayStart = DateTime(date.year, date.month, date.day);
  final dayEnd = dayStart.add(const Duration(days: 1));

  final intervals = <_TimeInterval>[];
  for (final task in tasks) {
    final scheduled = DateTime.tryParse(task.scheduledAt);
    if (scheduled == null) continue;
    if (scheduled.isBefore(dayStart) || !scheduled.isBefore(dayEnd)) continue;
    final end = scheduled.add(Duration(minutes: task.estimatedMinutes));
    intervals.add(_TimeInterval(start: scheduled, end: end));
  }

  if (intervals.isEmpty) return 0;

  intervals.sort((a, b) => a.start.compareTo(b.start));

  final merged = <_TimeInterval>[];
  var current = intervals.first;
  for (var i = 1; i < intervals.length; i++) {
    if (!intervals[i].start.isAfter(current.end)) {
      current = _TimeInterval(
        start: current.start,
        end: current.end.isAfter(intervals[i].end) ? current.end : intervals[i].end,
      );
    } else {
      merged.add(current);
      current = intervals[i];
    }
  }
  merged.add(current);

  int total = 0;
  for (final interval in merged) {
    total += interval.end.difference(interval.start).inMinutes;
  }
  return total;
}

class _TimeInterval {
  final DateTime start;
  final DateTime end;
  _TimeInterval({required this.start, required this.end});
}

List<TaskModel> planTasksWithLimit(
  DatabaseRepository db,
  List<TaskModel> tasks,
  int dailyMinutes, {
  DateTime? date,
}) {
  int availableMinutes = dailyMinutes;
  if (date != null) {
    final busy = _busyMinutesForDate(date, tasks);
    availableMinutes = dailyMinutes - busy;
    if (availableMinutes < 0) availableMinutes = 0;
  }

  final sorted = List<TaskModel>.from(tasks);
  sorted.sort((a, b) {
    final scoreA = db.computeTaskScore(a, dailyMinutes);
    final scoreB = db.computeTaskScore(b, dailyMinutes);
    return scoreB.compareTo(scoreA);
  });
  final selected = <TaskModel>[];
  var used = 0;
  for (final t in sorted) {
    if (used + t.estimatedMinutes > availableMinutes) continue;
    selected.add(t);
    used = used + t.estimatedMinutes;
  }
  return selected;
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String formatDayLabel(DateTime date) {
  const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diff = target.difference(today).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  if (diff > 1 && diff < 7) return days[date.weekday % 7];
  return '${date.day}/${date.month}';
}
