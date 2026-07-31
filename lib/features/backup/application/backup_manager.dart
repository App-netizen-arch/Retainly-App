import '../domain/models/backup_models.dart';
import '../domain/repositories/backup_repository.dart';
import '../domain/repositories/backup_scheduler.dart';
import '../domain/repositories/backup_encryption_service.dart';
import '../domain/repositories/backup_storage_service.dart';
import '../domain/repositories/restore_service.dart';
import '../data/repositories/local_backup_repository.dart';
import '../data/repositories/local_backup_scheduler.dart';
import '../data/repositories/backup_encryption_service.dart';
import '../data/repositories/backup_storage_service.dart';
import '../data/repositories/local_restore_service.dart';
import '../../../data/repositories/database_repository.dart';
import '../../../data/database_helper.dart';

class BackupManager {
  final BackupRepository repository;
  final BackupScheduler scheduler;
  final BackupEncryptionService encryptionService;
  final BackupStorageService storageService;
  final RestoreService restoreService;

  BackupManager({
    required this.repository,
    required this.scheduler,
    required this.encryptionService,
    required this.storageService,
    required this.restoreService,
  });

  static Future<BackupManager> create() async {
    final encryptionService = LocalBackupEncryptionService();
    await encryptionService.initialize();
    final storageService = LocalBackupStorageService();
    final scheduler = LocalBackupScheduler();
    await scheduler.initialize();
    final dbRepository = DatabaseRepository(DatabaseHelper.instance);
    final repository = LocalBackupRepository(
      dbRepository: dbRepository,
      encryptionService: encryptionService,
      storageService: storageService,
    );
    final restoreService = LocalRestoreService(
      encryptionService: encryptionService,
    );
    return BackupManager(
      repository: repository,
      scheduler: scheduler,
      encryptionService: encryptionService,
      storageService: storageService,
      restoreService: restoreService,
    );
  }

  Future<BackupRecord?> createBackup() async {
    return repository.createBackup();
  }

  Future<BackupRecord?> autoBackup() async {
    final enabled = await scheduler.isAutoBackupEnabled();
    if (!enabled) return null;
    final due = await scheduler.isBackupDue();
    if (!due) return null;
    final record = await repository.createBackup();
    if (record != null) {
      final rawDb = await DatabaseHelper.instance.database;
      final rows = await rawDb.query(
        'backup_records',
        where: 'created_at = ? AND status = ?',
        whereArgs: [record.createdAt.toIso8601String(), 'success'],
        orderBy: 'id DESC',
        limit: 1,
      );
      if (rows.isNotEmpty) {
        final destination = rows.first['destination'] as String?;
        if (destination != null) {
          await scheduler.recordBackup(destination);
        }
      }
    }
    return record;
  }

  Future<List<BackupRecord>> getBackupHistory() async {
    return repository.getBackupHistory();
  }

  Future<bool> deleteBackup(String id) async {
    return repository.deleteBackup(id);
  }

  Future<String?> exportBackup(String id) async {
    return repository.exportBackupFile(id);
  }

  Future<String?> importBackup(String path) async {
    return repository.importBackupFile(path);
  }

  Future<RestoreResult> restoreBackup(
    String path, {
    bool overwrite = true,
  }) async {
    return restoreService.restoreFromFile(path, overwrite: overwrite);
  }

  Future<RestoreConflict?> validateBackup(String path) async {
    return restoreService.validateBackup(path);
  }

  Future<List<String>> getBackupTables(String path) async {
    return restoreService.getBackupTables(path);
  }

  Future<BackupSettings> getBackupSettings() async {
    final frequency = await scheduler.getFrequency();
    final autoBackupEnabled = await scheduler.isAutoBackupEnabled();
    final lastBackupAt = await scheduler.getLastBackupTime();
    final storagePath = await storageService.getBackupDirectory();
    return BackupSettings(
      enabled: autoBackupEnabled,
      frequency: frequency,
      autoBackupEnabled: autoBackupEnabled,
      lastBackupAt: lastBackupAt,
      storagePath: storagePath,
    );
  }

  Future<void> updateBackupSettings(BackupSettings settings) async {
    await scheduler.setFrequency(settings.frequency);
    await scheduler.setAutoBackupEnabled(settings.autoBackupEnabled);
  }

  Future<void> cancelScheduledNotifications() async {
    await scheduler.cancelScheduledNotifications();
  }

  Future<void> checkAndNotify() async {
    await scheduler.checkAndNotify();
  }

  Future<List<BackupRecord>> getBackupInfo() async {
    return getBackupHistory();
  }

  Future<void> cleanOldBackups({int keepCount = 10}) async {
    await storageService.deleteOldBackups(keepCount);
  }
}
