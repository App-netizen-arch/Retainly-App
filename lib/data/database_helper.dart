// Copyright 2026 CodeSym
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static Future<Database>? _databaseOpening;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _databaseOpening ??= _initDB('study_planner.db');
    _database = await _databaseOpening!;
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);
    final db = await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async => _extendSchema(db),
    );
    return db;
  }

  Future<void> _extendSchema(Database db) async {
    await db.transaction((txn) async {
      final profileColumns = await txn.rawQuery(
        "PRAGMA table_info(user_profiles)",
      );
      final profileNames =
          profileColumns.map((c) => c['name'] as String).toList();
      if (!profileNames.contains('student_name')) {
        await txn.execute(
          "ALTER TABLE user_profiles ADD COLUMN student_name TEXT NOT NULL DEFAULT ''",
        );
      }
      if (!profileNames.contains('student_id')) {
        await txn.execute(
          "ALTER TABLE user_profiles ADD COLUMN student_id TEXT NOT NULL DEFAULT ''",
        );
      }
      if (!profileNames.contains('institution')) {
        await txn.execute(
          "ALTER TABLE user_profiles ADD COLUMN institution TEXT NOT NULL DEFAULT ''",
        );
      }

      final columns = await txn.rawQuery("PRAGMA table_info(focus_sessions)");
      final names = columns.map((c) => c['name'] as String).toList();
      if (!names.contains('notes')) {
        await txn.execute("ALTER TABLE focus_sessions ADD COLUMN notes TEXT");
      }
      if (!names.contains('reflection_status')) {
        await txn.execute(
          "ALTER TABLE focus_sessions ADD COLUMN reflection_status TEXT",
        );
      }
      if (!names.contains('parking_lot_notes')) {
        await txn.execute(
          "ALTER TABLE focus_sessions ADD COLUMN parking_lot_notes TEXT",
        );
      }

      final practicalColumns = await txn.rawQuery(
        "PRAGMA table_info(practical_records)",
      );
      final practicalNames =
          practicalColumns.map((c) => c['name'] as String).toList();
      if (!practicalNames.contains('objective')) {
        await txn.execute(
          "ALTER TABLE practical_records ADD COLUMN objective TEXT",
        );
      }
      if (!practicalNames.contains('apparatus')) {
        await txn.execute(
          "ALTER TABLE practical_records ADD COLUMN apparatus TEXT",
        );
      }
      if (!practicalNames.contains('procedure')) {
        await txn.execute(
          "ALTER TABLE practical_records ADD COLUMN procedure TEXT",
        );
      }
      if (!practicalNames.contains('observation')) {
        await txn.execute(
          "ALTER TABLE practical_records ADD COLUMN observation TEXT",
        );
      }
      if (!practicalNames.contains('viva_questions')) {
        await txn.execute(
          "ALTER TABLE practical_records ADD COLUMN viva_questions TEXT",
        );
      }

      final resourceColumns = await txn.rawQuery(
        "PRAGMA table_info(resources)",
      );
      final resourceNames =
          resourceColumns.map((c) => c['name'] as String).toList();
      if (!resourceNames.contains('file_size')) {
        await txn.execute("ALTER TABLE resources ADD COLUMN file_size INTEGER");
      }
      if (!resourceNames.contains('is_pinned')) {
        await txn.execute(
          "ALTER TABLE resources ADD COLUMN is_pinned INTEGER NOT NULL DEFAULT 0",
        );
      }
      if (!resourceNames.contains('tags')) {
        await txn.execute("ALTER TABLE resources ADD COLUMN tags TEXT");
      }
      if (!resourceNames.contains('folder')) {
        await txn.execute("ALTER TABLE resources ADD COLUMN folder TEXT");
      }
      if (!resourceNames.contains('chapter_id')) {
        await txn.execute(
          "ALTER TABLE resources ADD COLUMN chapter_id INTEGER",
        );
      }
      if (!resourceNames.contains('task_id')) {
        await txn.execute("ALTER TABLE resources ADD COLUMN task_id INTEGER");
      }
      if (!resourceNames.contains('practical_id')) {
        await txn.execute(
          "ALTER TABLE resources ADD COLUMN practical_id INTEGER",
        );
      }

      final chapterColumns = await txn.rawQuery("PRAGMA table_info(chapters)");
      final chapterNames =
          chapterColumns.map((c) => c['name'] as String).toList();
      if (!chapterNames.contains('exam_weight')) {
        await txn.execute(
          "ALTER TABLE chapters ADD COLUMN exam_weight INTEGER",
        );
      }
      if (!chapterNames.contains('confidence')) {
        await txn.execute("ALTER TABLE chapters ADD COLUMN confidence INTEGER");
      }
      if (!chapterNames.contains('content_source')) {
        await txn.execute(
          "ALTER TABLE chapters ADD COLUMN content_source TEXT",
        );
      }
      if (!chapterNames.contains('content_version')) {
        await txn.execute(
          "ALTER TABLE chapters ADD COLUMN content_version TEXT",
        );
      }
      if (!chapterNames.contains('review_date')) {
        await txn.execute("ALTER TABLE chapters ADD COLUMN review_date TEXT");
      }
      if (!chapterNames.contains('is_weak_topic')) {
        await txn.execute(
          "ALTER TABLE chapters ADD COLUMN is_weak_topic INTEGER NOT NULL DEFAULT 0",
        );
      }
      if (!chapterNames.contains('content_tier')) {
        await txn.execute(
          "ALTER TABLE chapters ADD COLUMN content_tier TEXT NOT NULL DEFAULT 'official'",
        );
      }

      final taskColumns = await txn.rawQuery("PRAGMA table_info(study_tasks)");
      final taskNames = taskColumns.map((c) => c['name'] as String).toList();
      if (!taskNames.contains('is_past_paper')) {
        await txn.execute(
          "ALTER TABLE study_tasks ADD COLUMN is_past_paper INTEGER NOT NULL DEFAULT 0",
        );
      }
      if (!taskNames.contains('is_template')) {
        await txn.execute(
          "ALTER TABLE study_tasks ADD COLUMN is_template INTEGER NOT NULL DEFAULT 0",
        );
      }
      if (!taskNames.contains('original_estimated_minutes')) {
        await txn.execute(
          "ALTER TABLE study_tasks ADD COLUMN original_estimated_minutes INTEGER",
        );
      }

      final revisionColumns = await txn.rawQuery(
        "PRAGMA table_info(revision_items)",
      );
      final revisionNames =
          revisionColumns.map((c) => c['name'] as String).toList();
      if (!revisionNames.contains('recall_confidence')) {
        await txn.execute(
          "ALTER TABLE revision_items ADD COLUMN recall_confidence INTEGER NOT NULL DEFAULT 0",
        );
      }
      if (!revisionNames.contains('ease_factor')) {
        await txn.execute(
          "ALTER TABLE revision_items ADD COLUMN ease_factor REAL NOT NULL DEFAULT 2.5",
        );
      }
      if (!revisionNames.contains('repetitions')) {
        await txn.execute(
          "ALTER TABLE revision_items ADD COLUMN repetitions INTEGER NOT NULL DEFAULT 0",
        );
      }
      if (!revisionNames.contains('last_review_at')) {
        await txn.execute(
          "ALTER TABLE revision_items ADD COLUMN last_review_at TEXT",
        );
      }
    });
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profiles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_name TEXT NOT NULL,
        student_id TEXT NOT NULL,
        institution TEXT NOT NULL,
        class_level TEXT NOT NULL,
        board TEXT NOT NULL,
        exam_date TEXT NOT NULL,
        daily_study_minutes INTEGER NOT NULL DEFAULT 120,
        theme TEXT NOT NULL DEFAULT 'light',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE subjects(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        sort_order INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE chapters(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        status TEXT NOT NULL,
        priority INTEGER NOT NULL DEFAULT 2,
        estimated_minutes INTEGER NOT NULL DEFAULT 30,
        revision_dates TEXT NOT NULL DEFAULT '[]',
        completed_at INTEGER,
        created_at TEXT NOT NULL,
        FOREIGN KEY(subject_id) REFERENCES subjects(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE study_tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        chapter_id INTEGER,
        title TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'custom',
        due_at TEXT,
        scheduled_at TEXT NOT NULL,
        estimated_minutes INTEGER NOT NULL,
        completed_minutes INTEGER NOT NULL DEFAULT 0,
        priority INTEGER NOT NULL DEFAULT 2,
        status TEXT NOT NULL,
        is_rescheduled INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
        FOREIGN KEY(chapter_id) REFERENCES chapters(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE focus_sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER,
        started_at TEXT NOT NULL,
        ended_at TEXT,
        planned_minutes INTEGER NOT NULL,
        completed_minutes INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY(task_id) REFERENCES study_tasks(id) ON DELETE SET NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE revision_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chapter_id INTEGER NOT NULL,
        due_at TEXT NOT NULL,
        interval_days INTEGER NOT NULL,
        status TEXT NOT NULL,
        completed_at INTEGER,
        created_at TEXT NOT NULL,
        FOREIGN KEY(chapter_id) REFERENCES chapters(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE resources(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        chapter_id INTEGER,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        local_path TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY(subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
        FOREIGN KEY(chapter_id) REFERENCES chapters(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE practical_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        due_at TEXT,
        status TEXT NOT NULL,
        resource_id INTEGER,
        created_at TEXT NOT NULL,
        FOREIGN KEY(subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
        FOREIGN KEY(resource_id) REFERENCES resources(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE backup_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at TEXT NOT NULL,
        destination TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE syllabus_templates(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        template_version INTEGER NOT NULL DEFAULT 1,
        exported_at TEXT NOT NULL,
        source_app TEXT,
        source_attribution TEXT,
        imported_at TEXT,
        content TEXT NOT NULL,
        content_tier TEXT NOT NULL DEFAULT 'official'
      )
    ''');
  }

  Future<int> createUserProfile(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('user_profiles', data);
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final db = await instance.database;
    final result = await db.query('user_profiles', limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> insertSubject(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('subjects', data);
  }

  Future<List<Map<String, dynamic>>> getSubjects() async {
    final db = await instance.database;
    return await db.query('subjects', orderBy: 'sort_order ASC');
  }

  Future<int> deleteSubject(int id) async {
    final db = await instance.database;
    return await db.delete('subjects', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertChapter(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('chapters', data);
  }

  Future<List<Map<String, dynamic>>> getChaptersBySubject(int subjectId) async {
    final db = await instance.database;
    return await db.query(
      'chapters',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'id ASC',
    );
  }

  Future<Map<String, dynamic>?> getChapterById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'chapters',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isEmpty ? null : result.first;
  }

  Future<List<Map<String, dynamic>>> getAllChapters() async {
    final db = await instance.database;
    return db.query('chapters', orderBy: 'id ASC');
  }

  Future<int> updateChapterStatus(
    int id,
    String status, {
    int? completedAt,
  }) async {
    final db = await instance.database;
    final data = <String, dynamic>{'status': status};
    if (completedAt != null) data['completed_at'] = completedAt;
    return await db.update('chapters', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setChapterCompletion(int chapterId, bool completed) async {
    final db = await instance.database;
    final now = DateTime.now();
    await db.update(
      'chapters',
      {
        'status': completed ? 'completed' : 'in_progress',
        'completed_at': completed ? now.millisecondsSinceEpoch : null,
      },
      where: 'id = ?',
      whereArgs: [chapterId],
    );
  }

  Future<int> insertTask(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('study_tasks', data);
  }

  Future<List<Map<String, dynamic>>> getTodayTasks() async {
    final db = await instance.database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return await db.query(
      'study_tasks',
      where: 'date(scheduled_at) >= date(?) AND date(scheduled_at) < date(?) AND status != ?',
      whereArgs: [
        today.toIso8601String(),
        tomorrow.toIso8601String(),
        'completed',
      ],
      orderBy: 'priority DESC, due_at ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllPendingTasks() async {
    final db = await instance.database;
    return await db.query(
      'study_tasks',
      where: 'status != ?',
      whereArgs: ['completed'],
      orderBy: 'priority DESC, due_at ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    final db = await instance.database;
    return db.query('study_tasks', orderBy: 'id ASC');
  }

  Future<List<Map<String, dynamic>>> getTasksForDate(DateTime date) async {
    final db = await instance.database;
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(start.year, start.month, start.day + 1);
    return await db.query(
      'study_tasks',
      where: 'scheduled_at >= ? AND scheduled_at < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'priority DESC, due_at ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getTasksForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await instance.database;
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day + 1);
    return await db.query(
      'study_tasks',
      where: 'scheduled_at >= ? AND scheduled_at < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'priority DESC, due_at ASC',
    );
  }

  Future<Map<String, dynamic>?> getTaskById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'study_tasks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getTasksByChapter(int chapterId) async {
    final db = await instance.database;
    return await db.query(
      'study_tasks',
      where: 'chapter_id = ?',
      whereArgs: [chapterId],
    );
  }

  Future<int> updateTask(int id, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.update(
      'study_tasks',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete('study_tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertFocusSession(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('focus_sessions', data);
  }

  Future<int> updateFocusSession(int id, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.update(
      'focus_sessions',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getActiveFocusSession() async {
    final db = await instance.database;
    return await db.query(
      'focus_sessions',
      where: 'status = ?',
      whereArgs: ['running'],
      limit: 1,
    );
  }

  Future<List<Map<String, dynamic>>> getFocusSessions() async {
    final db = await instance.database;
    return await db.query('focus_sessions');
  }

  Future<int> insertRevisionItem(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('revision_items', data);
  }

  Future<List<Map<String, dynamic>>> getDueRevisions() async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();
    return await db.query(
      'revision_items',
      where: 'due_at <= ?',
      whereArgs: [now],
      orderBy: 'due_at ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllRevisionItems() async {
    final db = await instance.database;
    return db.query('revision_items', orderBy: 'id ASC');
  }

  Future<List<Map<String, dynamic>>> getRevisionItemsByChapterAndInterval(
    int chapterId,
    int intervalDays,
  ) async {
    final db = await instance.database;
    return await db.query(
      'revision_items',
      where: 'chapter_id = ? AND interval_days = ? AND status != ?',
      whereArgs: [chapterId, intervalDays, 'completed'],
    );
  }

  Future<int> deleteRevisionItemsByChapter(int chapterId) async {
    final db = await instance.database;
    return await db.delete(
      'revision_items',
      where: 'chapter_id = ?',
      whereArgs: [chapterId],
    );
  }

  Future<int> insertResource(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('resources', data);
  }

  Future<List<Map<String, dynamic>>> getResourcesBySubject(
    int subjectId,
  ) async {
    final db = await instance.database;
    return await db.query(
      'resources',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllResources() async {
    final db = await instance.database;
    return await db.query('resources');
  }

  Future<int> updateResource(int id, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.update('resources', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertPracticalRecord(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('practical_records', data);
  }

  Future<List<Map<String, dynamic>>> getPracticalRecordsBySubject(
    int subjectId,
  ) async {
    final db = await instance.database;
    return await db.query(
      'practical_records',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllPracticalRecords() async {
    final db = await instance.database;
    return await db.query('practical_records');
  }

  Future<int> updatePracticalStatus(int id, String status) async {
    final db = await instance.database;
    return await db.update(
      'practical_records',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateChapter(int id, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.update('chapters', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> recordBackup(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('backup_records', data);
  }

  Future<List<Map<String, dynamic>>> getBackupHistory() async {
    final db = await instance.database;
    return await db.query('backup_records', orderBy: 'created_at DESC');
  }

  Future<int> insertBackupRecord(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('backup_records', data);
  }

  Future<int> insertSyllabusTemplate(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('syllabus_templates', data);
  }

  Future<List<Map<String, dynamic>>> getSyllabusTemplates() async {
    final db = await instance.database;
    return await db.query('syllabus_templates', orderBy: 'imported_at DESC');
  }

  Future<int> deleteSyllabusTemplate(int id) async {
    final db = await instance.database;
    return await db.delete(
      'syllabus_templates',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getSubjectProgress() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT subjects.id, subjects.name, subjects.color, subjects.sort_order,
             COUNT(chapters.id) as total_chapters,
             SUM(CASE WHEN chapters.status = 'completed' THEN 1 ELSE 0 END) as completed_chapters
      FROM subjects
      LEFT JOIN chapters ON subjects.id = chapters.subject_id
      GROUP BY subjects.id
      ORDER BY subjects.sort_order ASC
    ''');
  }

  Future<List<Map<String, dynamic>>> getAllChaptersWithSubject() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT chapters.*, subjects.name as subject_name
      FROM chapters
      JOIN subjects ON chapters.subject_id = subjects.id
      ORDER BY chapters.id ASC
    ''');
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    int? limit,
  }) async {
    final db = await instance.database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      limit: limit,
    );
  }

  Future<int> getTotalCompletedFocusMinutesForIncompleteChapters() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(fs.completed_minutes), 0) as total
      FROM focus_sessions fs
      JOIN study_tasks st ON fs.task_id = st.id
      JOIN chapters c ON st.chapter_id = c.id
      WHERE c.status != 'completed'
    ''');
    return result.first['total'] as int;
  }

  Future<int> updateUserProfile(Map<String, dynamic> data, int id) async {
    final db = await instance.database;
    return await db.update(
      'user_profiles',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
