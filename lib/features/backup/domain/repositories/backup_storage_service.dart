abstract class BackupStorageService {
  Future<String> getBackupDirectory();
  Future<String> generateBackupFilePath();
  Future<void> deleteOldBackups(int keepCount);
}
