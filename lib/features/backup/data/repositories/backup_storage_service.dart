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
