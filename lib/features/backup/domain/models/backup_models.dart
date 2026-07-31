import 'package:meta/meta.dart';

@immutable
class BackupRecord {
  final int? id;
  final String fileName;
  final DateTime createdAt;
  final int sizeBytes;
  final int schemaVersion;
  final String backupVersion;
  final Map<String, String> deviceInfo;
  final bool encrypted;
  final String status;

  const BackupRecord({
    this.id,
    required this.fileName,
    required this.createdAt,
    required this.sizeBytes,
    required this.schemaVersion,
    required this.backupVersion,
    required this.deviceInfo,
    required this.encrypted,
    required this.status,
  });

  BackupRecord copyWith({
    int? id,
    String? fileName,
    DateTime? createdAt,
    int? sizeBytes,
    int? schemaVersion,
    String? backupVersion,
    Map<String, String>? deviceInfo,
    bool? encrypted,
    String? status,
  }) {
    return BackupRecord(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      createdAt: createdAt ?? this.createdAt,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      backupVersion: backupVersion ?? this.backupVersion,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      encrypted: encrypted ?? this.encrypted,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file_name': fileName,
      'created_at': createdAt.toIso8601String(),
      'size_bytes': sizeBytes,
      'schema_version': schemaVersion,
      'backup_version': backupVersion,
      'device_info': deviceInfo,
      'encrypted': encrypted ? 1 : 0,
      'status': status,
    };
  }

  factory BackupRecord.fromMap(Map<String, dynamic> map) {
    return BackupRecord(
      id: map['id'] is int ? map['id'] as int : null,
      fileName: map['file_name'] is String ? map['file_name'] as String : '',
      createdAt:
          DateTime.tryParse(
            map['created_at'] is String ? map['created_at'] as String : '',
          ) ??
          DateTime.now(),
      sizeBytes: map['size_bytes'] is int ? map['size_bytes'] as int : 0,
      schemaVersion:
          map['schema_version'] is int ? map['schema_version'] as int : 1,
      backupVersion:
          map['backup_version'] is String
              ? map['backup_version'] as String
              : '1.0.0',
      deviceInfo:
          map['device_info'] is Map<String, dynamic>
              ? Map<String, String>.from(map['device_info'])
              : const {},
      encrypted: (map['encrypted'] is int ? map['encrypted'] as int : 0) == 1,
      status: map['status'] is String ? map['status'] as String : 'unknown',
    );
  }

  factory BackupRecord.fromJson(Map<String, dynamic> json) =>
      BackupRecord.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}

enum BackupFrequency { manualOnly, daily, weekly, monthly }

extension BackupFrequencyExtension on BackupFrequency {
  String get name {
    switch (this) {
      case BackupFrequency.manualOnly:
        return 'manualOnly';
      case BackupFrequency.daily:
        return 'daily';
      case BackupFrequency.weekly:
        return 'weekly';
      case BackupFrequency.monthly:
        return 'monthly';
    }
  }

  static BackupFrequency fromName(String name) {
    return BackupFrequency.values.firstWhere(
      (e) => e.name == name,
      orElse: () => BackupFrequency.manualOnly,
    );
  }
}

@immutable
class BackupSettings {
  final bool enabled;
  final BackupFrequency frequency;
  final bool autoBackupEnabled;
  final DateTime? lastBackupAt;
  final String? storagePath;

  const BackupSettings({
    required this.enabled,
    required this.frequency,
    required this.autoBackupEnabled,
    this.lastBackupAt,
    this.storagePath,
  });

  BackupSettings copyWith({
    bool? enabled,
    BackupFrequency? frequency,
    bool? autoBackupEnabled,
    DateTime? lastBackupAt,
    String? storagePath,
  }) {
    return BackupSettings(
      enabled: enabled ?? this.enabled,
      frequency: frequency ?? this.frequency,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      storagePath: storagePath ?? this.storagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled ? 1 : 0,
      'frequency': frequency.name,
      'auto_backup_enabled': autoBackupEnabled ? 1 : 0,
      'last_backup_at': lastBackupAt?.toIso8601String(),
      'storage_path': storagePath,
    };
  }

