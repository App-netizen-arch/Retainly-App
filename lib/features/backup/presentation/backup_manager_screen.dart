import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/backup_models.dart';
import '../application/backup_manager.dart';
import '../../../providers/database_provider.dart';

class BackupManagerScreen extends ConsumerStatefulWidget {
  const BackupManagerScreen({super.key});

  @override
  ConsumerState<BackupManagerScreen> createState() =>
      _BackupManagerScreenState();
}

class _BackupManagerScreenState extends ConsumerState<BackupManagerScreen> {
  BackupManager? _manager;
  List<BackupRecord> _history = const <BackupRecord>[];
  bool _loading = true;
  String? _statusMessage;
  BackupFrequency _frequency = BackupFrequency.manualOnly;
  bool _autoBackupEnabled = false;
  bool _backupEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    setState(() => _loading = true);
    try {
      final manager = await BackupManager.create();
      await _loadSettings();
      await _loadHistory(manager);
      setState(() {
        _manager = manager;
        _loading = false;
      });
    } on Exception catch (e) {
      setState(() {
        _loading = false;
        _statusMessage = 'Failed to load: $e';
      });
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final frequencyIndex =
        prefs.getInt('local_backup_frequency') ??
        BackupFrequency.manualOnly.index;
    final autoBackup = prefs.getBool('local_backup_auto_enabled') ?? false;
    final enabled = prefs.getBool('local_backup_enabled') ?? false;
    if (mounted) {
      setState(() {
        _frequency = BackupFrequency.values[frequencyIndex];
        _autoBackupEnabled = autoBackup;
        _backupEnabled = enabled;
      });
    }
  }

  Future<void> _loadHistory(BackupManager manager) async {
    final history = await manager.getBackupHistory();
    if (mounted) {
      setState(() => _history = history);
    }
  }

  Future<void> _setFrequency(BackupFrequency frequency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('local_backup_frequency', frequency.index);
    if (_manager != null) {
      await _manager!.scheduler.setFrequency(frequency);
    }
    if (mounted) setState(() => _frequency = frequency);
  }

  Future<void> _setAutoBackup(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('local_backup_auto_enabled', value);
    if (_manager != null) {
      await _manager!.scheduler.setAutoBackupEnabled(value);
    }
    if (mounted) setState(() => _autoBackupEnabled = value);
  }

