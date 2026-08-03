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

  Future<List<BackupRecord>> getBackupHistory() async {
    return repository.getBackupHistory();
  }

  Future<bool> deleteBackup(String id) async {
    return repository.deleteBackup(id);
  }

  Future<String?> exportBackup(String id) async {
    return repository.exportBackupFile(id);
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

  Future<void> cancelScheduledNotifications() async {
    await scheduler.cancelScheduledNotifications();
  }

  Future<void> checkAndNotify() async {
    await scheduler.checkAndNotify();
  }
}
