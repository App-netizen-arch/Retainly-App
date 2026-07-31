import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database_helper.dart';
import '../data/repositories/database_repository.dart';
import '../data/models/app_models.dart';
import '../data/drift/app_database.dart';
import '../data/drift/database_provider.dart' as drift_provider;
import '../services/sync_worker_service.dart';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return Locale(prefs.getString('app_locale') ?? 'en');
  }

  void setLocale(Locale locale) {
    state = locale;
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) {
    state = date;
  }
}

final selectedDateProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError('SharedPreferences not initialized');
});

final dbFutureProvider = FutureProvider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance.database.then((_) => DatabaseHelper.instance);
});

final driftDatabaseProvider = FutureProvider<AppDatabase?>((ref) async {
  await drift_provider.DatabaseProvider.initialize();
  return drift_provider.DatabaseProvider.driftDb;
});

final databaseRepositoryProvider =
    FutureProvider.autoDispose<DatabaseRepository>((ref) async {
      final db = await ref.watch(dbFutureProvider.future);
      final driftDb = await ref.watch(driftDatabaseProvider.future);
      return DatabaseRepository(db, driftDb: driftDb);
    });

final userProfileProvider = FutureProvider.autoDispose<UserModel?>((ref) async {
  final db = await ref.watch(databaseRepositoryProvider.future);
  return db.getUserProfile();
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile == null) return ThemeMode.system;
  switch (profile.theme) {
    case 'dark':
      return ThemeMode.dark;
    case 'light':
      return ThemeMode.light;
    default:
      return ThemeMode.system;
  }
});

final todayTasksProvider = FutureProvider.autoDispose<List<TaskModel>>((
  ref,
) async {
  final db = await ref.watch(databaseRepositoryProvider.future);
  return db.getTodayTasks();
});

final allPendingTasksProvider = FutureProvider.autoDispose<List<TaskModel>>((
  ref,
) async {
  final db = await ref.watch(databaseRepositoryProvider.future);
  return db.getAllPendingTasks();
});

final dueRevisionsProvider =
    FutureProvider.autoDispose<List<RevisionItemModel>>((ref) async {
      final db = await ref.watch(databaseRepositoryProvider.future);
      return db.getDueRevisions();
    });

final recallTrendsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final db = await ref.watch(databaseRepositoryProvider.future);
      return db.getRecallTrends();
    });

final subjectConfidenceDecayProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final db = await ref.watch(databaseRepositoryProvider.future);
      return db.getSubjectConfidenceDecay();
    });

final progressMetricsProvider = FutureProvider.autoDispose<Map<String, int>>((
  ref,
) async {
  final db = await ref.watch(databaseRepositoryProvider.future);
  final progressRows = await db.getSubjectProgress();
  int totalChapters = 0;
  int completedChapters = 0;
  for (final row in progressRows) {
    totalChapters += row.totalChapters;
    completedChapters += row.completedChapters;
  }
  final allSessions = await db.getFocusSessions();
  final totalMinutes = allSessions.fold<int>(
    0,
    (total, s) => total + s.completedMinutes,
  );
  return {
    'totalMinutes': totalMinutes,
    'completedChapters': completedChapters,
    'totalChapters': totalChapters,
  };
});

final tasksForDateProvider = FutureProvider.autoDispose
    .family<List<TaskModel>, DateTime>((ref, date) async {
      final db = await ref.watch(databaseRepositoryProvider.future);
      return db.getTasksForDate(date);
    });

final dashboardProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) async {
  final db = await ref.watch(databaseRepositoryProvider.future);
  final profile = await ref.watch(userProfileProvider.future);
  return _loadDashboard(db, profile);
});

final weeklyAnalyticsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
      final db = await ref.watch(databaseRepositoryProvider.future);
      return _loadWeeklyAnalytics(db);
    });

final analyticsDetailProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
      final db = await ref.watch(databaseRepositoryProvider.future);
      final accuracy = await db.getTaskEstimateAccuracy();
      final productiveTime = await db.getProductiveTimeInsights();
      final missedPatterns = await db.getMissedDayPatterns();
      final subjectAccuracy = await db.getSubjectEstimateAccuracy();
      final weakTopics = await db.getWeakTopics();
      final pastPaperTasks = await db.getPastPaperTasks();
      final completedPastPapers =
          pastPaperTasks.where((t) => t.status == 'completed').length;
      return {
        'taskAccuracy': accuracy,
        'productiveTime': productiveTime,
        'missedPatterns': missedPatterns,
        'subjectAccuracy': subjectAccuracy,
        'weakTopics': weakTopics,
        'pastPaperTotal': pastPaperTasks.length,
        'pastPaperCompleted': completedPastPapers,
      };
    });

