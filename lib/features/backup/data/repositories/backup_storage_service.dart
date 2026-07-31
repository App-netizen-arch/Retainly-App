import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../domain/repositories/backup_storage_service.dart';

class LocalBackupStorageService implements BackupStorageService {
  static const _backupFolderName = 'backups';

  @override
  Future<String> getBackupDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(docsDir.path, _backupFolderName));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir.path;
  }

  @override
  Future<String> generateBackupFilePath() async {
    final dir = await getBackupDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(
      RegExp(r'[: ]'),
      '-',
    );
    final fileName = 'msp_backup_$timestamp.json.enc';
    return p.join(dir, fileName);
  }

  @override
  Future<int> getAvailableStorageBytes() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      if (Platform.isLinux || Platform.isMacOS) {
        final result = await Process.run(
          'df',
          ['-B1', docsDir.path],
          runInShell: true,
        );
        if (result.exitCode == 0) {
          final lines =
              (result.stdout as String).trim().split('\n');
          if (lines.length >= 2) {
            final parts = lines[1].trim().split(RegExp(r'\s+'));
            if (parts.length >= 4) {
              final avail = int.tryParse(parts[3]);
              if (avail != null && avail >= 0) return avail;
            }
          }
        }
      } else if (Platform.isWindows) {
        final result = await Process.run(
          'wmic',
          [
            'logicaldisk',
            'where',
            "DeviceID='C:'",
            'get',
            'FreeSpace',
          ],
          runInShell: true,
        );
        if (result.exitCode == 0) {
          final lines =
              (result.stdout as String).trim().split('\n');
          if (lines.length >= 2) {
            final free = int.tryParse(lines[1].trim());
            if (free != null && free >= 0) return free;
          }
        }
      }
    } on Exception {
      return 0;
    }
    return 0;
  }

  @override
  Future<void> deleteOldBackups(int keepCount) async {
    final dir = Directory(await getBackupDirectory());
    if (!await dir.exists()) return;
    final entities = await dir.list().toList();
    final files =
        entities
            .whereType<File>()
            .where((f) => p.extension(f.path) == '.enc')
            .toList();
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    for (var i = keepCount; i < files.length; i++) {
      try {
        await files[i].delete();
      } on Exception {
        // Continue on failure to delete individual backup files
      }
    }
  }
}
