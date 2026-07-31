import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:retainly/data/database_helper.dart';
import 'package:retainly/data/models/app_models.dart';
import 'package:retainly/core/constants/matric_subjects.dart';
import 'package:retainly/data/drift/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;

typedef DriftDb = AppDatabase;

class DatabaseRepository {
  final DatabaseHelper db;
  final DriftDb? driftDb;

  DatabaseRepository(this.db, {this.driftDb});

  bool get _useDrift => driftDb != null;

  final double _sm2MinEaseFactor = 1.3;

  double _sm2NewEaseFactor(double currentEaseFactor, int quality) {
    final q = quality.clamp(0, 5);
    final adjustment = 0.1 - (5 - q) * (0.08 + (5 - q) * 0.02);
    return max(_sm2MinEaseFactor, currentEaseFactor + adjustment);
  }

  int _sm2NewInterval(int repetitions, double easeFactor, int currentInterval) {
    if (repetitions == 0) return 1;
    if (repetitions == 1) return 6;
    if (repetitions == 2) return 6;
    return (currentInterval * easeFactor).round().clamp(1, 365);
  }

  Map<String, dynamic> _sm2Schedule(
    int quality,
    double currentEaseFactor,
    int currentInterval,
    int currentRepetitions,
  ) {
    final newEaseFactor = _sm2NewEaseFactor(currentEaseFactor, quality);
    int newRepetitions = currentRepetitions;
    if (quality >= 3) {
      newRepetitions += 1;
    } else {
      newRepetitions = 0;
    }
    final newInterval = _sm2NewInterval(
      newRepetitions,
      newEaseFactor,
      currentInterval,
    );
    final dueAt =
        DateTime.now().add(Duration(days: newInterval)).toIso8601String();
    return {
      'ease_factor': newEaseFactor,
      'interval_days': newInterval,
      'repetitions': newRepetitions,
      'due_at': dueAt,
      'last_review_at': DateTime.now().toIso8601String(),
    };
  }

