import '../models/backup_models.dart';

abstract class BackupScheduler {
  Future<void> initialize();
  Future<BackupFrequency> getFrequency();
  Future<void> setFrequency(BackupFrequency frequency);
  Future<bool> isAutoBackupEnabled();
  Future<void> setAutoBackupEnabled(bool enabled);
  Future<DateTime?> getLastBackupTime();
  Future<void> recordBackup(String path);
  Future<String?> getLastBackupPath();
  Future<bool> isBackupDue();
  Future<void> checkAndNotify();
  Future<void> cancelScheduledNotifications();
}
