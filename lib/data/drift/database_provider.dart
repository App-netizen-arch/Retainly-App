import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'app_database.dart';

class DatabaseProvider {
  static final DatabaseProvider instance = DatabaseProvider._init();
  static AppDatabase? _driftDb;

  DatabaseProvider._init();

  static Future<void> initialize() async {
    if (_driftDb != null) return;
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      final docsDir = await getApplicationDocumentsDirectory();
      final path = p.join(docsDir.path, 'study_planner_drift.db');
      _driftDb = AppDatabase(
        LazyDatabase(() async {
          return NativeDatabase.createInBackground(File(path));
        }),
      );
    } else {
      _driftDb = null;
    }
  }

  static AppDatabase? get driftDb => _driftDb;
  static bool get isDriftAvailable => _driftDb != null;
}
