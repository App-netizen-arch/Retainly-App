import '../models/backup_models.dart';

abstract class RestoreService {
  Future<RestoreResult> restoreFromFile(String path, {bool overwrite = true});
  Future<RestoreConflict?> validateBackup(String path);
  Future<List<String>> getBackupTables(String path);
}
