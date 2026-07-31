import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/database_provider.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/database_repository.dart';

class PracticalRecordsScreen extends ConsumerWidget {
  const PracticalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbAsync = ref.watch(databaseRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Practical Records')),
      body: dbAsync.when(
        data:
            (db) => FutureBuilder<List<SubjectModel>>(
              future: db.getSubjects(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final subjects = snapshot.data!;
                if (subjects.isEmpty) {
                  return const Center(child: Text('No subjects found. Add subjects first.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(subject.color),
                          child: const Icon(Icons.science),
                        ),
                        title: Text(subject.name),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          if (subject.id == null) return;
                          showDialog(
                            context: context,
                            builder:
                                (context) =>
                                    _PracticalDialog(subjectId: subject.id!),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Something went wrong. Please try again.')),
      ),
    );
  }
}

class _PracticalDialog extends ConsumerStatefulWidget {
  final int subjectId;

  const _PracticalDialog({required this.subjectId});

  @override
  ConsumerState<_PracticalDialog> createState() => _PracticalDialogState();
}

class _PracticalDialogState extends ConsumerState<_PracticalDialog> {
  late TextEditingController _titleController;
  late TextEditingController _objectiveController;
  late TextEditingController _apparatusController;
  late TextEditingController _procedureController;
  late TextEditingController _observationController;
  late TextEditingController _vivaController;
  String _status = 'pending';
  DateTime? _dueAt;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _objectiveController = TextEditingController();
    _apparatusController = TextEditingController();
    _procedureController = TextEditingController();
    _observationController = TextEditingController();
    _vivaController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _objectiveController.dispose();
    _apparatusController.dispose();
    _procedureController.dispose();
    _observationController.dispose();
    _vivaController.dispose();
    super.dispose();
  }

  Future<void> _addPractical(DatabaseRepository db) async {
    if (_titleController.text.isEmpty) return;
    await db.insertPracticalRecord(
      PracticalRecordModel(
        subjectId: widget.subjectId,
        title: _titleController.text.trim(),
        status: _status,
        dueAt: _dueAt?.toIso8601String(),
        objective:
            _objectiveController.text.trim().isEmpty
                ? null
                : _objectiveController.text.trim(),
        apparatus:
            _apparatusController.text.trim().isEmpty
                ? null
                : _apparatusController.text.trim(),
        procedure:
            _procedureController.text.trim().isEmpty
                ? null
                : _procedureController.text.trim(),
        observation:
            _observationController.text.trim().isEmpty
                ? null
                : _observationController.text.trim(),
        vivaQuestions:
            _vivaController.text.trim().isEmpty
                ? null
                : _vivaController.text.trim(),
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
    _titleController.clear();
    _objectiveController.clear();
    _apparatusController.clear();
    _procedureController.clear();
    _observationController.clear();
    _vivaController.clear();
    setState(() {
      _status = 'pending';
      _dueAt = null;
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dbAsync = ref.watch(databaseRepositoryProvider);
    return AlertDialog(
      title: const Text('Add Practical Record'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<List<PracticalRecordModel>>(
              future:
                  dbAsync.value != null
                      ? dbAsync.value!.getPracticalRecordsBySubject(
                        widget.subjectId,
                      )
                      : Future.value(const []),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final records = snapshot.data!;
                return Column(
                  children: [
                    ...records.map(
                      (r) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          title: Text(r.title),
                          subtitle: Text('Status: ${r.status}'),
                          children: [
                            if (r.objective != null)
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text('Objective: ${r.objective}'),
                              ),
                            if (r.apparatus != null)
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text('Apparatus: ${r.apparatus}'),
                              ),
                            if (r.procedure != null)
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text('Procedure: ${r.procedure}'),
                              ),
                            if (r.observation != null)
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text('Observation: ${r.observation}'),
                              ),
                            if (r.vivaQuestions != null)
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text('Viva: ${r.vivaQuestions}'),
                              ),
                            if (r.dueAt != null)
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text('Due: ${r.dueAt}'),
                              ),
                            StatefulBuilder(
                              builder:
                                  (
                                    ctx,
                                    setDialogState,
                                  ) => DropdownButtonFormField<String>(
                                    initialValue: r.status,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'pending',
                                        child: Text('Pending'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'completed',
                                        child: Text('Completed'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'missing',
                                        child: Text('Missing'),
                                      ),
                                    ],
                                    onChanged: (v) async {
                                      if (v == null || r.id == null) return;
                                      try {
                                        final db = dbAsync.value;
                                        if (db != null) {
                                          await db.updatePracticalStatus(
                                            r.id!,
                                            v,
                                          );
                                        }
                                        setDialogState(() {});
                                      } on Exception catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to update: ${e.toString()}',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Practical title',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _objectiveController,
                      decoration: const InputDecoration(labelText: 'Objective'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _apparatusController,
                      decoration: const InputDecoration(
                        labelText: 'Apparatus / Materials',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _procedureController,
                      decoration: const InputDecoration(
                        labelText: 'Procedure checklist',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _observationController,
                      decoration: const InputDecoration(
                        labelText: 'Observation / Result',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _vivaController,
                      decoration: const InputDecoration(
                        labelText: 'Viva questions',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
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
                        decoration: const InputDecoration(
                          labelText: 'Due date',
                        ),
                        child: Text(
                          _dueAt == null
                              ? 'Optional'
                              : DateFormat('MMM d, y').format(_dueAt!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      items: const [
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('Completed'),
                        ),
                        DropdownMenuItem(
                          value: 'missing',
                          child: Text('Missing'),
                        ),
                      ],
                      onChanged:
                          (v) => setState(() => _status = v ?? 'pending'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () async {
            final db = dbAsync.value;
            if (db != null) await _addPractical(db);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
