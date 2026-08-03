import 'package:test/test.dart';
import 'package:retainly/data/models/app_models.dart';

void main() {
  group('Adaptive estimates and learning loop', () {
    test('TaskModel round-trips with past paper and template flags', () {
      final now = DateTime.now();
      final original = TaskModel(
        id: 10,
        subjectId: 2,
        title: 'Physics Past Paper 2025',
        type: 'past_paper',
        scheduledAt: now.toIso8601String(),
        estimatedMinutes: 90,
        completedMinutes: 85,
        isPastPaper: true,
        isTemplate: false,
        status: 'completed',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      );
      final restored = TaskModel.fromMap(original.toMap());
      expect(restored.id, original.id);
      expect(restored.isPastPaper, original.isPastPaper);
      expect(restored.isTemplate, original.isTemplate);
      expect(restored.completedMinutes, original.completedMinutes);
    });

    test('TaskModel treats missing flags as false', () {
      final map = {
        'id': 1,
        'subject_id': 1,
        'title': 'Homework',
        'type': 'homework',
        'scheduled_at': DateTime.now().toIso8601String(),
        'estimated_minutes': 30,
        'completed_minutes': 0,
        'priority': 2,
        'status': 'not_started',
        'is_rescheduled': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      final task = TaskModel.fromMap(map);
      expect(task.isPastPaper, isFalse);
      expect(task.isTemplate, isFalse);
    });

    test('ChapterModel round-trips with is_weak_topic', () {
      final now = DateTime.now();
      final original = ChapterModel(
        id: 5,
        subjectId: 1,
        title: 'Trigonometry',
        status: 'in_progress',
        priority: 3,
        estimatedMinutes: 45,
        createdAt: now.toIso8601String(),
        confidence: 25,
        isWeakTopic: true,
      );
      final restored = ChapterModel.fromMap(original.toMap());
      expect(restored.id, original.id);
      expect(restored.confidence, original.confidence);
      expect(restored.isWeakTopic, original.isWeakTopic);
    });
  });
}