  Future<void> _setBackupEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('local_backup_enabled', value);
    if (mounted) setState(() => _backupEnabled = value);
  }

  Future<void> _createBackup() async {
    if (_manager == null) return;
    setState(() => _statusMessage = 'Creating backup...');
    final record = await _manager!.createBackup();
    if (record == null) {
      setState(() => _statusMessage = 'Backup failed');
    } else {
      setState(() => _statusMessage = 'Backup created: ${record.fileName}');
      await _loadHistory(_manager!);
    }
  }

  Future<void> _exportBackup(String id) async {
    if (_manager == null) return;
    final result = await _manager!.exportBackup(id);
    if (result == null) {
      setState(() => _statusMessage = 'Export cancelled or failed');
    } else {
      setState(() => _statusMessage = 'Exported to $result');
    }
  }

  Future<void> _importBackup() async {
    if (_manager == null) return;
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['enc', 'json'],
    );
    if (result == null || result.files.isEmpty) return;
    final file = File(result.files.first.path ?? '');
    if (!await file.exists()) {
      setState(() => _statusMessage = 'File not found');
      return;
    }

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (dialogContext, setDialogState) {
                  final controller = TextEditingController();
                  bool canRestore = false;
                  return AlertDialog(
                    title: const Text('Restore from backup?'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This will overwrite your current data with the backup from:\n${p.basename(file.path)}\n\nThis cannot be undone.',
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Type "restore" to confirm:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            hintText: 'Type restore',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setDialogState(() {
                              canRestore = value.toLowerCase() == 'restore';
                            });
                          },
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: canRestore
                            ? () => Navigator.pop(ctx, true)
                            : null,
                        child: const Text('Restore'),
                      ),
                    ],
                  );
                },
          ),
    );
    if (confirmed != true) return;

    setState(() => _statusMessage = 'Restoring...');
    final restoreResult = await _manager!.restoreBackup(file.path);
    if (restoreResult.success) {
      setState(
        () =>
            _statusMessage =
                'Restore successful. ${restoreResult.recordsRestored} records restored.',
      );
      ref.invalidate(databaseRepositoryProvider);
      ref.invalidate(userProfileProvider);
      ref.invalidate(todayTasksProvider);
      ref.invalidate(allPendingTasksProvider);
      ref.invalidate(dueRevisionsProvider);
      ref.invalidate(dashboardProvider);
      ref.invalidate(progressMetricsProvider);
      await _loadHistory(_manager!);
    } else {
      setState(
        () => _statusMessage = 'Restore failed: ${restoreResult.message}',
      );
    }
  }

  Future<void> _deleteBackup(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete backup?'),
            content: const Text(
              'This will permanently delete the selected backup.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    if (_manager == null) return;
    final ok = await _manager!.deleteBackup(id);
    if (ok) {
      setState(() => _statusMessage = 'Backup deleted');
      await _loadHistory(_manager!);
    } else {
      setState(() => _statusMessage = 'Failed to delete backup');
    }
  }

  Future<int> _getAvailableStorageBytes() async {
    if (_manager == null) return 0;
    final dirPath = await _manager!.storageService.getBackupDirectory();
    final dir = Directory(dirPath);
    if (!await dir.exists()) return 0;
    int total = 0;
    await for (final entity in dir.list()) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '$bytes B';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup Manager')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_statusMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _statusMessage!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  SwitchListTile(
                    secondary: const Icon(Icons.backup_rounded),
                    title: const Text('Enable Backup'),
                    subtitle: const Text('Turn on local encrypted backups'),
                    value: _backupEnabled,
                    onChanged: _setBackupEnabled,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<BackupFrequency>(
                    decoration: const InputDecoration(
                      labelText: 'Backup Frequency',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _frequency,
                    items:
                        BackupFrequency.values
                            .map(
                              (f) => DropdownMenuItem(
                                value: f,
                                child: Text(
                                  f.name == 'manualOnly'
                                      ? 'Manual Only'
                                      : f.name.capitalize(),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) _setFrequency(value);
                    },
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    secondary: const Icon(Icons.autorenew_rounded),
                    title: const Text('Auto-backup reminders'),
                    subtitle: const Text('Notify when a backup is due'),
                    value: _autoBackupEnabled,
                    onChanged: _setAutoBackup,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _createBackup,
                          icon: const Icon(Icons.backup_rounded),
                          label: const Text('Create Backup Now'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _importBackup,
                          icon: const Icon(Icons.restore_rounded),
                          label: const Text('Restore'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        'Backup History',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      FutureBuilder<int>(
                        future: _getAvailableStorageBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                children: [
                                  const Text('Something went wrong. Please try again.'),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      if (context.mounted) {
                                        setState(() {});
                                      }
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          }
                          final bytes = snapshot.data ?? 0;
                          return Text(
                            'Storage: ${_formatBytes(bytes)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_history.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text('No backups yet.'),
                    )
                  else
                    ..._history.map((record) {
                      final date = DateFormat(
                        'yyyy-MM-dd HH:mm',
                      ).format(record.createdAt);
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.lock_rounded),
                          title: Text(record.fileName),
                          subtitle: Text(
                            '$date • ${_formatBytes(record.sizeBytes)} • ${record.status}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                               IconButton(
                                 iconSize: 18,
                                 icon: const Icon(
                                   Icons.file_download_rounded,
                                   size: 20,
                                 ),
                                 tooltip: 'Download backup',
                                 onPressed:
                                     () => _exportBackup(record.id.toString()),
                               ),
                               IconButton(
                                 iconSize: 18,
                                 icon: Icon(
                                   Icons.delete_rounded,
                                   size: 20,
                                   color: Theme.of(context).colorScheme.error,
                                 ),
                                 tooltip: 'Delete backup',
                                 onPressed:
                                     () => _deleteBackup(record.id.toString()),
                               ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