  Future<void> recordRevisionFeedback(
    int revisionId,
    int confidence,
    String status,
  ) async {
    final item = await getRevisionItem(revisionId);
    if (item == null) return;

    final quality = _confidenceToSm2Quality(confidence);
    final sm2 = _sm2Schedule(
      quality,
      item.easeFactor,
      item.intervalDays,
      item.repetitions,
    );

    final rawDb = await db.database;
    await rawDb.update(
      'revision_items',
      {
        'status': status,
        'recall_confidence': confidence,
        'ease_factor': sm2['ease_factor'],
        'interval_days': sm2['interval_days'],
        'repetitions': sm2['repetitions'],
        'due_at': sm2['due_at'],
        'last_review_at': sm2['last_review_at'],
        'completed_at':
            status == 'completed'
                ? DateTime.now().millisecondsSinceEpoch
                : null,
      },
      where: 'id = ?',
      whereArgs: [revisionId],
    );

    final chapter = await getChapterById(item.chapterId);
    if (chapter != null && status == 'completed') {
      final taskMaps = await db.getTasksByChapter(item.chapterId);
      final activeTasks =
          taskMaps.where((t) => t['status'] != 'completed').toList();
      if (activeTasks.isNotEmpty) {
        for (final t in activeTasks) {
          final task = TaskModel.fromMap(t);
          final originalEstimate =
              task.originalEstimatedMinutes ?? task.estimatedMinutes;
          final ratio = originalEstimate > 0 ? confidence / 100.0 : 0.5;
          final newEstimate = (originalEstimate * ratio).round().clamp(
            1,
            originalEstimate * 3,
          );
          await rawDb.update(
            'study_tasks',
            {
              'estimated_minutes': newEstimate,
              'updated_at': DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [task.id],
          );
        }
      }
    }
  }

  int _confidenceToSm2Quality(int confidence) {
    if (confidence >= 90) return 5;
    if (confidence >= 75) return 4;
    if (confidence >= 60) return 3;
    if (confidence >= 40) return 2;
    if (confidence >= 20) return 1;
    return 0;
  }

  Future<List<RevisionItemModel>> getDueRevisions() async {
    final maps = await db.getDueRevisions();
    return maps.map((m) => RevisionItemModel.fromMap(m)).toList();
  }

  Future<List<RevisionItemModel>> getAllRevisionItems() async {
    final maps = await db.getAllRevisionItems();
    return maps.map(RevisionItemModel.fromMap).toList();
  }

  Future<int> insertRevisionItem(RevisionItemModel item) async {
    final id = await db.insertRevisionItem(item.toMap());
    await _trackChange('revision_items', id.toString(), 'create', item.toMap());
    return id;
  }

  Future<RevisionItemModel?> getRevisionItem(int id) async {
    final maps = await db.query(
      'revision_items',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return RevisionItemModel.fromMap(maps.first);
  }

  Future<int> updateRevisionItem(int id, Map<String, dynamic> data) async {
    final rawDb = await db.database;
    return rawDb.update(
      'revision_items',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getRecallTrends() async {
    final rawDb = await db.database;
    return await rawDb.rawQuery('''
      SELECT
        date(r.created_at) as review_date,
        c.subject_id,
        s.name as subject_name,
        AVG(r.recall_confidence) as avg_confidence,
        COUNT(r.id) as review_count
      FROM revision_items r
      JOIN chapters c ON r.chapter_id = c.id
      JOIN subjects s ON c.subject_id = s.id
      WHERE r.recall_confidence > 0
      GROUP BY date(r.created_at), c.subject_id
      ORDER BY review_date DESC
      LIMIT 90
    ''');
  }

  Future<List<Map<String, dynamic>>> getSubjectConfidenceDecay() async {
    final rawDb = await db.database;
    return await rawDb.rawQuery('''
      SELECT
        c.subject_id,
        s.name as subject_name,
        AVG(r.recall_confidence) as avg_confidence,
        COUNT(r.id) as total_reviews,
        SUM(CASE WHEN r.recall_confidence < 50 THEN 1 ELSE 0 END) as low_confidence_count
      FROM revision_items r
      JOIN chapters c ON r.chapter_id = c.id
      JOIN subjects s ON c.subject_id = s.id
      WHERE r.recall_confidence > 0
      GROUP BY c.subject_id
      ORDER BY avg_confidence ASC
    ''');
  }

  Future<List<Map<String, dynamic>>> getTaskEstimateAccuracy() async {
    final rawDb = await db.database;
    return await rawDb.rawQuery('''
      SELECT
        t.id as task_id,
        t.title as task_title,
        t.estimated_minutes,
        COALESCE(SUM(fs.completed_minutes), 0) as actual_minutes,
        COUNT(fs.id) as session_count
      FROM study_tasks t
      LEFT JOIN focus_sessions fs ON t.id = fs.task_id AND fs.status = 'completed'
      WHERE t.status = 'completed'
      GROUP BY t.id
      ORDER BY t.id DESC
      LIMIT 50
    ''');
  }

  Future<List<Map<String, dynamic>>> getProductiveTimeInsights() async {
    final rawDb = await db.database;
    return await rawDb.rawQuery('''
      SELECT
        strftime('%H', started_at) as hour_of_day,
        COUNT(*) as session_count,
        SUM(completed_minutes) as total_minutes
      FROM focus_sessions
      WHERE status = 'completed'
      GROUP BY hour_of_day
      ORDER BY total_minutes DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getSubjectEstimateAccuracy() async {
    final rawDb = await db.database;
    return await rawDb.rawQuery('''
      SELECT
        s.name as subject_name,
        s.id as subject_id,
        SUM(t.estimated_minutes) as estimated_minutes,
        COALESCE(SUM(fs.completed_minutes), 0) as actual_minutes,
        COUNT(DISTINCT t.id) as task_count
      FROM study_tasks t
      JOIN subjects s ON t.subject_id = s.id
      LEFT JOIN focus_sessions fs ON t.id = fs.task_id AND fs.status = 'completed'
      WHERE t.status = 'completed'
      GROUP BY s.id
      ORDER BY actual_minutes DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getMissedDayPatterns() async {
    final rawDb = await db.database;
    return await rawDb.rawQuery('''
      SELECT
        date(scheduled_at) as plan_date,
        COUNT(*) as planned_count,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as done_count
      FROM study_tasks
      WHERE scheduled_at >= date('now', '-30 days')
      GROUP BY plan_date
      ORDER BY plan_date ASC
    ''');
  }

  Future<UserModel?> getUserProfile() async {
    final map = await db.getUserProfile();
    return map == null ? null : UserModel.fromMap(map);
  }

  Future<int> createUserProfile(UserModel profile) async {
    final id = await db.createUserProfile(profile.toMap());
    await _trackChange(
      'user_profiles',
      id.toString(),
      'create',
      profile.toMap(),
    );
    return id;
  }

  Future<List<SubjectModel>> getSubjects() async {
    final maps = await db.getSubjects();
    if (maps.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final alreadySeeded = prefs.getBool('subjects_seeded') ?? false;
      if (!alreadySeeded) {
        await _seedDefaultSubjects();
        await prefs.setBool('subjects_seeded', true);
      }
      return db.getSubjects().then((m) => m.map(SubjectModel.fromMap).toList());
    }
    return maps.map((m) => SubjectModel.fromMap(m)).toList();
  }

  Future<void> _seedDefaultSubjects() async {
    final templates = await getSyllabusTemplates();
    if (templates.isNotEmpty) {
      final latest = templates.first;
      try {
        final payload = jsonDecode(latest.content) as Map<String, dynamic>;
        for (final s in (payload['subjects'] ?? const [])) {
          await insertSubject(SubjectModel.fromMap(s as Map<String, dynamic>));
        }
        for (final c in (payload['chapters'] ?? const [])) {
          await insertChapter(ChapterModel.fromMap(c as Map<String, dynamic>));
        }
        return;
      } on Exception catch (_) {}
    }
    await Future.wait(
      MatricSubjects.subjects.asMap().entries.map((entry) {
        final e = entry.value;
        return db.insertSubject({
          'name': e['name'] as String,
          'color': e['color'] as int,
          'sort_order': entry.key,
          'created_at': DateTime.now().toIso8601String(),
        });
      }),
    );
  }

  Future<int> insertSubject(SubjectModel subject) async {
    int id;
    if (_useDrift) {
      final db = driftDb!;
      id = await db
          .into(db.subjects)
          .insert(
            SubjectsCompanion.insert(
              name: subject.name,
              color: subject.color,
              sortOrder: subject.sortOrder,
              createdAt: subject.createdAt,
            ),
          );
    } else {
      id = await db.insertSubject(subject.toMap());
    }
    await _trackChange('subjects', id.toString(), 'create', subject.toMap());
    return id;
  }

  Future<int> deleteSubject(int id) async {
    final result = await db.deleteSubject(id);
    await _trackChange('subjects', id.toString(), 'delete', {'id': id});
    return result;
  }

  Future<List<ChapterModel>> getChaptersBySubject(int subjectId) async {
    final maps = await db.getChaptersBySubject(subjectId);
    return maps.map((m) => ChapterModel.fromMap(m)).toList();
  }

  Future<int> insertChapter(ChapterModel chapter) async {
    int id;
    if (_useDrift) {
      final db = driftDb!;
      id = await db
          .into(db.chapters)
          .insert(
            ChaptersCompanion.insert(
              subjectId: chapter.subjectId,
              title: chapter.title,
              createdAt: chapter.createdAt,
              status: Value(chapter.status),
              priority: Value(chapter.priority),
              estimatedMinutes: Value(chapter.estimatedMinutes),
              revisionDates: Value(chapter.revisionDates),
              completedAt: Value(chapter.completedAt),
              examWeight: Value(chapter.examWeight),
              confidence: Value(chapter.confidence),
              contentSource: Value(chapter.contentSource),
              contentVersion: Value(chapter.contentVersion),
              reviewDate: Value(chapter.reviewDate),
              isWeakTopic: Value(
                chapter.confidence != null && chapter.confidence! < 50 ? 1 : 0,
              ),
            ),
          );
    } else {
      id = await db.insertChapter(chapter.toMap());
    }
    await _trackChange('chapters', id.toString(), 'create', chapter.toMap());
    return id;
  }

  Future<int> updateChapterStatus(int id, String status) async {
    final result = await db.updateChapterStatus(
      id,
      status,
      completedAt:
          status == 'completed' ? DateTime.now().millisecondsSinceEpoch : null,
    );
    await _trackChange('chapters', id.toString(), 'update', {'status': status});
    return result;
  }

  Future<void> setChapterCompletion(int chapterId, bool completed) async {
    await db.setChapterCompletion(chapterId, completed);
    await _trackChange('chapters', chapterId.toString(), 'update', {
      'status': completed ? 'completed' : 'in_progress',
    });
  }

  Future<ChapterModel?> getChapterById(int id) async {
    final map = await db.getChapterById(id);
    return map == null ? null : ChapterModel.fromMap(map);
  }

  Future<List<ChapterModel>> getAllChapters() async {
    final maps = await db.getAllChapters();
    return maps.map(ChapterModel.fromMap).toList();
  }

  Future<List<TaskModel>> getTodayTasks() async {
    final maps = await db.getTodayTasks();
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<List<TaskModel>> getAllPendingTasks() async {
    final maps = await db.getAllPendingTasks();
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<List<TaskModel>> getAllTasks() async {
    final maps = await db.getAllTasks();
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<TaskModel?> getTaskById(int id) async {
    final map = await db.getTaskById(id);
    return map == null ? null : TaskModel.fromMap(map);
  }

  Future<int> insertTask(TaskModel task) async {
    int id;
    if (_useDrift) {
      final db = driftDb!;
      id = await db
          .into(db.studyTasks)
          .insert(
            StudyTasksCompanion.insert(
              subjectId: task.subjectId,
              title: task.title,
              scheduledAt: task.scheduledAt,
              estimatedMinutes: task.estimatedMinutes,
              status: task.status,
              createdAt: task.createdAt,
              updatedAt: task.updatedAt,
              chapterId: Value(task.chapterId),
              type: Value(task.type),
              dueAt: Value(task.dueAt),
              completedMinutes: Value(task.completedMinutes),
              priority: Value(task.priority),
              isRescheduled: Value(task.isRescheduled ? 1 : 0),
              isPastPaper: Value(task.isPastPaper ? 1 : 0),
              isTemplate: Value(task.isTemplate ? 1 : 0),
            ),
          );
    } else {
      id = await db.insertTask(task.toMap());
    }
    await _trackChange('study_tasks', id.toString(), 'create', task.toMap());
    return id;
  }

  Future<int> updateTask(int id, Map<String, dynamic> data) async {
    final result = await db.updateTask(id, data);
    await _trackChange('study_tasks', id.toString(), 'update', data);
    return result;
  }

  Future<int> deleteTask(int id) async {
    final result = await db.deleteTask(id);
    await _trackChange('study_tasks', id.toString(), 'delete', {'id': id});
    return result;
  }

  Future<FocusSessionModel?> getActiveFocusSession() async {
    final maps = await db.getActiveFocusSession();
    if (maps.isEmpty) return null;
    return FocusSessionModel.fromMap(maps.first);
  }

  Future<int> insertFocusSession(FocusSessionModel session) async {
    int id;
    if (_useDrift) {
      final db = driftDb!;
      id = await db
          .into(db.focusSessions)
          .insert(
            FocusSessionsCompanion.insert(
              taskId: Value(session.taskId),
              startedAt: session.startedAt,
              plannedMinutes: Value(session.plannedMinutes),
              completedMinutes: Value(session.completedMinutes),
              status: session.status,
              createdAt: session.createdAt,
              endedAt: Value(session.endedAt),
              notes: Value(session.notes),
              reflectionStatus: Value(session.reflectionStatus),
              parkingLotNotes: Value(session.parkingLotNotes),
            ),
          );
    } else {
      id = await db.insertFocusSession(session.toMap());
    }
    await _trackChange(
      'focus_sessions',
      id.toString(),
      'create',
      session.toMap(),
    );
    return id;
  }

  Future<int> updateFocusSession(int id, Map<String, dynamic> data) async {
    final result = await db.updateFocusSession(id, data);
    await _trackChange('focus_sessions', id.toString(), 'update', data);
    return result;
  }

  Future<int> updatePracticalRecord(int id, Map<String, dynamic> data) async {
    final rawDb = await db.database;
    final result = await rawDb.update(
      'practical_records',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
    await _trackChange('practical_records', id.toString(), 'update', data);
    return result;
  }

  Future<int> updateResource(int id, Map<String, dynamic> data) async {
    final result = await db.updateResource(id, data);
    await _trackChange('resources', id.toString(), 'update', data);
    return result;
  }

  Future<int> updateChapter(int id, Map<String, dynamic> data) async {
    int result;
    if (_useDrift) {
      final companion = ChaptersCompanion(
        title: Value(data['title'] as String? ?? ''),
        status: Value(data['status'] as String? ?? 'not_started'),
        priority: Value(data['priority'] as int? ?? 2),
        estimatedMinutes: Value(data['estimatedMinutes'] as int? ?? 30),
        revisionDates: Value(data['revisionDates'] as String? ?? '[]'),
        completedAt: Value(data['completedAt'] as int?),
        examWeight: Value(data['examWeight'] as int?),
        confidence: Value(data['confidence'] as int?),
        contentSource: Value(data['contentSource'] as String?),
        contentVersion: Value(data['contentVersion'] as String?),
        reviewDate: Value(data['reviewDate'] as String?),
        isWeakTopic: Value(data['isWeakTopic'] as int? ?? 0),
        contentTier: Value(data['contentTier'] as String? ?? 'official'),
      );
      result = await (driftDb!.update(driftDb!.chapters)
            ..where((c) => c.id.equals(id))
          )
          .write(companion);
    } else {
      final rawDb = await db.database;
      result = await rawDb.update(
        'chapters',
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    await _trackChange('chapters', id.toString(), 'update', data);
    return result;
  }

  Future<List<ResourceModel>> getResourcesBySubject(int subjectId) async {
    final maps = await db.getResourcesBySubject(subjectId);
    return maps.map((m) => ResourceModel.fromMap(m)).toList();
  }

  Future<List<ResourceModel>> getAllResources() async {
    final maps = await db.getAllResources();
    return maps.map((m) => ResourceModel.fromMap(m)).toList();
  }

  Future<int> insertResource(ResourceModel resource) async {
    final id = await db.insertResource(resource.toMap());
    await _trackChange('resources', id.toString(), 'create', resource.toMap());
    return id;
  }

  Future<List<PracticalRecordModel>> getPracticalRecordsBySubject(
    int subjectId,
  ) async {
    final maps = await db.getPracticalRecordsBySubject(subjectId);
    return maps.map((m) => PracticalRecordModel.fromMap(m)).toList();
  }

  Future<List<PracticalRecordModel>> getAllPracticalRecords() async {
    final maps = await db.getAllPracticalRecords();
    return maps.map((m) => PracticalRecordModel.fromMap(m)).toList();
  }

  Future<int> insertPracticalRecord(PracticalRecordModel record) async {
    final id = await db.insertPracticalRecord(record.toMap());
    await _trackChange(
      'practical_records',
      id.toString(),
      'create',
      record.toMap(),
    );
    return id;
  }

  Future<int> updatePracticalStatus(int id, String status) async {
    final result = await db.updatePracticalStatus(id, status);
    await _trackChange('practical_records', id.toString(), 'update', {
      'status': status,
    });
    return result;
  }

  Future<List<FocusSessionModel>> getFocusSessions() async {
    final maps = await db.getFocusSessions();
    return maps.map((m) => FocusSessionModel.fromMap(m)).toList();
  }

  Future<List<Map<String, dynamic>>> getBackupHistory() =>
      db.getBackupHistory();

  Future<List<Map<String, dynamic>>> getRevisionItemsByChapterAndInterval(
    int chapterId,
    int intervalDays,
  ) => db.getRevisionItemsByChapterAndInterval(chapterId, intervalDays);

  Future<int> deleteRevisionItemsByChapter(int chapterId) async {
    final result = await db.deleteRevisionItemsByChapter(chapterId);
    await _trackChange('revision_items', chapterId.toString(), 'delete', {
      'chapterId': chapterId,
    });
    return result;
  }

  Future<List<TaskModel>> getTasksByChapter(int chapterId) async {
    final maps = await db.getTasksByChapter(chapterId);
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<int> getTotalCompletedFocusMinutesForIncompleteChapters() async {
    return await db.getTotalCompletedFocusMinutesForIncompleteChapters();
  }

  Future<List<ChapterWithSubjectModel>> getAllChaptersWithSubject() async {
    final maps = await db.getAllChaptersWithSubject();
    return maps.map((m) => ChapterWithSubjectModel.fromMap(m)).toList();
  }

  Future<int> getTotalCompletedMinutesForChapter(int chapterId) async {
    final taskMaps = await db.getTasksByChapter(chapterId);
    final taskIds = taskMaps.map((m) => m['id'] as int).toList();
    if (taskIds.isEmpty) return 0;
    final rawDb = await db.database;
    final placeholders = List.filled(taskIds.length, '?').join(',');
    final result = await rawDb.rawQuery(
      'SELECT COALESCE(SUM(completed_minutes), 0) as total FROM focus_sessions WHERE task_id IN ($placeholders)',
      taskIds,
    );
    return result.first['total'] as int;
  }

  Future<List<TaskModel>> getTasksForDate(DateTime date) async {
    final maps = await db.getTasksForDate(date);
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<List<TaskModel>> getTasksForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final maps = await db.getTasksForDateRange(startDate, endDate);
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<List<SubjectProgressModel>> getSubjectProgress() async {
    final maps = await db.getSubjectProgress();
    return maps.map((m) => SubjectProgressModel.fromMap(m)).toList();
  }

  Future<int> updateUserProfile(UserModel profile) async {
    final result = await db.updateUserProfile(profile.toMap(), profile.id!);
    await _trackChange(
      'user_profiles',
      profile.id.toString(),
      'update',
      profile.toMap(),
    );
    return result;
  }

  Future<int> insertBackupRecord(String destination, String status) async {
    final id = await db.insertBackupRecord({
      'created_at': DateTime.now().toIso8601String(),
      'destination': destination,
      'status': status,
    });
    await _trackChange('backup_records', id.toString(), 'create', {
      'destination': destination,
      'status': status,
    });
    return id;
  }

  Future<List<dynamic>> search(String query) async {
    final lower = query.toLowerCase();
    final rawDb = await db.database;
    final taskRows = await rawDb.query(
      'study_tasks',
      where: 'LOWER(title) LIKE ?',
      whereArgs: ['%$lower%'],
    );
    final subjectRows = await rawDb.query(
      'subjects',
      where: 'LOWER(name) LIKE ?',
      whereArgs: ['%$lower%'],
    );
    final chapterRows = await rawDb.query(
      'chapters',
      where: 'LOWER(title) LIKE ?',
      whereArgs: ['%$lower%'],
    );
    final resourceRows = await rawDb.query(
      'resources',
      where: 'LOWER(title) LIKE ?',
      whereArgs: ['%$lower%'],
    );
    final practicalRows = await rawDb.query(
      'practical_records',
      where: 'LOWER(title) LIKE ?',
      whereArgs: ['%$lower%'],
    );
    return [
      ...taskRows.map((m) => TaskModel.fromMap(m)),
      ...subjectRows.map((m) => SubjectModel.fromMap(m)),
      ...chapterRows.map((m) => ChapterModel.fromMap(m)),
      ...resourceRows.map((m) => ResourceModel.fromMap(m)),
      ...practicalRows.map((m) => PracticalRecordModel.fromMap(m)),
    ];
  }

  int computeTaskScore(TaskModel task, int dailyMinutes) {
    final now = DateTime.now();
    var score = 0;
    if (task.dueAt != null) {
      final diff = DateTime.parse(task.dueAt!).difference(now).inDays;
      score += diff < 0 ? 50 : (30 - diff.clamp(0, 30));
    }
    score += task.priority * 10;
    if (task.estimatedMinutes <= dailyMinutes) score += 5;
    return score;
  }

  Future<List<TaskModel>> getPastPaperTasks() async {
    final maps = await db.query(
      'study_tasks',
      where: 'is_past_paper = ?',
      whereArgs: [1],
    );
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<List<TaskModel>> getTaskTemplates() async {
    final maps = await db.query(
      'study_tasks',
      where: 'is_template = ?',
      whereArgs: [1],
    );
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<List<ChapterModel>> getWeakTopics() async {
    final maps = await db.query(
      'chapters',
      where: 'is_weak_topic = ?',
      whereArgs: [1],
    );
    return maps.map((m) => ChapterModel.fromMap(m)).toList();
  }

  Future<int> toggleWeakTopic(int chapterId, bool weak) async {
    final rawDb = await db.database;
    final result = await rawDb.update(
      'chapters',
      {'is_weak_topic': weak ? 1 : 0},
      where: 'id = ?',
      whereArgs: [chapterId],
    );
    await _trackChange('chapters', chapterId.toString(), 'update', {
      'is_weak_topic': weak ? 1 : 0,
    });
    return result;
  }

  Future<int> insertSyllabusTemplate(SyllabusTemplateModel template) async {
    if (_useDrift) {
      // Drift not used for syllabus_templates yet; fall through to SQLite
    }
    final id = await db.insertSyllabusTemplate(template.toMap());
    await _trackChange(
      'syllabus_templates',
      id.toString(),
      'create',
      template.toMap(),
    );
    return id;
  }

  Future<List<SyllabusTemplateModel>> getSyllabusTemplates() async {
    final maps = await db.getSyllabusTemplates();
    return maps.map(SyllabusTemplateModel.fromMap).toList();
  }

  Future<int> deleteSyllabusTemplate(int id) async {
    final result = await db.deleteSyllabusTemplate(id);
    await _trackChange('syllabus_templates', id.toString(), 'delete', {
      'id': id,
    });
    return result;
  }

  String exportAnkiCsv(
    List<SubjectModel> subjects,
    List<ChapterModel> chapters,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('Front,Back,Tags');
    for (final subject in subjects) {
      final subjectChapters =
          chapters.where((c) => c.subjectId == subject.id).toList();
      for (final chapter in subjectChapters) {
        final front = chapter.title.replaceAll(',', '，');
        final back = subject.name;
        final tags =
            'matric,${subject.name.replaceAll(',', '，')},${chapter.title.replaceAll(',', '，')}';
        buffer.writeln('"$front","$back","$tags"');
      }
    }
    return buffer.toString();
  }

  List<Map<String, dynamic>> importAnkiCsv(String csvContent, int subjectId) {
    final lines = csvContent.split('\n');
    final resources = <Map<String, dynamic>>[];
    if (lines.isEmpty) return resources;
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final parts = _parseAnkiCsvLine(line);
      if (parts.length >= 2) {
        resources.add({
          'subject_id': subjectId,
          'type': 'flashcard',
          'title': parts[0],
          'local_path': '',
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    }
    return resources;
  }

  List<String> _parseAnkiCsvLine(String line) {
    final result = <String>[];
    var current = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString());
        current = StringBuffer();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString());
    return result;
  }

  Future<void> _trackChange(
    String entity,
    String localId,
    String operation,
    Map<String, dynamic> data,
  ) async {
    final now = DateTime.now().toIso8601String();
    final rawDb = await db.database;
    await rawDb.insert(
      'sync_meta',
      {
        'entity': entity,
        'local_id': localId,
        'sync_status': 'pending',
        'conflict_data': null,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getConflicts() async {
    final rawDb = await db.database;
    final rows = await rawDb.query(
      'sync_meta',
      where: 'conflict_data IS NOT NULL',
      orderBy: 'updated_at DESC',
    );
    return rows;
  }

  Future<int> clearConflict(String entity, String localId) async {
    final rawDb = await db.database;
    return await rawDb.update(
      'sync_meta',
      {
        'conflict_data': null,
        'sync_status': 'pending',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'entity = ? AND local_id = ?',
      whereArgs: [entity, localId],
    );
  }

  Future<int> markEntityConflict(
    String entity,
    String localId,
    Map<String, dynamic> conflictData,
  ) async {
    final now = DateTime.now().toIso8601String();
    final rawDb = await db.database;
    final encoded = jsonEncode(conflictData);
    await rawDb.insert(
      'sync_meta',
      {
        'entity': entity,
        'local_id': localId,
        'sync_status': 'conflict',
        'conflict_data': encoded,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return 1;
  }
}