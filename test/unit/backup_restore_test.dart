import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:retainly/features/backup/domain/models/backup_models.dart';
import 'package:retainly/features/backup/domain/repositories/backup_encryption_service.dart';
import 'package:retainly/features/backup/data/repositories/local_restore_service.dart';

class FakeEncryptionService implements BackupEncryptionService {
  @override
  Future<Uint8List> encryptData(Uint8List data) async {
    return Uint8List.fromList(utf8.encode('FAKE_ENC:') + data);
  }

  @override
  Future<Uint8List> decryptData(Uint8List encryptedData) async {
    final header = utf8.decode(encryptedData.sublist(0, 9));
    if (header != 'FAKE_ENC:') {
      throw FormatException('Invalid encrypted backup format');
    }
    return encryptedData.sublist(9);
  }

  @override
  Future<bool> isEncryptionAvailable() async => true;

  @override
  Future<void> initialize() async {}
}

void main() {
  group('LocalRestoreService', () {
    late LocalRestoreService restoreService;

    setUp(() {
      restoreService = LocalRestoreService(
        encryptionService: FakeEncryptionService(),
      );
    });

    test('validateBackup returns conflict for missing file', () async {
      final conflict = await restoreService.validateBackup(
        '/nonexistent/path.enc',
      );
      expect(conflict, isNotNull);
      expect(conflict!.conflictType, RestoreConflictType.cancel);
      expect(conflict.currentDataWarning, contains('not found'));
    });

    test('validateBackup returns null for valid backup', () async {
      final payload = {
        'exportedAt': DateTime.now().toIso8601String(),
        'schemaVersion': 2,
        'backupVersion': '1.0.0',
        'deviceInfo': {'platform': 'test'},
        'profile': null,
        'subjects': [],
        'chapters': [],
        'tasks': [],
        'focusSessions': [],
        'revisions': [],
        'resources': [],
        'practicals': [],
        'syllabusTemplates': [],
        'settings': {},
      };
      final jsonBytes = Uint8List.fromList(utf8.encode(jsonEncode(payload)));
      final encrypted = await FakeEncryptionService().encryptData(jsonBytes);
      final tempPath =
          '${Directory.systemTemp.path}/test_backup_${DateTime.now().millisecondsSinceEpoch}.enc';
      await File(tempPath).writeAsBytes(encrypted);

      final conflict = await restoreService.validateBackup(tempPath);
      expect(conflict, isNull);
    });

    test('validateBackup returns merge conflict for schema mismatch', () async {
      final payload = {
        'exportedAt': DateTime.now().toIso8601String(),
        'schemaVersion': 1,
        'backupVersion': '1.0.0',
        'deviceInfo': {'platform': 'test'},
        'profile': null,
        'subjects': [],
        'chapters': [],
        'tasks': [],
        'focusSessions': [],
        'revisions': [],
        'resources': [],
        'practicals': [],
        'syllabusTemplates': [],
        'settings': {},
      };
      final jsonBytes = Uint8List.fromList(utf8.encode(jsonEncode(payload)));
      final encrypted = await FakeEncryptionService().encryptData(jsonBytes);
      final tempPath =
          '${Directory.systemTemp.path}/test_backup_schema_${DateTime.now().millisecondsSinceEpoch}.enc';
      await File(tempPath).writeAsBytes(encrypted);

      final conflict = await restoreService.validateBackup(tempPath);
      expect(conflict, isNotNull);
      expect(conflict!.conflictType, RestoreConflictType.merge);
      expect(conflict.currentDataWarning, contains('Schema version mismatch'));
    });

    test('getBackupTables returns expected table names', () async {
      final payload = {
        'exportedAt': DateTime.now().toIso8601String(),
        'schemaVersion': 2,
        'backupVersion': '1.0.0',
        'deviceInfo': {'platform': 'test'},
        'profile': null,
        'subjects': [],
        'chapters': [],
        'tasks': [],
        'focusSessions': [],
        'revisions': [],
        'resources': [],
        'practicals': [],
        'syllabusTemplates': [],
        'settings': {},
      };
      final jsonBytes = Uint8List.fromList(utf8.encode(jsonEncode(payload)));
      final encrypted = await FakeEncryptionService().encryptData(jsonBytes);
      final tempPath =
          '${Directory.systemTemp.path}/test_backup_tables_${DateTime.now().millisecondsSinceEpoch}.enc';
      await File(tempPath).writeAsBytes(encrypted);

      final tables = await restoreService.getBackupTables(tempPath);
      expect(tables, contains('subjects'));
      expect(tables, contains('chapters'));
      expect(tables, contains('tasks'));
    });

    test('validateBackup returns conflict for truncated JSON', () async {
      final truncatedJson =
          '{"schemaVersion": 2, "backupVersion": "1.0.0", "exp';
      final jsonBytes = Uint8List.fromList(utf8.encode(truncatedJson));
      final encrypted = await FakeEncryptionService().encryptData(jsonBytes);
      final tempPath =
          '${Directory.systemTemp.path}/test_backup_truncated_${DateTime.now().millisecondsSinceEpoch}.enc';
      await File(tempPath).writeAsBytes(encrypted);

      final conflict = await restoreService.validateBackup(tempPath);
      expect(conflict, isNotNull);
      expect(conflict!.conflictType, RestoreConflictType.cancel);
      expect(conflict.currentDataWarning, contains('corrupted'));
    });

    test('validateBackup returns conflict for empty file', () async {
      final jsonBytes = Uint8List.fromList(utf8.encode(''));
      final encrypted = await FakeEncryptionService().encryptData(jsonBytes);
      final tempPath =
          '${Directory.systemTemp.path}/test_backup_empty_${DateTime.now().millisecondsSinceEpoch}.enc';
      await File(tempPath).writeAsBytes(encrypted);

      final conflict = await restoreService.validateBackup(tempPath);
      expect(conflict, isNotNull);
      expect(conflict!.conflictType, RestoreConflictType.cancel);
      expect(conflict.currentDataWarning, contains('empty'));
    });

    test('validateBackup returns conflict for missing required field', () async {
      final payload = {
        'exportedAt': DateTime.now().toIso8601String(),
        'schemaVersion': 2,
        'backupVersion': '1.0.0',
        'deviceInfo': {'platform': 'test'},
        'profile': null,
        'subjects': [],
      };
      final jsonBytes = Uint8List.fromList(utf8.encode(jsonEncode(payload)));
      final encrypted = await FakeEncryptionService().encryptData(jsonBytes);
      final tempPath =
          '${Directory.systemTemp.path}/test_backup_missing_${DateTime.now().millisecondsSinceEpoch}.enc';
      await File(tempPath).writeAsBytes(encrypted);

      final conflict = await restoreService.validateBackup(tempPath);
      expect(conflict, isNotNull);
      expect(conflict!.conflictType, RestoreConflictType.cancel);
      expect(conflict.currentDataWarning, contains('corrupted'));
    });

    test('validateBackup returns conflict for non-object JSON', () async {
      final jsonBytes = Uint8List.fromList(utf8.encode('[1, 2, 3]'));
      final encrypted = await FakeEncryptionService().encryptData(jsonBytes);
      final tempPath =
          '${Directory.systemTemp.path}/test_backup_array_${DateTime.now().millisecondsSinceEpoch}.enc';
      await File(tempPath).writeAsBytes(encrypted);

      final conflict = await restoreService.validateBackup(tempPath);
      expect(conflict, isNotNull);
      expect(conflict!.conflictType, RestoreConflictType.cancel);
      expect(conflict.currentDataWarning, contains('corrupted'));
    });

    test('restoreFromFile returns failure for corrupted data', () async {
      final truncatedJson =
          '{"schemaVersion": 2, "backupVersion": "1.0.0", "exp';
      final jsonBytes = Uint8List.fromList(utf8.encode(truncatedJson));
      final encrypted = await FakeEncryptionService().encryptData(jsonBytes);
      final tempPath =
          '${Directory.systemTemp.path}/test_restore_corrupt_${DateTime.now().millisecondsSinceEpoch}.enc';
      await File(tempPath).writeAsBytes(encrypted);

      final result = await restoreService.restoreFromFile(tempPath);
      expect(result.success, isFalse);
      expect(result.recordsRestored, 0);
      expect(result.message, contains('corrupted'));
    });

    test('getBackupTables returns empty list for corrupted data', () async {
      final truncatedJson =
          '{"schemaVersion": 2, "backupVersion": "1.0.0", "exp';
      final jsonBytes = Uint8List.fromList(utf8.encode(truncatedJson));
      final encrypted = await FakeEncryptionService().encryptData(jsonBytes);
      final tempPath =
          '${Directory.systemTemp.path}/test_tables_corrupt_${DateTime.now().millisecondsSinceEpoch}.enc';
      await File(tempPath).writeAsBytes(encrypted);

      final tables = await restoreService.getBackupTables(tempPath);
      expect(tables, isEmpty);
    });
  });
}
