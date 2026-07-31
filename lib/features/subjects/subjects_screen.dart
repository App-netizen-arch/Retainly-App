import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/database_provider.dart';
import '../../data/models/app_models.dart';
import '../../services/ai_service.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final dbAsync = ref.watch(databaseRepositoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => _showAISidebar(context),
            tooltip: 'AI Assistant',
          ),
        ],
      ),
      body: dbAsync.when(
        data: (db) => FutureBuilder<List<ResourceModel>>(
          future: db.getAllResources(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final allResources = snapshot.data!;
            final customNotes = allResources
                .where((r) => r.folder == 'Custom Notes')
                .toList();
            final subjects = db.getSubjects();

            return FutureBuilder<List<SubjectModel>>(
              future: subjects,
              builder: (context, subjectSnapshot) {
                final subjectList = subjectSnapshot.data ?? [];

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Custom Notes folder - always visible
                    Row(
                      children: [
                        const Icon(
                          Icons.folder_special,
                          color: Colors.purple,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Custom Notes',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (customNotes.isEmpty)
                      Card(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No custom notes yet. Import documents from Settings to add notes here.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      )
                    else
                      ...customNotes.map(
                        (note) => Card(
                          margin: const EdgeInsets.only(bottom: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple[100],
                              child: Icon(
                                _getIconForType(note.type),
                                color: Colors.purple,
                                size: 20,
                              ),
                            ),
                            title: Text(note.title),
                            subtitle: Text(
                              '${note.type.toUpperCase()} • ${_formatDate(note.createdAt)}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.visibility, size: 18),
                              onPressed: () => _openNote(context, note),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    // Subjects section
                    Row(
                      children: [
                        const Icon(Icons.book, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Subjects',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            GoRouter.of(context).push('/subjects/setup');
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (subjectList.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextButton.icon(
                            onPressed: () {
                              GoRouter.of(context).push('/subjects/setup');
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Setup Subjects'),
                          ),
                        ),
                      )
                    else
                      ...subjectList.map((subject) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color(subject.color),
                              child: const Icon(
                                Icons.book,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            title: Text(subject.name),
                            trailing: const Icon(Icons.chevron_right),
                            onTap:
                                () => GoRouter.of(
                                  context,
                                ).push('/subjects/${subject.id}'),
                          ),
                        );
                      }),
                  ],
                );
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  IconData _getIconForType(String type) {
    final lower = type.toLowerCase();
    if (lower.endsWith('pdf')) return Icons.picture_as_pdf;
    if (lower.endsWith('jpg') || lower.endsWith('jpeg') || lower.endsWith('png') || lower.endsWith('gif')) return Icons.image;
    if (lower == 'txt' || lower == 'md') return Icons.text_snippet;
    return Icons.attach_file;
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } on Exception {
      return '';
    }
  }

  Future<void> _openNote(BuildContext context, ResourceModel note) async {
    final file = File(note.localPath);
    if (!await file.exists()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File not found')),
        );
      }
      return;
    }
    final lowerType = note.type.toLowerCase();
    if (!context.mounted) return;
    if (lowerType == 'pdf') {
      final router = GoRouter.of(context);
      router.push('/pdf', extra: {'path': note.localPath, 'title': note.title});
    } else if (lowerType.endsWith('jpg') || lowerType.endsWith('jpeg') || lowerType.endsWith('png') || lowerType.endsWith('gif')) {
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => ImagePreviewScreen(path: note.localPath),
        ),
      );
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opening: ${note.localPath}')),
      );
    }
  }


  Future<void> _showAISidebar(BuildContext context) async {
    final service = AIService();
    final answer = await service.askAiAboutSubject(
      'local_user',
      'Help me organize my study notes. Suggest categories for my subjects and notes.',
    );
    if (!context.mounted) return;
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
