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

import 'package:drift/drift.dart';

part 'app_database.g.dart';

class UserProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get studentName => text()();
  TextColumn get studentId => text()();
  TextColumn get institution => text()();
  TextColumn get classLevel => text()();
  TextColumn get board => text()();
  TextColumn get examDate => text()();
  IntColumn get dailyStudyMinutes =>
      integer().withDefault(const Constant(120))();
  TextColumn get theme => text().withDefault(const Constant('light'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
}

class Subjects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get color => integer()();
  IntColumn get sortOrder => integer()();
  TextColumn get createdAt => text()();
}

class Chapters extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get subjectId => integer().references(Subjects, #id)();
  TextColumn get title => text()();
  TextColumn get status => text().withDefault(const Constant('not_started'))();
  IntColumn get priority => integer().withDefault(const Constant(2))();
  IntColumn get estimatedMinutes => integer().withDefault(const Constant(30))();
  TextColumn get revisionDates => text().withDefault(const Constant('[]'))();
  IntColumn? get completedAt => integer().nullable()();
  TextColumn get createdAt => text()();
  IntColumn? get examWeight => integer().nullable()();
  IntColumn? get confidence => integer().nullable()();
  TextColumn? get contentSource => text().nullable()();
  TextColumn? get contentVersion => text().nullable()();
  TextColumn? get reviewDate => text().nullable()();
  IntColumn get isWeakTopic => integer().withDefault(const Constant(0))();
  TextColumn get contentTier =>
      text().withDefault(const Constant('official'))();
}

class StudyTasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get subjectId => integer().references(Subjects, #id)();
  IntColumn? get chapterId => integer().nullable().references(Chapters, #id)();
  TextColumn get title => text()();
  TextColumn get type => text().withDefault(const Constant('custom'))();
  TextColumn? get dueAt => text().nullable()();
  TextColumn get scheduledAt => text()();
  IntColumn get estimatedMinutes => integer()();
  IntColumn get completedMinutes => integer().withDefault(const Constant(0))();
  IntColumn get priority => integer().withDefault(const Constant(2))();
  TextColumn get status => text()();
  IntColumn get isRescheduled => integer().withDefault(const Constant(0))();
  IntColumn get isPastPaper => integer().withDefault(const Constant(0))();
  IntColumn get isTemplate => integer().withDefault(const Constant(0))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn? get originalEstimatedMinutes => integer().nullable()();
}

class FocusSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn? get taskId => integer().nullable().references(StudyTasks, #id)();
  TextColumn get startedAt => text()();
  TextColumn? get endedAt => text().nullable()();
  IntColumn get plannedMinutes => integer().withDefault(const Constant(25))();
  IntColumn get completedMinutes => integer().withDefault(const Constant(0))();
  TextColumn get status => text()();
  TextColumn get createdAt => text()();
  TextColumn? get notes => text().nullable()();
  TextColumn? get reflectionStatus => text().nullable()();
  TextColumn? get parkingLotNotes => text().nullable()();
}

class RevisionItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get chapterId => integer().references(Chapters, #id)();
  TextColumn get dueAt => text()();
  IntColumn get intervalDays => integer()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn? get completedAt => integer().nullable()();
  TextColumn get createdAt => text()();
  IntColumn get recallConfidence => integer().withDefault(const Constant(0))();
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  TextColumn? get lastReviewAt => text().nullable()();
}

class Resources extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get subjectId => integer().references(Subjects, #id)();
  IntColumn? get chapterId => integer().nullable().references(Chapters, #id)();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get localPath => text()();
  TextColumn get createdAt => text()();
  IntColumn? get fileSize => integer().nullable()();
  IntColumn get isPinned => integer().withDefault(const Constant(0))();
  TextColumn? get tags => text().nullable()();
  TextColumn? get folder => text().nullable()();
  IntColumn? get taskId => integer().nullable()();
  IntColumn? get practicalId => integer().nullable()();
}

class PracticalRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get subjectId => integer().references(Subjects, #id)();
  TextColumn get title => text()();
  TextColumn? get dueAt => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn? get resourceId => integer().nullable()();
  TextColumn get createdAt => text()();
  TextColumn? get objective => text().nullable()();
  TextColumn? get apparatus => text().nullable()();
  TextColumn? get procedure => text().nullable()();
  TextColumn? get observation => text().nullable()();
  TextColumn? get vivaQuestions => text().nullable()();
}

class BackupRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get createdAt => text()();
  TextColumn get destination => text()();
  TextColumn get status => text()();
}

class SyllabusTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get templateVersion =>
      integer().withDefault(const Constant(1))();
  TextColumn get exportedAt => text()();
  TextColumn? get sourceApp => text().nullable()();
  TextColumn? get sourceAttribution => text().nullable()();
  TextColumn? get importedAt => text().nullable()();
  TextColumn get content => text()();
  TextColumn get contentTier =>
      text().withDefault(const Constant('official'))();
}

class SyncMeta extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entity => text()();
  TextColumn get localId => text()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();
  TextColumn? get lastSyncedAt => text().nullable()();
  TextColumn? get remoteVersion => text().nullable()();
  TextColumn? get conflictData => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
}

@DriftDatabase(
  tables: [
    UserProfiles,
    Subjects,
    Chapters,
    StudyTasks,
    FocusSessions,
    RevisionItems,
    Resources,
    PracticalRecords,
    BackupRecords,
    SyllabusTemplates,
    SyncMeta,
  ],
)
class AppDatabase extends _$AppDatabase {
  // ignore: use_super_parameters
  AppDatabase(QueryExecutor db) : super(db);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Future schema migrations are applied here.
        // Keep this block so Drift's migration framework triggers correctly
        // on existing databases after schemaVersion increments.
      }
      if (from < 3) {
        await m.addColumn(resources, resources.folder);
        await m.addColumn(resources, resources.taskId);
        await m.addColumn(resources, resources.practicalId);
        await m.createTable(syllabusTemplates);
        await m.createTable(syncMeta);
      }
    },
  );
}
