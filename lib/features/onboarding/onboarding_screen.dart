import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/database_provider.dart';
import '../../data/models/app_models.dart';
import '../../core/constants/matric_subjects.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  String? _academicGroup;
  String? _religion;
  String? _classLevel;
  String? _board;
  DateTime? _examDate;
  final int _dailyMinutes = 120;
  final String _studentName = '';
  final String _studentId = '';
  final String _institution = '';
  final List<String> _selectedElectives = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Step ${_step + 1}/4',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildStepContent(),
            ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildAcademicGroupSelection();
      case 1:
        return _buildReligionSelection();
      case 2:
        return _buildElectiveSelection();
      case 3:
        return _buildSubjectSummary();
      default:
        return const SizedBox.shrink(); // Should not happen
    }
  }

  Widget _buildAcademicGroupSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Your Academic Group',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        RadioGroup<String>(
          groupValue: _academicGroup,
          onChanged: (value) {
            setState(() {
              _academicGroup = value;
            });
          },
          child: Column(
            children: MatricSubjects.electiveGroups.keys
                .map(
                  (group) => RadioListTile<String>(
                    title: Text(group),
                    value: group,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 32),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _academicGroup != null
                ? () => setState(() => _step = 1)
                : null,
            child: const Text('Next'),
          ),
        ),
      ],
    );
  }

  Widget _buildReligionSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Your Religion',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        const Text(
          'This determines whether you will study Islamiyat or Ethics.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        RadioGroup<String>(
          groupValue: _religion,
          onChanged: (value) {
            setState(() {
              _religion = value;
            });
          },
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text('Muslim (Islamiyat)'),
                value: 'Muslim',
              ),
              RadioListTile<String>(
                title: const Text('Non-Muslim (Ethics)'),
                value: 'Non-Muslim',
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() => _step = 0),
              child: const Text('Back'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _religion != null
                  ? () => setState(() => _step = 2)
                  : null,
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildElectiveSelection() {
    final electives = MatricSubjects.electiveGroups[_academicGroup] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Elective Subjects',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          'Choose 2-3 elective subjects based on your academic group:',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: electives.map((subject) => ChoiceChip(
                label: Text(subject['name']!),
                selected: _selectedElectives.contains(subject['name']),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedElectives.add(subject['name']!);
                    } else {
                      _selectedElectives.remove(subject['name']);
                    }
                  });
                },
              )).toList(),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() => _step = 1),
              child: const Text('Back'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _selectedElectives.isNotEmpty
                  ? () => setState(() => _step = 3)
                  : null,
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubjectSummary() {
    // Build compulsory subjects based on religion
    final List<Map<String, String>> compulsoryWithReligion = List.from(MatricSubjects.compulsorySubjects);
    
    // Add Islamiyat or Ethics based on religion
    if (_religion == 'Muslim') {
      compulsoryWithReligion.add({'id': 'islamiat', 'name': 'Islamiyat'});
    } else {
      compulsoryWithReligion.add({'id': 'ethics', 'name': 'Ethics'});
    }
    
    // Get selected elective subjects
    final List<Map<String, String>> selectedElectives = 
        MatricSubjects.electiveGroups[_academicGroup]!
            .where((subject) => _selectedElectives.contains(subject['name']!))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Subject Selection',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        const Text(
          'Compulsory Subjects:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...compulsoryWithReligion.map((subject) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(subject['name']!)),
                ],
              ),
            )),
        const SizedBox(height: 24),
        const Text(
          'Elective Subjects:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...selectedElectives.map((subject) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(subject['name']!)),
                ],
              ),
            )),
        if (selectedElectives.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'No electives selected',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : () => _saveSubjectSelection(
              compulsoryWithReligion, selectedElectives, context),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Start Studying'),
        ),
      ],
    );
  }

  Future<void> _saveSubjectSelection(
      List<Map<String, String>> compulsorySubjects,
      List<Map<String, String>> electiveSubjects,
      BuildContext context) async {
    setState(() => _isLoading = true);
    
    try {
      final db = ref.read(databaseRepositoryProvider).value;
      if (db == null) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Database not available')),
          );
        }
        return;
      }

      final now = DateTime.now();
      final examDate = _examDate ?? now.add(const Duration(days: 180));
      
      // Create or update user profile
      await db.createUserProfile(
        UserModel(
          studentName: _studentName.isNotEmpty ? _studentName : 'Student',
          studentId: _studentId,
          institution: _institution,
          classLevel: _classLevel ?? '10',
          board: _board ?? 'Punjab Board',
          examDate: examDate.toIso8601String(),
          dailyStudyMinutes: _dailyMinutes,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        ),
      );

      // Clear existing subjects and insert the selected ones
      final existingSubjects = await db.getSubjects();
      for (final subject in existingSubjects) {
        if (subject.id != null) {
          await db.deleteSubject(subject.id!);
        }
      }
      
      // Insert compulsory subjects
      for (final subject in compulsorySubjects) {
        await db.insertSubject(
          SubjectModel(
            name: subject['name']!,
            color: _getColorForSubject(subject['name']!),
            sortOrder: 0,
            createdAt: now.toIso8601String(),
          ),
        );
      }
      
      // Insert elective subjects
      for (int i = 0; i < electiveSubjects.length; i++) {
        final subject = electiveSubjects[i];
        await db.insertSubject(
          SubjectModel(
            name: subject['name']!,
            color: _getColorForSubject(subject['name']!),
            sortOrder: i + 1,
            createdAt: now.toIso8601String(),
          ),
        );
      }

      if (context.mounted) {
        ref.invalidate(userProfileProvider);
        await ref.read(userProfileProvider.future);
        if (!context.mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subjects saved successfully!'),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (!context.mounted) return;
        GoRouter.of(context).go('/');
      }
    } catch (e) {
      if (!context.mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving subjects: $e')),
      );
    } finally {
      if (context.mounted) setState(() => _isLoading = false);
    }
  }

  int _getColorForSubject(String subjectName) {
    // Find the color for the subject name from MatricSubjects
    for (final subject in MatricSubjects.subjects) {
      if (subject['name'] == subjectName) {
        return subject['color'] as int;
      }
    }
    // Default color if not found
    return 0xFF757575;
  }
}