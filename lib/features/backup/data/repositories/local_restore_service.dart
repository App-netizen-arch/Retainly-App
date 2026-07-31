import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/backup_models.dart';
import '../../domain/repositories/restore_service.dart';
import '../../domain/repositories/backup_encryption_service.dart';
import '../../../../data/database_helper.dart';

class LocalRestoreService implements RestoreService {
  static const _schemaVersion = 2;
  static const _requiredFields = [
    'schemaVersion',
    'backupVersion',
    'exportedAt',
    'profile',
    'subjects',
    'chapters',
    'tasks',
    'focusSessions',
    'revisions',
    'resources',
    'practicals',
    'syllabusTemplates',
    'settings',
  ];
  final BackupEncryptionService _encryptionService;

  LocalRestoreService({required BackupEncryptionService encryptionService})
    : _encryptionService = encryptionService;

  Future<Map<String, dynamic>> _decryptAndValidateBackup(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw FileSystemException('Backup file not found', path);
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw const FormatException(
        'Backup file is empty or corrupted (truncated data).',
      );
    }
    final decrypted = await _encryptionService.decryptData(bytes);
    if (decrypted.isEmpty) {
      throw const FormatException(
        'Decrypted backup data is empty (possible corruption).',
      );
    }
    final decoded = utf8.decode(decrypted);
    if (decoded.isEmpty) {
      throw const FormatException(
        'Decoded backup data is empty (possible corruption).',
      );
    }
    final json = jsonDecode(decoded);
    if (json is! Map<String, dynamic>) {
      throw FormatException(
        'Backup data is not a valid JSON object (truncated or corrupted JSON).',
      );
    }
    for (final field in _requiredFields) {
      if (!json.containsKey(field)) {
        throw FormatException(
          'Backup data is missing required field: $field. '
          'The backup may be truncated or corrupted.',
        );
      }
    }
    final dynamic schemaVersion = json['schemaVersion'];
    if (schemaVersion is! int) {
      throw FormatException(
        'Invalid schemaVersion in backup: expected int, got ${schemaVersion.runtimeType}.',
      );
    }
    return json;
  }

  @override
  Future<RestoreConflict?> validateBackup(String path) async {
    try {
      final json = await _decryptAndValidateBackup(path);
      final schemaVersion = json['schemaVersion'] as int;
      final backupVersion =
          json['backupVersion'] is String
              ? json['backupVersion'] as String
              : 'unknown';
      final backupInfo = BackupRecord(
        fileName: p.basename(path),
        createdAt:
            DateTime.tryParse(
                  json['exportedAt'] is String
                      ? json['exportedAt'] as String
                      : '',
                ) ??
                DateTime.now(),
        sizeBytes: File(path).lengthSync(),
        schemaVersion: schemaVersion,
        backupVersion: backupVersion,
        deviceInfo:
            json['deviceInfo'] is Map<String, dynamic>
                ? Map<String, String>.from(json['deviceInfo'])
                : const {},
        encrypted: true,
        status: 'valid',
      );
      if (schemaVersion != _schemaVersion) {
        return RestoreConflict(
          backupInfo: backupInfo,
          conflictType: RestoreConflictType.merge,
          currentDataWarning:
              'Schema version mismatch: backup has version $schemaVersion, expected $_schemaVersion.',
        );
      }
      return null;
    } on FormatException catch (e) {
      return RestoreConflict(
        backupInfo: BackupRecord(
          fileName: p.basename(path),
          createdAt: DateTime.now(),
          sizeBytes: 0,
          schemaVersion: 0,
          backupVersion: 'unknown',
          deviceInfo: const {},
          encrypted: true,
          status: 'corrupt',
        ),
        conflictType: RestoreConflictType.cancel,
        currentDataWarning: 'Backup data is corrupted: ${e.message}',
      );
    } on FileSystemException catch (e) {
      return RestoreConflict(
        backupInfo: BackupRecord(
          fileName: p.basename(path),
          createdAt: DateTime.now(),
          sizeBytes: 0,
          schemaVersion: 0,
          backupVersion: 'unknown',
          deviceInfo: const {},
          encrypted: true,
          status: 'invalid',
        ),
        conflictType: RestoreConflictType.cancel,
        currentDataWarning: 'Backup file not found: ${e.path}',
      );
    } on Exception catch (e) {
      return RestoreConflict(
        backupInfo: BackupRecord(
          fileName: p.basename(path),
          createdAt: DateTime.now(),
          sizeBytes: 0,
          schemaVersion: 0,
          backupVersion: 'unknown',
          deviceInfo: const {},
          encrypted: true,
          status: 'error',
        ),
        conflictType: RestoreConflictType.cancel,
        currentDataWarning: 'Failed to validate backup: $e',
      );
    }
  }

  @override
  Future<List<String>> getBackupTables(String path) async {
    try {
      final json = await _decryptAndValidateBackup(path);
      final keys =
          json.keys
              .where(
                (key) =>
                    key != 'exportedAt' &&
                    key != 'schemaVersion' &&
                    key != 'backupVersion' &&
                    key != 'deviceInfo' &&
                    key != 'settings',
              )
              .toList();
      return keys.toList();
    } on Exception {
      return [];
    }
  }

  Future<Map<String, dynamic>> _decryptBackup(String path) async {
    return _decryptAndValidateBackup(path);
  }

  Future<void> _clearLocalData() async {
    final rawDb = await DatabaseHelper.instance.database;
    await rawDb.delete('focus_sessions');
    await rawDb.delete('revision_items');
    await rawDb.delete('study_tasks');
    await rawDb.delete('resources');
    await rawDb.delete('practical_records');
    await rawDb.delete('chapters');
    await rawDb.delete('subjects');
    await rawDb.delete('user_profiles');
    await rawDb.delete('backup_records');
    await rawDb.delete('sync_meta');
  }

  int _countRecords(Map<String, dynamic> payload) {
    var count = 0;
    count += (payload['profile'] != null) ? 1 : 0;
    count += (payload['subjects'] as List?)?.length ?? 0;
    count += (payload['chapters'] as List?)?.length ?? 0;
    count += (payload['tasks'] as List?)?.length ?? 0;
    count += (payload['focusSessions'] as List?)?.length ?? 0;
    count += (payload['revisions'] as List?)?.length ?? 0;
    count += (payload['resources'] as List?)?.length ?? 0;
    count += (payload['practicals'] as List?)?.length ?? 0;
    count += (payload['syllabusTemplates'] as List?)?.length ?? 0;
    return count;
  }

  Future<void> _importData(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (payload['profile'] != null) {
      await DatabaseHelper.instance.createUserProfile(
        Map<String, dynamic>.from(payload['profile']),
      );
    }
    for (final s in payload['subjects'] ?? const []) {
      await DatabaseHelper.instance.insertSubject(Map<String, dynamic>.from(s));
    }
    for (final c in payload['chapters'] ?? const []) {
      await DatabaseHelper.instance.insertChapter(Map<String, dynamic>.from(c));
    }
    for (final t in payload['tasks'] ?? const []) {
      await DatabaseHelper.instance.insertTask(Map<String, dynamic>.from(t));
    }
    for (final s in payload['focusSessions'] ?? const []) {
      await DatabaseHelper.instance.insertFocusSession(
        Map<String, dynamic>.from(s),
      );
    }
    for (final r in payload['revisions'] ?? const []) {
      await DatabaseHelper.instance.insertRevisionItem(
        Map<String, dynamic>.from(r),
      );
    }
    for (final r in payload['resources'] ?? const []) {
      await DatabaseHelper.instance.insertResource(
        Map<String, dynamic>.from(r),
      );
    }
    for (final p in payload['practicals'] ?? const []) {
      await DatabaseHelper.instance.insertPracticalRecord(
        Map<String, dynamic>.from(p),
      );
    }
    for (final t in payload['syllabusTemplates'] ?? const []) {
      await DatabaseHelper.instance.insertSyllabusTemplate(
        Map<String, dynamic>.from(t),
      );
    }
  }

  Future<void> _importSettings(Map<String, dynamic> payload) async {
    final settings = payload['settings'];
    if (settings is! Map<String, dynamic>) return;
    final prefs = await SharedPreferences.getInstance();
    for (final entry in settings.entries) {
      final value = entry.value;
      if (value is bool) {
        await prefs.setBool(entry.key, value);
      } else if (value is int) {
        await prefs.setInt(entry.key, value);
      } else if (value is double) {
        await prefs.setDouble(entry.key, value);
      } else if (value is String) {
        await prefs.setString(entry.key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(entry.key, value);
      }
    }
  }

  @override
  Future<RestoreResult> restoreFromFile(
    String path, {
    bool overwrite = true,
  }) async {
    try {
      final payload = await _decryptBackup(path);
      final schemaVersion = payload['schemaVersion'];
      if (schemaVersion != _schemaVersion) {
        return const RestoreResult(
          success: false,
          message: 'Incompatible schema version.',
          recordsRestored: 0,
          conflictsEncountered: 1,
        );
      }

      if (overwrite) {
        await _clearLocalData();
      }

      await _importData(payload);
      await _importSettings(payload);

      final recordCount = _countRecords(payload);

      return RestoreResult(
        success: true,
        message: 'Restore completed successfully.',
        recordsRestored: recordCount,
        conflictsEncountered: 0,
      );
    } on FormatException catch (e) {
      return RestoreResult(
        success: false,
        message: 'Restore failed: backup data is corrupted: ${e.message}',
        recordsRestored: 0,
        conflictsEncountered: 1,
      );
    } on FileSystemException catch (e) {
      return RestoreResult(
        success: false,
        message: 'Restore failed: ${e.message}',
        recordsRestored: 0,
        conflictsEncountered: 1,
      );
    } on Exception catch (e) {
      return RestoreResult(
        success: false,
        message: 'Restore failed: $e',
        recordsRestored: 0,
        conflictsEncountered: 1,
      );
    }
  }
}
