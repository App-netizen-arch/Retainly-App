abstract class BackupStorageService {
  Future<String> getBackupDirectory();
  Future<String> generateBackupFilePath();
  Future<int> getAvailableStorageBytes();
  Future<void> deleteOldBackups(int keepCount);
}
