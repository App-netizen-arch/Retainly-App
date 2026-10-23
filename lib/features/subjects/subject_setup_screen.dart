import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/database_provider.dart';
import '../../data/models/app_models.dart';
import '../../core/constants/matric_subjects.dart';

class SubjectSetupScreen extends ConsumerStatefulWidget {
  const SubjectSetupScreen({super.key});

  @override
  ConsumerState<SubjectSetupScreen> createState() => _SubjectSetupScreenState();
}

class _SubjectSetupScreenState extends ConsumerState<SubjectSetupScreen> {
  String? _academicGroup;
  String? _religion;
  List<String> _selectedElectives = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with default values
    _academicGroup = 'Science (Biology Group)';
    _religion = 'Muslim';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subject Setup')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildContent(),
              ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const Text(
          'Academic Group',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _academicGroup,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items:
              MatricSubjects.electiveGroups.keys
                  .map(
                    (group) =>
                        DropdownMenuItem(value: group, child: Text(group)),
                  )
                  .toList(),
          onChanged: (value) {
            setState(() {
              _academicGroup = value;
              _selectedElectives = [];
            });
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Religion',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ChoiceChip(
              label: const Text('Muslim'),
              selected: _religion == 'Muslim',
              onSelected: (selected) {
                if (selected) setState(() => _religion = 'Muslim');
              },
            ),
            const SizedBox(width: 12),
            ChoiceChip(
              label: const Text('Non-Muslim'),
              selected: _religion == 'Non-Muslim',
              onSelected: (selected) {
                if (selected) setState(() => _religion = 'Non-Muslim');
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Elective Subjects',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Select your elective subjects:',
          style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              (MatricSubjects.electiveGroups[_academicGroup] ?? [])
                  .map(
                    (subject) => FilterChip(
                      label: Text(subject['name']!),
                      selected: _selectedElectives.contains(subject['name']),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedElectives.add(subject['name']!);
                          } else {
                            _selectedElectives.remove(subject['name']!);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedElectives.isNotEmpty ? _saveSubjects : null,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Save Subjects'),
          ),
        ),
      ],
    ),
  );
}

  Future<void> _saveSubjects() async {
    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseRepositoryProvider).value;
      if (db == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Database not available')),
          );
        }
        return;
      }

      final now = DateTime.now();

      // Build the subject list
      final List<Map<String, String>> allSubjects = [];

      // Add compulsory subjects
      allSubjects.addAll(MatricSubjects.compulsorySubjects);

      // Add Islamiyat or Ethics based on religion
      if (_religion == 'Muslim') {
        allSubjects.add({'id': 'islamiat', 'name': 'Islamiyat'});
      } else {
        allSubjects.add({'id': 'ethics', 'name': 'Ethics'});
      }

      // Add selected electives
      final selectedElectives =
          MatricSubjects.electiveGroups[_academicGroup]!
              .where((subject) => _selectedElectives.contains(subject['name']!))
              .toList();
      allSubjects.addAll(selectedElectives);

      // Preserve subject identities and history. Unselected subjects are
      // archived, not deleted, because chapters/tasks/revisions reference them.
      final existingSubjects = await db.getAllSubjects();
      final selectedByName = <String, Map<String, String>>{
        for (final subject in allSubjects)
          subject['name']!.trim().toLowerCase(): subject,
      };
      final keptNames = <String>{};

      for (final existing in existingSubjects) {
        final id = existing.id;
        if (id == null) continue;
        final key = existing.name.trim().toLowerCase();
        final selected = selectedByName[key];
        await db.setSubjectActive(id, selected != null);
        if (selected == null) continue;

        final index = allSubjects.indexWhere(
          (subject) => subject['name']!.trim().toLowerCase() == key,
        );
        await db.updateSubject(
          id,
          SubjectModel(
            id: id,
            name: selected['name']!,
            color: _getColorForSubject(selected['name']!),
            sortOrder: index < 0 ? existing.sortOrder : index,
            createdAt: existing.createdAt,
          ),
        );
        keptNames.add(key);
      }

      // Only create a record if this subject has never existed on this device.
      for (int i = 0; i < allSubjects.length; i++) {
        final subject = allSubjects[i];
        final name = subject['name']!.trim().toLowerCase();
        if (keptNames.contains(name)) continue;
        await db.insertSubject(
          SubjectModel(
            name: subject['name']!,
            color: _getColorForSubject(subject['name']!),
            sortOrder: i,
            createdAt: now.toIso8601String(),
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subjects updated successfully!')),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted && GoRouter.of(context).canPop()) {
          GoRouter.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving subjects. Please try again.')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _getColorForSubject(String subjectName) {
    for (final subject in MatricSubjects.subjects) {
      if (subject['name'] == subjectName) {
        return subject['color'] as int;
      }
    }
    return 0xFF757575;
  }
}
