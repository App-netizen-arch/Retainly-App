import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/backup_models.dart';
import '../../domain/repositories/backup_storage_service.dart';
import '../../domain/repositories/backup_encryption_service.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../../../data/database_helper.dart';
import '../../../../data/repositories/database_repository.dart';

class LocalBackupRepository implements BackupRepository {
  static const _schemaVersion = 2;
  static const _backupVersion = '1.0.0';
  final DatabaseRepository _dbRepository;
  final BackupEncryptionService _encryptionService;
  final BackupStorageService _storageService;

  LocalBackupRepository({
    required DatabaseRepository dbRepository,
    required BackupEncryptionService encryptionService,
    required BackupStorageService storageService,
  }) : _dbRepository = dbRepository,
       _encryptionService = encryptionService,
       _storageService = storageService;

  Map<String, String> _buildDeviceInfo() {
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'model': Platform.isAndroid ? 'android' : 'unknown',
      'app': 'retainly',
    };
  }

  Future<Map<String, dynamic>> _collectBackupData() async {
    final profile = await _dbRepository.getUserProfile();
    final subjects = await _dbRepository.getSubjects();
    final chapters = await _dbRepository.getAllChapters();
    final tasks = await _dbRepository.getAllTasks();
    final sessions = await _dbRepository.getFocusSessions();
    final revisions = await _dbRepository.getAllRevisionItems();
    final resources = await _dbRepository.getAllResources();
    final practicals = await _dbRepository.getAllPracticalRecords();
    final templates = await _dbRepository.getSyllabusTemplates();

    final prefs = await SharedPreferences.getInstance();
    final settingsKeys = prefs.getKeys().toList();

    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'schemaVersion': _schemaVersion,
      'backupVersion': _backupVersion,
      'deviceInfo': _buildDeviceInfo(),
      'profile': profile?.toMap(),
      'subjects': subjects.map((s) => s.toMap()).toList(),
      'chapters': chapters.map((c) => c.toMap()).toList(),
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'focusSessions': sessions.map((s) => s.toMap()).toList(),
      'revisions': revisions.map((r) => r.toMap()).toList(),
      'resources': resources.map((r) => r.toMap()).toList(),
      'practicals': practicals.map((p) => p.toMap()).toList(),
      'syllabusTemplates': templates.map((t) => t.toMap()).toList(),
      'settings': {for (final key in settingsKeys) key: prefs.get(key)},
    };
  }

  @override
  Future<BackupRecord?> createBackup() async {
    try {
      final data = await _collectBackupData();
      final jsonBytes = utf8.encode(jsonEncode(data));
      final encryptedBytes = await _encryptionService.encryptData(
        Uint8List.fromList(jsonBytes),
      );
      final path = await _storageService.generateBackupFilePath();
      final file = File(path);
      await file.writeAsBytes(encryptedBytes);
      final size = await file.length();
      final record = BackupRecord(
        fileName: p.basename(path),
        createdAt: DateTime.now(),
        sizeBytes: size,
        schemaVersion: _schemaVersion,
        backupVersion: _backupVersion,
        deviceInfo: _buildDeviceInfo(),
        encrypted: true,
        status: 'success',
      );
      await DatabaseHelper.instance.insertBackupRecord({
        'created_at': record.createdAt.toIso8601String(),
        'destination': path,
        'status': 'success',
      });
      return record;
    } on Exception {
      return null;
    }
  }

  @override
  Future<List<BackupRecord>> getBackupHistory() async {
    final rawDb = await DatabaseHelper.instance.database;
    final rows = await rawDb.query(
      'backup_records',
      orderBy: 'created_at DESC',
    );
    final records = <BackupRecord>[];
    for (final r in rows) {
      final destination = r['destination'] as String?;
      String fileName = '';
      int sizeBytes = 0;
      if (destination != null) {
        fileName = p.basename(destination);
        final file = File(destination);
        if (await file.exists()) {
          sizeBytes = await file.length();
        }
      }
      records.add(
        BackupRecord(
          id: r['id'] is int ? r['id'] as int : null,
          fileName: fileName,
          createdAt: DateTime.tryParse(
                r['created_at'] is String ? r['created_at'] as String : '',
              ) ??
              DateTime.now(),
          sizeBytes: sizeBytes,
          schemaVersion: _schemaVersion,
          backupVersion: _backupVersion,
          deviceInfo: _buildDeviceInfo(),
          encrypted: true,
          status: r['status'] is String ? r['status'] as String : 'unknown',
        ),
      );
    }
    return records;
  }

  @override
  Future<bool> deleteBackup(String id) async {
    try {
      final intId = int.tryParse(id);
      if (intId == null) return false;
      final rawDb = await DatabaseHelper.instance.database;
      final rows = await rawDb.query(
        'backup_records',
        where: 'id = ?',
        whereArgs: [intId],
      );
      if (rows.isEmpty) return false;
      final path = rows.first['destination'] as String?;
      await rawDb.delete('backup_records', where: 'id = ?', whereArgs: [id]);
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
      return true;
    } on Exception {
      return false;
    }
  }

  @override
  Future<String?> exportBackupFile(String id) async {
    try {
      final intId = int.tryParse(id);
      if (intId == null) return null;
      final rawDb = await DatabaseHelper.instance.database;
      final rows = await rawDb.query(
        'backup_records',
        where: 'id = ?',
        whereArgs: [intId],
      );
      if (rows.isEmpty) return null;
      final sourcePath = rows.first['destination'] as String?;
      if (sourcePath == null) return null;
      final source = File(sourcePath);
      if (!await source.exists()) return null;

      final result = await FilePicker.saveFile(
        dialogTitle: 'Export Backup',
        fileName:
            'msp_backup_${DateTime.now().millisecondsSinceEpoch}.json.enc',
        type: FileType.custom,
        allowedExtensions: ['enc'],
        bytes: await source.readAsBytes(),
      );
      if (result == null) return null;
      return result;
    } on Exception {
      return null;
    }
  }

  @override
  Future<String?> importBackupFile(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return null;
      final decrypted = await _encryptionService.decryptData(bytes);
      if (decrypted.isEmpty) return null;
      final json = jsonDecode(utf8.decode(decrypted)) as Map<String, dynamic>;
      if (json['schemaVersion'] != _schemaVersion) {
        throw FormatException('Incompatible schema version');
      }
      final requiredFields = [
        'exportedAt',
        'backupVersion',
        'deviceInfo',
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
      for (final field in requiredFields) {
        if (!json.containsKey(field)) {
          throw FormatException('Missing required field: $field');
        }
      }
      return path;
    } on Exception {
      return null;
    }
  }
}
