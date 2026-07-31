import 'dart:convert';
import 'package:test/test.dart';
import 'package:retainly/features/backup/domain/models/backup_models.dart';

void main() {
  group('BackupModels', () {
    test('BackupRecord round-trips through toMap/fromMap', () {
      final now = DateTime.now();
      final original = BackupRecord(
        fileName: 'msp_backup_2026-01-01.json.enc',
        createdAt: now,
        sizeBytes: 1024,
        schemaVersion: 2,
        backupVersion: '1.0.0',
        deviceInfo: {'platform': 'android', 'app': 'retainly'},
        encrypted: true,
        status: 'success',
      );
      final map = original.toMap();
      final restored = BackupRecord.fromMap(map);
      expect(restored.fileName, original.fileName);
      expect(restored.sizeBytes, original.sizeBytes);
      expect(restored.schemaVersion, original.schemaVersion);
      expect(restored.backupVersion, original.backupVersion);
      expect(restored.encrypted, original.encrypted);
      expect(restored.status, original.status);
    });

    test('BackupSettings round-trips through toMap/fromMap', () {
      final original = BackupSettings(
        enabled: true,
        frequency: BackupFrequency.weekly,
        autoBackupEnabled: false,
        lastBackupAt: DateTime.now(),
        storagePath: '/path/to/backups',
      );
      final map = original.toMap();
      final restored = BackupSettings.fromMap(map);
      expect(restored.enabled, original.enabled);
      expect(restored.frequency, original.frequency);
      expect(restored.autoBackupEnabled, original.autoBackupEnabled);
      expect(restored.storagePath, original.storagePath);
    });

    test('BackupFrequencyExtension fromName returns correct enum', () {
      expect(BackupFrequencyExtension.fromName('daily'), BackupFrequency.daily);
      expect(
        BackupFrequencyExtension.fromName('weekly'),
        BackupFrequency.weekly,
      );
      expect(
        BackupFrequencyExtension.fromName('monthly'),
        BackupFrequency.monthly,
      );
      expect(
        BackupFrequencyExtension.fromName('unknown'),
        BackupFrequency.manualOnly,
      );
    });

    test('BackupFrequencyExtension name returns correct string', () {
      expect(BackupFrequency.daily.name, 'daily');
      expect(BackupFrequency.weekly.name, 'weekly');
      expect(BackupFrequency.monthly.name, 'monthly');
      expect(BackupFrequency.manualOnly.name, 'manualOnly');
    });

    test('RestoreConflict round-trips through toMap/fromMap', () {
      final backup = BackupRecord(
        fileName: 'test.enc',
        createdAt: DateTime.now(),
        sizeBytes: 500,
        schemaVersion: 2,
        backupVersion: '1.0.0',
        deviceInfo: const {},
        encrypted: true,
        status: 'valid',
      );
      final original = RestoreConflict(
        backupInfo: backup,
        conflictType: RestoreConflictType.merge,
        currentDataWarning: 'Schema version mismatch',
      );
      final map = original.toMap();
      final restored = RestoreConflict.fromMap(map);
      expect(restored.backupInfo.fileName, original.backupInfo.fileName);
      expect(restored.conflictType, original.conflictType);
      expect(restored.currentDataWarning, original.currentDataWarning);
    });

    test('RestoreResult round-trips through toMap/fromMap', () {
      final original = RestoreResult(
        success: true,
        message: 'Restore completed',
        recordsRestored: 42,
        conflictsEncountered: 0,
      );
      final map = original.toMap();
      final restored = RestoreResult.fromMap(map);
      expect(restored.success, original.success);
      expect(restored.message, original.message);
      expect(restored.recordsRestored, original.recordsRestored);
      expect(restored.conflictsEncountered, original.conflictsEncountered);
    });

    test('BackupRecord JSON serialization preserves fields', () {
      final record = BackupRecord(
        fileName: 'test.json.enc',
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        sizeBytes: 2048,
        schemaVersion: 2,
        backupVersion: '1.0.0',
        deviceInfo: {'platform': 'android', 'app': 'retainly'},
        encrypted: true,
        status: 'success',
      );
      final json = jsonEncode(record.toJson());
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      expect(decoded['file_name'], 'test.json.enc');
      expect(decoded['size_bytes'], 2048);
      expect(decoded['encrypted'], 1);
    });
  });
}
