import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/feature_flags.dart';
import '../../core/utils/ai_utils.dart';
import '../../providers/database_provider.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/database_repository.dart';
import '../../services/ai_service.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  const AddTaskScreen({super.key});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _subjectId;
  String _title = '';
  int _estimatedMinutes = 30;
  int _priority = 2;
  DateTime? _dueAt;
  String _type = 'custom';
  bool _aiBreakdownLoading = false;
  String? _aiBreakdownError;
  List<String> _subTasks = [];
  final Set<int> _selectedSubTasks = {};

  Future<List<SubjectModel>> _loadSubjects(DatabaseRepository db) async {
    return db.getSubjects();
  }

  void _applyTemplate(String title, String type, int minutes, int priority) {
    setState(() {
      _title = title;
      _type = type;
      _estimatedMinutes = minutes;
      _priority = priority;
    });
  }

  Future<void> _runAiBreakdown() async {
    if (!FeatureFlags.aiAssistance) {
      setState(
        () => _aiBreakdownError = 'AI assistance is disabled in Settings.',
      );
      return;
    }
    if (_title.trim().isEmpty) {
      setState(() => _aiBreakdownError = 'Enter a task title first.');
      return;
    }
    try {
      final service = AIService();
      final gate = await service.checkAiGate('local_user');
      if (gate != null) {
        setState(() => _aiBreakdownError = gate);
        return;
      }
    } on Exception catch (_) {
      setState(() => _aiBreakdownError = 'Unable to verify AI readiness. Please retry.');
      return;
    }
    setState(() {
      _aiBreakdownLoading = true;
      _aiBreakdownError = null;
      _subTasks = [];
      _selectedSubTasks.clear();
    });
    final service = AIService();
    final userId = 'local_user';
    try {
      final result = await service.generateTaskBreakdown(userId, _title.trim());
      if (!mounted) return;
      if (result == null || result.startsWith('AI_ERROR:')) {
        final message = result != null && result.startsWith('AI_ERROR:')
            ? result.substring('AI_ERROR:'.length).trim()
            : result;
        setState(
          () => _aiBreakdownError = message ?? 'No result from AI service.',
        );
        return;
      }

      final parsed = <String>[];
      for (final line in result.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        final cleaned = SubTaskCleaner.clean(trimmed);
        if (cleaned.isNotEmpty) {
          parsed.add(cleaned);
        }
      }

      final safeParsed = parsed.isNotEmpty ? parsed : ['No sub-tasks could be parsed from the AI response.'];
      setState(() {
        _subTasks = safeParsed;
        _aiBreakdownLoading = false;
        _selectedSubTasks.clear();
        if (parsed.isNotEmpty) {
          _selectedSubTasks.addAll(
            List.generate(parsed.length, (i) => i),
          );
        }
      });
                         } on Exception catch (_) {
      if (!mounted) return;
      setState(() {
         _aiBreakdownError = 'Breakdown failed. Please try again.';
        _aiBreakdownLoading = false;
      });
    }
  }

  void _saveSubTasks(DatabaseRepository db) async {
    if (_selectedSubTasks.isEmpty) return;
    if (_subjectId == null) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Please select a subject before saving sub-tasks.'),
        ),
      );
      return;
    }
    for (final index in _selectedSubTasks) {
      if (index < 0 || index >= _subTasks.length) continue;
      final subTitle = _subTasks[index];
      final task = TaskModel(
        subjectId: _subjectId!,
        chapterId: null,
        title: subTitle,
        type: _type,
        dueAt: _dueAt?.toIso8601String(),
        scheduledAt: DateTime.now().toIso8601String(),
        estimatedMinutes: (_estimatedMinutes / _subTasks.length).round().clamp(
          5,
          120,
        ),
        priority: _priority,
        status: 'not_started',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      try {
        await db.insertTask(task);
      } on Exception catch (_) {
        // Continue saving other tasks even if one fails
      }
    }
    if (mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Saved ${_selectedSubTasks.length} sub-task(s)'),
        ),
      );
      ref.invalidate(todayTasksProvider);
      ref.invalidate(dueRevisionsProvider);
      ref.invalidate(allPendingTasksProvider);
      if (GoRouter.of(context).canPop()) {
        GoRouter.of(context).pop();
      }
    }
  }

  static const _templates = <Map<String, dynamic>>[
    {
      'title': 'Past Paper Practice',
      'type': 'past_paper',
      'minutes': 60,
      'priority': 2,
    },
    {
      'title': 'Mid-year Exam Past Paper',
      'type': 'past_paper',
      'minutes': 90,
      'priority': 3,
    },
    {
      'title': 'Board Exam Past Paper',
      'type': 'past_paper',
      'minutes': 120,
      'priority': 4,
    },
    {
      'title': 'Homework Assignment',
      'type': 'homework',
      'minutes': 30,
      'priority': 2,
    },
    {
      'title': 'Lab Practical',
      'type': 'practical',
      'minutes': 45,
      'priority': 3,
    },
    {
      'title': 'Revision Session',
      'type': 'revision',
      'minutes': 30,
      'priority': 3,
    },
    {'title': 'Quick Recall', 'type': 'revision', 'minutes': 15, 'priority': 2},
    {'title': 'Essay Writing', 'type': 'custom', 'minutes': 45, 'priority': 3},
    {
      'title': 'Numerical Problems',
      'type': 'custom',
      'minutes': 40,
      'priority': 2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final dbAsync = ref.watch(databaseRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: dbAsync.when(
        data:
            (db) => Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  FutureBuilder<List<SubjectModel>>(
                    future: _loadSubjects(db),
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
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final subjects = snapshot.data!;
                      if (subjects.isEmpty) {
                        return const Text('No subjects found');
                      }
                      return DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'Subject'),
                        hint: const Text('Select a subject'),
                        items:
                            subjects.map((s) {
                              return DropdownMenuItem(
                                value: s.id,
                                child: Text(s.name),
                              );
                            }).toList(),
                        onChanged: (v) => setState(() => _subjectId = v),
                        validator: (v) => v == null ? 'Select subject' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Task title'),
                    validator:
                        (v) => v == null || v.isEmpty ? 'Enter title' : null,
                    onChanged: (v) => _title = v,
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'custom', label: Text('Custom')),
                      ButtonSegment(value: 'homework', label: Text('Homework')),
                      ButtonSegment(value: 'revision', label: Text('Revision')),
                      ButtonSegment(
                        value: 'past_paper',
                        label: Text('Past Paper'),
                      ),
                      ButtonSegment(
                        value: 'practical',
                        label: Text('Practical'),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (Set<String> selection) {
                      setState(() => _type = selection.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Templates',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _templates.map((t) {
                          return ElevatedButton(
                            onPressed:
                                () => _applyTemplate(
                                  t['title'] as String,
                                  t['type'] as String,
                                  t['minutes'] as int,
                                  t['priority'] as int,
                                ),
                            child: Text(t['title'] as String),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                  if (FeatureFlags.aiAssistance)
                    ElevatedButton.icon(
                      onPressed: _aiBreakdownLoading ? null : _runAiBreakdown,
                      icon:
                          _aiBreakdownLoading
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.auto_awesome),
                      label: const Text('AI Breakdown'),
                    ),
                  if (_aiBreakdownError != null) ...[
                    const SizedBox(height: 8),
                     Text(
                       _aiBreakdownError!,
                       style: TextStyle(
                         color: Theme.of(context).colorScheme.error,
                         fontSize: 13,
                       ),
                     ),
                  ],
                  if (_subTasks.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sub-tasks',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ..._subTasks.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final subTask = entry.value;
                              return CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(subTask),
                                value: _selectedSubTasks.contains(idx),
                                onChanged: (v) {
                                  setState(() {
                                    if (v == true) {
                                      _selectedSubTasks.add(idx);
                                    } else {
                                      _selectedSubTasks.remove(idx);
                                    }
                                  });
                                },
                              );
                            }),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed:
                                  _selectedSubTasks.isEmpty
                                      ? null
                                      : () => _saveSubTasks(db),
                              child: Text(
                                _selectedSubTasks.length == 1
                                    ? 'Save 1 Sub-task'
                                    : 'Save ${_selectedSubTasks.length} Sub-tasks',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Estimated minutes',
                      helperText: 'e.g., 30',
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: '30',
                    onChanged: (v) {
                      final parsed = int.tryParse(v);
                      _estimatedMinutes =
                          (parsed != null && parsed > 0) ? parsed : 30;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      helperText: 'Medium is recommended',
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Low')),
                      DropdownMenuItem(value: 2, child: Text('Medium')),
                      DropdownMenuItem(value: 3, child: Text('High')),
                      DropdownMenuItem(value: 4, child: Text('Urgent')),
                    ],
                    initialValue: _priority,
                    onChanged: (v) => setState(() => _priority = v ?? 2),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(
                          const Duration(days: 7),
                        ),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setState(() => _dueAt = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Due date'),
                      child: Text(
                        _dueAt == null
                            ? 'Optional'
                            : DateFormat('MMM d, y').format(_dueAt!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          _subjectId != null) {
                        final task = TaskModel(
                          subjectId: _subjectId!,
                          chapterId: null,
                          title: _title,
                          type: _type,
                          dueAt: _dueAt?.toIso8601String(),
                          scheduledAt: DateTime.now().toIso8601String(),
                          estimatedMinutes: _estimatedMinutes,
                          priority: _priority,
                          status: 'not_started',
                          createdAt: DateTime.now().toIso8601String(),
                          updatedAt: DateTime.now().toIso8601String(),
                        );
                        try {
                          await db.insertTask(task);
                          if (context.mounted) {
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.hideCurrentSnackBar();
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Task saved')),
                            );
                          }
                           ref.invalidate(todayTasksProvider);
                           ref.invalidate(dueRevisionsProvider);
                           ref.invalidate(allPendingTasksProvider);
                           if (context.mounted && GoRouter.of(context).canPop()) {
                             GoRouter.of(context).pop();
                           }
                        } on Exception catch (_) {
                          if (context.mounted) {
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.hideCurrentSnackBar();
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Failed to save task. Please try again.',
                                ),
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: const Text('Save Task'),
                  ),
                ],
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