final dataHealthProvider = FutureProvider.autoDispose<String>((ref) async {
  final db = await ref.watch(databaseRepositoryProvider.future);
  final profile = await db.getUserProfile();
  if (profile == null) return 'local_only';
  final backupHistory = await db.getBackupHistory();
  if (backupHistory.isEmpty) return 'saved_local';
  final lastBackup = backupHistory.first;
  final backupDate = DateTime.tryParse(lastBackup['created_at'] ?? '');
  if (backupDate == null) return 'saved_local';
  final diff = DateTime.now().difference(backupDate).inHours;
  if (diff < 24) return 'backed_up';
  return 'local_only';
});

final syncWorkerProvider = Provider<SyncWorkerService>((ref) {
  return SyncWorkerService();
});

final weeklyReflectionProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final db = await ref.watch(databaseRepositoryProvider.future);
      return _loadWeeklyReflections(db);
    });

final syncStatusProvider = Provider<Map<String, int>>((ref) {
  final worker = ref.watch(syncWorkerProvider);
  return {
    'pendingOutbox': worker.pendingOutbox,
    'pendingConflicts': worker.pendingConflicts,
    'prunedTombstones': worker.prunedTombstones,
  };
});

Future<Map<String, dynamic>> _loadDashboard(
  DatabaseRepository db,
  UserModel? profile,
) async {
  final progressRows = await db.getSubjectProgress();
  int totalMinutes = 0;
  int totalChapters = 0;
  int completedChapters = 0;

  for (final row in progressRows) {
    totalChapters += row.totalChapters;
    completedChapters += row.completedChapters;
  }

  final allTaskIds = <int>[];
  final allTasks = await db.getAllTasks();
  allTaskIds.addAll(allTasks.map((t) => t.id).whereType<int>());
  if (allTaskIds.isNotEmpty) {
    final rawDb = await db.db.database;
    final placeholders = List.filled(allTaskIds.length, '?').join(',');
    final result = await rawDb.rawQuery(
      'SELECT COALESCE(SUM(completed_minutes), 0) as total FROM focus_sessions WHERE task_id IN ($placeholders)',
      allTaskIds,
    );
    totalMinutes = result.first['total'] as int;
  }

  final pendingTasks = await db.getAllPendingTasks();
  final suggestedTasks = <TaskModel>[];
  final taskSessions = <int, List<FocusSessionModel>>{};
  final allSessions = await db.getFocusSessions();
  for (final s in allSessions) {
    if (s.taskId != null && s.completedMinutes > 0) {
      taskSessions.putIfAbsent(s.taskId!, () => []).add(s);
    }
  }
  for (final t in pendingTasks) {
    final sessions = taskSessions[t.id];
    if (sessions == null || sessions.length < 2) continue;
    final durations = sessions.map((s) => s.completedMinutes).toList()..sort();
    final median = durations[durations.length ~/ 2];
    if (median > t.estimatedMinutes) {
      suggestedTasks.add(t);
    }
  }

  String insight = '';
  if (suggestedTasks.isNotEmpty) {
    final sample = suggestedTasks.take(2).map((t) => t.title).join(', ');
    insight =
        'Tasks usually take longer: $sample. Consider planning more time.';
  } else if (allSessions.length >= 3) {
    final medianAll =
        allSessions.map((s) => s.completedMinutes).toList()..sort();
    final median = medianAll[medianAll.length ~/ 2];
    insight = 'Your typical study session is around $median min.';
  }

  final revisions = await db.getDueRevisions();
  String nextAction = '';
  if (revisions.isNotEmpty) {
    nextAction =
        'Review ${revisions.length} overdue revision item${revisions.length == 1 ? '' : 's'}';
  }
  final weakTopics = await db.getWeakTopics();
  if (weakTopics.isNotEmpty && nextAction.isEmpty) {
    nextAction =
        'Practice ${weakTopics.take(2).map((c) => c.title).join(', ')} — marked as weak topics';
  } else if (weakTopics.isNotEmpty) {
    nextAction +=
        '. Then review weak topics: ${weakTopics.take(2).map((c) => c.title).join(', ')}';
  }
  if (nextAction.isEmpty && suggestedTasks.isNotEmpty) {
    nextAction =
        'Start with ${suggestedTasks.first.title} — it often needs more time than planned';
  }
  final allChapters = await db.getAllChapters();
  final chapterTitleMap = <int, String>{};
  for (final c in allChapters) {
    if (c.id != null) chapterTitleMap[c.id!] = c.title;
  }

  final dailyMinutes = profile?.dailyStudyMinutes ?? 120;
  final scored =
      pendingTasks.map((t) {
        final score = db.computeTaskScore(t, dailyMinutes);
        return MapEntry(t, score);
      }).toList();
  scored.sort((a, b) => b.value.compareTo(a.value));
  final recommended = scored.isNotEmpty ? scored.first.key : null;

  final todayRaw = await db.getTodayTasks();
  final todayTasks = todayRaw;
  final selected = _getTodayTasksWithLimit(db, todayTasks, dailyMinutes);
  final selectedIds = selected.map((t) => t.id).toSet();
  final overflow =
      todayTasks.where((t) => !selectedIds.contains(t.id)).toList();

  return {
    'totalMinutes': totalMinutes,
    'completedChapters': completedChapters,
    'totalChapters': totalChapters,
    'insight': insight,
    'recommended': recommended,
    'todayTasks': todayTasks,
    'selectedToday': selected,
    'overflowToday': overflow,
    'dailyMinutes': dailyMinutes,
    'revisions': revisions,
    'revisionTitles': chapterTitleMap,
    'examDate': profile?.examDate,
    'minimumViableDay': _computeMinimumViableDay(
      scored,
      dailyMinutes,
      selectedIds,
    ),
    'weakTopics': weakTopics,
    'nextAction': nextAction,
  };
}

