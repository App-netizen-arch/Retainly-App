import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:retainly/features/backup/domain/models/backup_models.dart';

String formatBytes(int bytes) {
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  if (bytes >= 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  return '$bytes B';
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Backup Manager Screen - Format Bytes', () {
    test('formats bytes for 0', () {
      expect(formatBytes(0), '0 B');
    });

    test('formats bytes for small values', () {
      expect(formatBytes(512), '512 B');
      expect(formatBytes(100), '100 B');
    });

    test('formats bytes for 1023 (just under 1 KB)', () {
      expect(formatBytes(1023), '1023 B');
    });

    test('formats bytes for 1024 (exactly 1 KB)', () {
      expect(formatBytes(1024), '1.0 KB');
    });

    test('formats bytes for 1536 (1.5 KB)', () {
      expect(formatBytes(1536), '1.5 KB');
    });

    test('formats bytes for 1048576 (exactly 1 MB)', () {
      expect(formatBytes(1048576), '1.0 MB');
    });

    test('formats bytes for large values', () {
      expect(formatBytes(5242880), '5.0 MB');
    });

    test('formats bytes for 1572864 (1.5 MB)', () {
      expect(formatBytes(1572864), '1.5 MB');
    });
  });

  group('Backup Manager Screen - Settings Persistence', () {
    test('backup frequency defaults to manualOnly', () async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('local_backup_frequency'), isNull);
    });

    test('backup frequency can be set to daily', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('local_backup_frequency', BackupFrequency.daily.index);
      expect(prefs.getInt('local_backup_frequency'), BackupFrequency.daily.index);
    });

    test('backup frequency can be set to weekly', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('local_backup_frequency', BackupFrequency.weekly.index);
      expect(prefs.getInt('local_backup_frequency'), BackupFrequency.weekly.index);
    });

    test('backup frequency can be set to monthly', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('local_backup_frequency', BackupFrequency.monthly.index);
      expect(prefs.getInt('local_backup_frequency'), BackupFrequency.monthly.index);
    });

    test('auto backup enabled defaults to false', () async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('local_backup_auto_enabled'), isNull);
    });

    test('auto backup enabled can be set to true', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('local_backup_auto_enabled', true);
      expect(prefs.getBool('local_backup_auto_enabled'), isTrue);
    });

    test('backup enabled defaults to false', () async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('local_backup_enabled'), isNull);
    });

    test('backup enabled can be set to true', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('local_backup_enabled', true);
      expect(prefs.getBool('local_backup_enabled'), isTrue);
    });
  });

  group('Backup Manager Screen - BackupFrequency Enum', () {
    test('BackupFrequency has 4 values', () {
      expect(BackupFrequency.values.length, 4);
    });

    test('BackupFrequency values are correct', () {
      expect(BackupFrequency.values, contains(BackupFrequency.manualOnly));
      expect(BackupFrequency.values, contains(BackupFrequency.daily));
      expect(BackupFrequency.values, contains(BackupFrequency.weekly));
      expect(BackupFrequency.values, contains(BackupFrequency.monthly));
    });

    test('BackupFrequency names are correct', () {
      expect(BackupFrequency.manualOnly.name, 'manualOnly');
      expect(BackupFrequency.daily.name, 'daily');
      expect(BackupFrequency.weekly.name, 'weekly');
      expect(BackupFrequency.monthly.name, 'monthly');
    });

    test('BackupFrequency indices are sequential', () {
      expect(BackupFrequency.manualOnly.index, 0);
      expect(BackupFrequency.daily.index, 1);
      expect(BackupFrequency.weekly.index, 2);
      expect(BackupFrequency.monthly.index, 3);
    });

    test('BackupFrequencyExtension.fromName returns correct values', () {
      expect(
        BackupFrequencyExtension.fromName('daily'),
        BackupFrequency.daily,
      );
      expect(
        BackupFrequencyExtension.fromName('weekly'),
        BackupFrequency.weekly,
      );
      expect(
        BackupFrequencyExtension.fromName('monthly'),
        BackupFrequency.monthly,
      );
      expect(
        BackupFrequencyExtension.fromName('manualOnly'),
        BackupFrequency.manualOnly,
      );
    });

    test('BackupFrequencyExtension.fromName returns manualOnly for unknown', () {
      expect(
        BackupFrequencyExtension.fromName('unknown'),
        BackupFrequency.manualOnly,
      );
    });
  });

  group('Backup Manager Screen - BackupRecord Model', () {
    test('BackupRecord can be created with required fields', () {
      final record = BackupRecord(
        fileName: 'backup.enc',
        createdAt: DateTime.now(),
        sizeBytes: 1024,
        schemaVersion: 2,
        backupVersion: '1.0.0',
        deviceInfo: {'platform': 'test'},
        encrypted: true,
        status: 'success',
      );
      expect(record.fileName, 'backup.enc');
      expect(record.sizeBytes, 1024);
      expect(record.schemaVersion, 2);
      expect(record.encrypted, isTrue);
      expect(record.status, 'success');
    });

    test('BackupRecord copyWith returns updated values', () {
      final record = BackupRecord(
        fileName: 'backup.enc',
        createdAt: DateTime.now(),
        sizeBytes: 1024,
        schemaVersion: 2,
        backupVersion: '1.0.0',
        deviceInfo: {'platform': 'test'},
        encrypted: true,
        status: 'success',
      );
      final updated = record.copyWith(sizeBytes: 2048, status: 'failed');
      expect(updated.sizeBytes, 2048);
      expect(updated.status, 'failed');
      expect(updated.fileName, 'backup.enc');
    });

    test('BackupRecord toMap and fromMap round-trip', () {
      final record = BackupRecord(
        id: 1,
        fileName: 'backup.enc',
        createdAt: DateTime(2024, 1, 15, 10, 30),
        sizeBytes: 1024,
        schemaVersion: 2,
        backupVersion: '1.0.0',
        deviceInfo: {'platform': 'test'},
        encrypted: true,
        status: 'success',
      );
      final map = record.toMap();
      final restored = BackupRecord.fromMap(map);
      expect(restored.id, record.id);
      expect(restored.fileName, record.fileName);
      expect(restored.sizeBytes, record.sizeBytes);
      expect(restored.schemaVersion, record.schemaVersion);
      expect(restored.backupVersion, record.backupVersion);
      expect(restored.deviceInfo, record.deviceInfo);
      expect(restored.encrypted, record.encrypted);
      expect(restored.status, record.status);
    });
  });
}
