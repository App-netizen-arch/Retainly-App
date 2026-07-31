import '../models/backup_models.dart';

abstract class BackupRepository {
  Future<BackupRecord?> createBackup();
  Future<List<BackupRecord>> getBackupHistory();
  Future<bool> deleteBackup(String id);
  Future<String?> exportBackupFile(String id);
  Future<String?> importBackupFile(String path);
}