TaskModel? _computeMinimumViableDay(
  List<MapEntry<TaskModel, int>> scored,
  int dailyMinutes,
  Set<int?> selectedIds,
) {
  for (final entry in scored) {
    if (entry.value > 0 &&
        entry.key.estimatedMinutes <= dailyMinutes &&
        !selectedIds.contains(entry.key.id)) {
      return entry.key;
    }
  }
  return null;
}

List<TaskModel> _getTodayTasksWithLimit(
  DatabaseRepository db,
  List<TaskModel> tasks,
  int dailyMinutes,
) {
  final sorted = List<TaskModel>.from(tasks);
  sorted.sort((a, b) {
    final scoreA = db.computeTaskScore(a, dailyMinutes);
    final scoreB = db.computeTaskScore(b, dailyMinutes);
    return scoreB.compareTo(scoreA);
  });
  final selected = <TaskModel>[];
  var used = 0;
  for (final t in sorted) {
    if (used + t.estimatedMinutes > dailyMinutes) continue;
    selected.add(t);
    used += t.estimatedMinutes;
  }
  return selected;
}

Future<Map<String, dynamic>> _loadWeeklyAnalytics(DatabaseRepository db) async {
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final weekStartDate = DateTime(
    weekStart.year,
    weekStart.month,
    weekStart.day,
  );
  final weekEndDate = weekStartDate.add(const Duration(days: 7));

  final allSessions = await db.getFocusSessions();
  final weekSessions =
      allSessions.where((s) {
        final started = DateTime.tryParse(s.startedAt);
        return started != null &&
            started.isAfter(weekStartDate.subtract(const Duration(days: 1))) &&
            started.isBefore(weekEndDate);
      }).toList();

  final weekMinutes = weekSessions.fold<int>(
    0,
    (total, s) => total + s.completedMinutes,
  );

  final allTasks = await db.getAllTasks();
  final plannedMinutes = allTasks
      .where((t) {
        final scheduled = DateTime.tryParse(t.scheduledAt);
        return scheduled != null &&
            scheduled.isAfter(
              weekStartDate.subtract(const Duration(days: 1)),
            ) &&
            scheduled.isBefore(weekEndDate);
      })
      .fold<int>(0, (total, t) => total + t.estimatedMinutes);

  final actualMinutes = allTasks
      .where((t) {
        final scheduled = DateTime.tryParse(t.scheduledAt);
        return scheduled != null &&
            scheduled.isAfter(
              weekStartDate.subtract(const Duration(days: 1)),
            ) &&
            scheduled.isBefore(weekEndDate);
      })
      .fold<int>(0, (total, t) => total + t.completedMinutes);

  final allTasksMap = {for (final t in allTasks) if (t.id != null) t.id!: t};

  final subjectMinutes = <int, int>{};
  for (final s in weekSessions) {
    if (s.taskId == null) continue;
    final task = allTasksMap[s.taskId!];
    if (task == null) continue;
    subjectMinutes[task.subjectId] =
        (subjectMinutes[task.subjectId] ?? 0) + s.completedMinutes;
  }

  final subjects = await db.getSubjects();
  final subjectNames = <int, String>{};
  for (final s in subjects) {
    if (s.id != null) subjectNames[s.id!] = s.name;
  }

  final revisions = await db.getDueRevisions();
  final revisionBacklogCount =
      revisions
          .where((r) => DateTime.tryParse(r.dueAt)?.isBefore(now) ?? false)
          .length;

  String nextAction = '';
  if (revisionBacklogCount > 0) {
    nextAction = 'Review $revisionBacklogCount overdue revision items';
  }

  return {
    'weekMinutes': weekMinutes,
    'plannedMinutes': plannedMinutes,
    'actualMinutes': actualMinutes,
    'subjectMinutes': subjectMinutes,
    'subjectNames': subjectNames,
    'revisionBacklog': revisionBacklogCount,
    'sessionCount': weekSessions.length,
    'nextAction': nextAction,
  };
}

