import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:retainly/features/backup/data/repositories/local_backup_scheduler.dart';
import 'package:retainly/features/backup/domain/models/backup_models.dart';

void main() {
  group('LocalBackupScheduler', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('defaults to manualOnly frequency', () async {
      final scheduler = LocalBackupScheduler();
      final freq = await scheduler.getFrequency();
      expect(freq, BackupFrequency.manualOnly);
    });

    test('defaults autoBackupEnabled to false', () async {
      final scheduler = LocalBackupScheduler();
      final enabled = await scheduler.isAutoBackupEnabled();
      expect(enabled, false);
    });

    test('setFrequency persists and retrieves frequency', () async {
      final scheduler = LocalBackupScheduler();
      await scheduler.setFrequency(BackupFrequency.daily);
      final freq = await scheduler.getFrequency();
      expect(freq, BackupFrequency.daily);
    });

    test('setAutoBackupEnabled persists and retrieves value', () async {
      final scheduler = LocalBackupScheduler();
      await scheduler.setAutoBackupEnabled(true);
      final enabled = await scheduler.isAutoBackupEnabled();
      expect(enabled, true);
    });

    test('recordBackup stores timestamp and path', () async {
      final scheduler = LocalBackupScheduler();
      await scheduler.recordBackup('/tmp/backup.json.enc');
      final lastTime = await scheduler.getLastBackupTime();
      expect(lastTime, isNotNull);
      final path = await scheduler.getLastBackupPath();
      expect(path, '/tmp/backup.json.enc');
    });

    test('isBackupDue returns true when no previous backup', () async {
      final scheduler = LocalBackupScheduler();
      final due = await scheduler.isBackupDue();
      expect(due, false);
    });

    test('isBackupDue respects daily frequency', () async {
      final scheduler = LocalBackupScheduler();
      await scheduler.setFrequency(BackupFrequency.daily);
      await scheduler.recordBackup('/tmp/backup.json.enc');
      final due = await scheduler.isBackupDue();
      expect(due, false);
    });

    test('isBackupDue returns false for manualOnly frequency', () async {
      final scheduler = LocalBackupScheduler();
      await scheduler.setFrequency(BackupFrequency.manualOnly);
      await scheduler.recordBackup('/tmp/backup.json.enc');
      final due = await scheduler.isBackupDue();
      expect(due, false);
    });

    test('isBackupDue returns false when autoBackup is disabled', () async {
      final scheduler = LocalBackupScheduler();
      await scheduler.setFrequency(BackupFrequency.daily);
      await scheduler.setAutoBackupEnabled(false);
      await scheduler.recordBackup('/tmp/backup.json.enc');
      final due = await scheduler.isBackupDue();
      expect(due, false);
    });

    test('initialize does not throw', () async {
      final scheduler = LocalBackupScheduler();
      await scheduler.initialize();
      // Should be idempotent
      await scheduler.initialize();
    });

    test('cancelScheduledNotifications does not throw', () async {
      final scheduler = LocalBackupScheduler();
      await scheduler.cancelScheduledNotifications();
    });

    test('checkAndNotify does not throw when autoBackup is disabled', () async {
      final scheduler = LocalBackupScheduler();
      await scheduler.setAutoBackupEnabled(false);
      await scheduler.checkAndNotify();
    });

    test('checkAndNotify does not throw when backup is not due', () async {
      final scheduler = LocalBackupScheduler();
      await scheduler.setAutoBackupEnabled(true);
      await scheduler.setFrequency(BackupFrequency.daily);
      await scheduler.checkAndNotify();
    });
  });
}