  factory BackupSettings.fromMap(Map<String, dynamic> map) {
    return BackupSettings(
      enabled: (map['enabled'] is int ? map['enabled'] as int : 0) == 1,
      frequency: BackupFrequencyExtension.fromName(
        map['frequency'] is String ? map['frequency'] as String : 'manualOnly',
      ),
      autoBackupEnabled:
          (map['auto_backup_enabled'] is int
              ? map['auto_backup_enabled'] as int
              : 0) ==
          1,
      lastBackupAt: DateTime.tryParse(
        map['last_backup_at'] is String ? map['last_backup_at'] as String : '',
      ),
      storagePath:
          map['storage_path'] is String ? map['storage_path'] as String : null,
    );
  }

  factory BackupSettings.fromJson(Map<String, dynamic> json) =>
      BackupSettings.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}

enum RestoreConflictType { replace, merge, cancel }

@immutable
class RestoreConflict {
  final BackupRecord backupInfo;
  final RestoreConflictType conflictType;
  final String currentDataWarning;

  const RestoreConflict({
    required this.backupInfo,
    required this.conflictType,
    required this.currentDataWarning,
  });

  RestoreConflict copyWith({
    BackupRecord? backupInfo,
    RestoreConflictType? conflictType,
    String? currentDataWarning,
  }) {
    return RestoreConflict(
      backupInfo: backupInfo ?? this.backupInfo,
      conflictType: conflictType ?? this.conflictType,
      currentDataWarning: currentDataWarning ?? this.currentDataWarning,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'backup_info': backupInfo.toMap(),
      'conflict_type': conflictType.name,
      'current_data_warning': currentDataWarning,
    };
  }

  factory RestoreConflict.fromMap(Map<String, dynamic> map) {
    return RestoreConflict(
      backupInfo: BackupRecord.fromMap(
        map['backup_info'] is Map<String, dynamic>
            ? map['backup_info'] as Map<String, dynamic>
            : const {},
      ),
      conflictType: RestoreConflictType.values.firstWhere(
        (e) => e.name == map['conflict_type'],
        orElse: () => RestoreConflictType.cancel,
      ),
      currentDataWarning:
          map['current_data_warning'] is String
              ? map['current_data_warning'] as String
              : '',
    );
  }

  factory RestoreConflict.fromJson(Map<String, dynamic> json) =>
      RestoreConflict.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}

@immutable
class RestoreResult {
  final bool success;
  final String message;
  final int recordsRestored;
  final int conflictsEncountered;

  const RestoreResult({
    required this.success,
    required this.message,
    required this.recordsRestored,
    required this.conflictsEncountered,
  });

  RestoreResult copyWith({
    bool? success,
    String? message,
    int? recordsRestored,
    int? conflictsEncountered,
  }) {
    return RestoreResult(
      success: success ?? this.success,
      message: message ?? this.message,
      recordsRestored: recordsRestored ?? this.recordsRestored,
      conflictsEncountered: conflictsEncountered ?? this.conflictsEncountered,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success ? 1 : 0,
      'message': message,
      'records_restored': recordsRestored,
      'conflicts_encountered': conflictsEncountered,
    };
  }

  factory RestoreResult.fromMap(Map<String, dynamic> map) {
    return RestoreResult(
      success: (map['success'] is int ? map['success'] as int : 0) == 1,
      message: map['message'] is String ? map['message'] as String : '',
      recordsRestored:
          map['records_restored'] is int ? map['records_restored'] as int : 0,
      conflictsEncountered:
          map['conflicts_encountered'] is int
              ? map['conflicts_encountered'] as int
              : 0,
    );
  }

  factory RestoreResult.fromJson(Map<String, dynamic> json) =>
      RestoreResult.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}