Future<List<Map<String, dynamic>>> _loadWeeklyReflections(
  DatabaseRepository db,
) async {
  final allSessions = await db.getFocusSessions();
  final now = DateTime.now();
  final weeks = <Map<String, dynamic>>[];

  for (var i = 7; i >= 0; i--) {
    final weekEnd = now.subtract(Duration(days: i * 7));
    final weekStart = weekEnd.subtract(const Duration(days: 6));
    final weekStartDate = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    final weekEndDate = DateTime(
      weekEnd.year,
      weekEnd.month,
      weekEnd.day,
    ).add(const Duration(days: 1));

    final weekSessions =
        allSessions.where((s) {
          final started = DateTime.tryParse(s.startedAt);
          return started != null &&
              started.isAfter(
                weekStartDate.subtract(const Duration(days: 1)),
              ) &&
              started.isBefore(weekEndDate);
        }).toList();

    if (weekSessions.isEmpty) continue;

    final totalMinutes = weekSessions.fold<int>(
      0,
      (acc, s) => acc + s.completedMinutes,
    );
    final completedSessions =
        weekSessions.where((s) => s.status == 'completed').length;
    final totalSessionsForRate = weekSessions.length;

    final understood =
        weekSessions.where((s) => s.reflectionStatus == 'understood').length;
    final needPractice =
        weekSessions.where((s) => s.reflectionStatus == 'need_practice').length;
    final couldNotFinish =
        weekSessions
            .where((s) => s.reflectionStatus == 'could_not_finish')
            .length;
    final none =
        weekSessions
            .where(
              (s) => s.reflectionStatus == 'none' || s.reflectionStatus == null,
            )
            .length;

    final parkingLotNotes = <String>[];
    for (final s in weekSessions) {
      final notes = s.parkingLotNotes;
      if (notes != null && notes.isNotEmpty) {
        parkingLotNotes.add(notes);
      }
    }
    final topNotes = parkingLotNotes.take(3).toList();

    weeks.add({
      'weekStart':
          '${weekStartDate.year}-${weekStartDate.month.toString().padLeft(2, '0')}-${weekStartDate.day.toString().padLeft(2, '0')}',
      'totalSessions': weekSessions.length,
      'totalMinutes': totalMinutes,
      'completedSessions': completedSessions,
      'totalSessionsForRate': totalSessionsForRate,
      'understood': understood,
      'needPractice': needPractice,
      'couldNotFinish': couldNotFinish,
      'none': none,
      'parkingLotNotes': topNotes,
    });
  }

  return weeks;
}
