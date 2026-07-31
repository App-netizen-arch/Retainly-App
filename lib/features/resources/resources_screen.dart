import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import '../../providers/database_provider.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/database_repository.dart';
import '../../services/ai_service.dart';

class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen> {
  static const int maxFileSizeBytes = 50 * 1024 * 1024;

  Future<String> _getCustomNotesDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final notesDir = Directory('${dir.path}/CustomNotes');
    if (!await notesDir.exists()) {
      await notesDir.create(recursive: true);
    }
    return notesDir.path;
  }

  Future<List<String>> _getCustomNoteFolders() async {
    final notesDirPath = await _getCustomNotesDirectory();
    final notesDir = Directory(notesDirPath);
    final entities = await notesDir.list().toList();
    final folders = <String>[];
    for (final e in entities) {
      if (e is Directory) {
        folders.add(p.basename(e.path));
      }
    }
    return folders;
  }

  Future<void> _createCustomNoteFolder(String folderName) async {
    final folders = await _getCustomNoteFolders();
    if (folders.length >= 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 6 folders allowed in Custom Notes')),
        );
      }
      return;
    }
    final notesDir = await _getCustomNotesDirectory();
    final newFolder = Directory(p.join(notesDir, folderName));
    if (!await newFolder.exists()) {
      await newFolder.create(recursive: true);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Folder "$folderName" created')),
      );
    }
    setState(() {});
  }

  Future<void> _showCreateFolderDialog() async {
    final controller = TextEditingController();
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('New Folder'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Folder name',
                hintText: 'e.g., Biology Notes',
              ),
              maxLength: 30,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Create'),
              ),
            ],
          ),
    );
    if (confirmed == true && controller.text.trim().isNotEmpty) {
      await _createCustomNoteFolder(controller.text.trim());
    }
  }

  Future<void> _showAISidebar() async {
    if (!mounted) return;
    final service = AIService();
    final answer = await service.askAiAboutSubject(
      'local_user',
      'Help me organize my Custom Notes. Suggest a structure for my study notes.',
    );
    if (!mounted) return;
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('AI Notes Assistant'),
            content: SingleChildScrollView(
              child: Text(answer ?? 'Could not generate suggestion.'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Future<void> _importResource({
    required DatabaseRepository db,
    required PlatformFile file,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final sourceFile = File(file.path ?? '');
    if (!await sourceFile.exists()) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Source file not found')),
        );
      }
      return;
    }

    final fileSize = await sourceFile.length();
    if (fileSize > maxFileSizeBytes) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'File too large: ${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB. Max allowed is 50 MB.',
            ),
          ),
        );
      }
      return;
    }

    final ext = file.extension ?? p.extension(file.name);
    final bytes = await sourceFile.readAsBytes();
    final saveResult = await FilePicker.saveFile(
      dialogTitle: 'Save imported resource',
      fileName: file.name,
      type: FileType.custom,
      allowedExtensions: [ext.replaceFirst('.', '')],
      bytes: bytes,
    );
    if (saveResult == null) return;
    final targetPath = saveResult;

    final existing = await db.getAllResources();
    final exists = existing.any(
      (r) => r.localPath == targetPath || r.title == file.name,
    );
    if (exists) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('${file.name} already exists. Skipped.')),
        );
      }
      return;
    }

    await sourceFile.copy(targetPath);
    final subjects = await db.getSubjects();
    final subjectId = subjects.isNotEmpty ? subjects.first.id ?? 1 : 1;
    final meta = await _showMetaDialog();
    await db.insertResource(
      ResourceModel(
        subjectId: subjectId,
        type: file.extension ?? 'file',
        title: file.name,
        localPath: targetPath,
        createdAt: DateTime.now().toIso8601String(),
        isPinned: false,
        folder: meta?.folder,
        tags: meta?.tags.join(','),
      ),
    );
    if (mounted) {
      setState(() {});
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Imported to $targetPath (${(fileSize / 1024).toStringAsFixed(1)} KB)',
          ),
        ),
      );
    }
  }

  Future<_ResourceMeta?> _showMetaDialog() async {
    if (!mounted) return null;
    final folderController = TextEditingController();
    final tagsController = TextEditingController();
    return await showDialog<_ResourceMeta>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Resource details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: folderController,
                  decoration: const InputDecoration(
                    labelText: 'Folder (optional)',
                  ),
                ),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma-separated)',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Skip'),
              ),
              ElevatedButton(
                onPressed: () {
                  final tags =
                      tagsController.text
                          .split(',')
                          .map((t) => t.trim())
                          .where((t) => t.isNotEmpty)
                          .toList();
                  Navigator.pop(
                    ctx,
                    _ResourceMeta(
                      folder:
                          folderController.text.trim().isEmpty
                              ? null
                              : folderController.text.trim(),
                      tags: tags,
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbAsync = ref.watch(databaseRepositoryProvider);
    final fabEnabled = dbAsync.value != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Resources')),
      floatingActionButton: fabEnabled
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'ai_notes',
                  onPressed: _showAISidebar,
                  child: const Icon(Icons.auto_awesome),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'add_resource',
                  onPressed: () async {
                    final db = dbAsync.value;
                    if (db == null) return;
                    final result = await FilePicker.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: [
                        'pdf',
                        'txt',
                        'md',
                        'doc',
                        'docx',
                        'jpg',
                        'jpeg',
                        'png',
                        'gif',
                      ],
                    );
                    if (result == null || result.files.isEmpty) return;
                    final file = result.files.first;
                    await _importResource(db: db, file: file);
                  },
                  child: const Icon(Icons.attach_file),
                ),
              ],
            )
          : null,
      body: dbAsync.when(
        data:
            (db) => FutureBuilder<List<ResourceModel>>(
              future: _loadResources(db),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data!;

                final customNotes =
                    items.where((r) => r.folder == 'Custom Notes').toList();
                final otherResources =
                    items.where((r) => r.folder != 'Custom Notes').toList();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.folder_special, color: Colors.purple),
                        const SizedBox(width: 8),
                        Text(
                          'Custom Notes',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _showCreateFolderDialog,
                          icon: const Icon(Icons.create_new_folder),
                          label: const Text('New Folder'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (customNotes.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No custom notes yet. Import documents or create folders to get started.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      )
                    else
                      ...customNotes.map(
                        (item) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple[100],
                              child: const Icon(
                                Icons.note,
                                color: Colors.purple,
                              ),
                            ),
                            title: Text(item.title),
                            subtitle: Text(
                              item.folder ?? 'Custom Notes',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.visibility, size: 20),
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(
                                  context,
                                );
                                final file = File(item.localPath);
                                if (!await file.exists()) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('File not found'),
                                    ),
                                  );
                                  return;
                                }
                                if (!context.mounted) return;
                                if (item.type.toLowerCase() == 'pdf') {
                                  final router = GoRouter.of(context);
                                  router.push('/pdf', extra: {
                                    'path': item.localPath,
                                    'title': item.title,
                                  });
                                } else {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Opening: ${item.localPath}',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    const Divider(height: 32),
                    Text(
                      'Other Resources',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (otherResources.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No other resources yet.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      )
                    else
                      ...otherResources.map((item) {
                        final isImage =
                            item.type.toLowerCase().endsWith('jpg') ||
                            item.type.toLowerCase().endsWith('jpeg') ||
                            item.type.toLowerCase().endsWith('png') ||
                            item.type.toLowerCase().endsWith('gif');
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  isImage ? Colors.purple : Colors.blue,
                              child: Icon(
                                isImage ? Icons.image : Icons.picture_as_pdf,
                              ),
                            ),
                            title: Text(item.title),
                            subtitle: Text(item.folder ?? 'General'),
                            trailing: IconButton(
                              icon: const Icon(Icons.visibility, size: 20),
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(
                                  context,
                                );
                                final file = File(item.localPath);
                                if (!await file.exists()) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('File not found'),
                                    ),
                                  );
                                  return;
                                }
                                if (!context.mounted) return;
                                if (isImage) {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (ctx) => ImagePreviewScreen(
                                            path: item.localPath,
                                          ),
                                    ),
                                  );
                                  if (!context.mounted) return;
                                } else if (item.type.toLowerCase() == 'pdf') {
                                  if (!context.mounted) return;
                                  final router = GoRouter.of(context);
                                  router.push('/pdf', extra: {
                                    'path': item.localPath,
                                    'title': item.title,
                                  });
                                } else {
                                  if (!context.mounted) return;
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Opening: ${item.localPath}',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      }),
                  ],
                );
              },
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Something went wrong. Please try again.')),
      ),
    );
  }

  Future<List<ResourceModel>> _loadResources(DatabaseRepository db) async {
    final resources = await db.getAllResources();
    resources.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return resources;
  }
}

class ImagePreviewScreen extends StatelessWidget {
  final String path;
  const ImagePreviewScreen({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Preview')),
      body: Center(
        child: InteractiveViewer(child: Image.file(File(path), fit: BoxFit.contain)),
      ),
    );
  }
}

class _ResourceMeta {
  final String? folder;
  final List<String> tags;

  const _ResourceMeta({this.folder, this.tags = const []});
}
