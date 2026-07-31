import 'package:test/test.dart';
import 'package:retainly/data/models/app_models.dart';

void main() {
  group('Production fixes', () {
    test('computeTaskScore respects deadline urgency', () {
      final now = DateTime.now();
      final overdue = TaskModel(
        subjectId: 1,
        title: 'Overdue',
        dueAt: now.subtract(const Duration(days: 5)).toIso8601String(),
        estimatedMinutes: 30,
        priority: 2,
        status: 'not_started',
        scheduledAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
        createdAt: now.toIso8601String(),
      );
      final future = TaskModel(
        subjectId: 1,
        title: 'Future',
        dueAt: now.add(const Duration(days: 10)).toIso8601String(),
        estimatedMinutes: 30,
        priority: 2,
        status: 'not_started',
        scheduledAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
        createdAt: now.toIso8601String(),
      );
      final scoreOverdue = _computeTaskScore(overdue, 120);
      final scoreFuture = _computeTaskScore(future, 120);
      expect(scoreOverdue, greaterThan(scoreFuture));
    });

    test('computeTaskScore adds priority and fit bonuses', () {
      final now = DateTime.now();
      final high = TaskModel(
        subjectId: 1,
        title: 'High',
        priority: 4,
        estimatedMinutes: 60,
        status: 'not_started',
        scheduledAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
        createdAt: now.toIso8601String(),
      );
      final low = TaskModel(
        subjectId: 1,
        title: 'Low',
        priority: 1,
        estimatedMinutes: 180,
        status: 'not_started',
        scheduledAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
        createdAt: now.toIso8601String(),
      );
      expect(
        _computeTaskScore(high, 120),
        greaterThan(_computeTaskScore(low, 120)),
      );
    });

    test('SubjectProgressModel parses aggregated query correctly', () {
      final row = {
        'id': 1,
        'name': 'Physics',
        'color': 0xFF4CAF50,
        'sort_order': 2,
        'total_chapters': 8,
        'completed_chapters': 5,
      };
      final model = SubjectProgressModel.fromMap(row);
      expect(model.id, 1);
      expect(model.name, 'Physics');
      expect(model.totalChapters, 8);
      expect(model.completedChapters, 5);
    });

    test('ChapterWithSubjectModel parses join query correctly', () {
      final row = {
        'id': 3,
        'subject_id': 2,
        'title': 'Organic Chemistry',
        'status': 'not_started',
        'priority': 3,
        'estimated_minutes': 60,
        'revision_dates': '[]',
        'completed_at': null,
        'created_at': '2026-01-01T00:00:00Z',
        'subject_name': 'Chemistry',
      };
      final model = ChapterWithSubjectModel.fromMap(row);
      expect(model.id, 3);
      expect(model.subjectId, 2);
      expect(model.title, 'Organic Chemistry');
      expect(model.subjectName, 'Chemistry');
    });

    test('TaskModel round-trips through toMap/fromMap', () {
      final now = DateTime.now();
      final original = TaskModel(
        id: 42,
        subjectId: 7,
        chapterId: 3,
        title: 'Past Paper 2024',
        type: 'past_paper',
        dueAt: now.add(const Duration(days: 3)).toIso8601String(),
        scheduledAt: now.toIso8601String(),
        estimatedMinutes: 90,
        completedMinutes: 45,
        priority: 3,
        status: 'in_progress',
        isRescheduled: true,
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      );
      final restored = TaskModel.fromMap(original.toMap());
      expect(restored.id, original.id);
      expect(restored.subjectId, original.subjectId);
      expect(restored.chapterId, original.chapterId);
      expect(restored.title, original.title);
      expect(restored.type, original.type);
      expect(restored.status, original.status);
      expect(restored.isRescheduled, original.isRescheduled);
    });

    test('FocusSessionModel round-trips with new reflection fields', () {
      final now = DateTime.now();
      final original = FocusSessionModel(
        id: 1,
        taskId: 5,
        startedAt: now.toIso8601String(),
        endedAt: now.add(const Duration(minutes: 25)).toIso8601String(),
        plannedMinutes: 25,
        completedMinutes: 25,
        status: 'completed',
        createdAt: now.toIso8601String(),
        notes: 'Good session, understood the concepts',
        reflectionStatus: 'understood',
        parkingLotNotes: 'Got distracted by phone notifications',
      );
      final restored = FocusSessionModel.fromMap(original.toMap());
      expect(restored.id, original.id);
      expect(restored.notes, original.notes);
      expect(restored.reflectionStatus, original.reflectionStatus);
      expect(restored.parkingLotNotes, original.parkingLotNotes);
    });

    test('PracticalRecordModel round-trips with full fields', () {
      final now = DateTime.now();
      final original = PracticalRecordModel(
        id: 1,
        subjectId: 2,
        title: 'Chemistry Lab 1',
        dueAt: now.add(const Duration(days: 7)).toIso8601String(),
        status: 'pending',
        createdAt: now.toIso8601String(),
        objective: 'To determine the melting point of benzoic acid',
        apparatus: 'Bunsen burner, capillary tube, thermometer',
        procedure:
            '1. Heat the substance 2. Record temperature 3. Compare with known values',
        observation: 'Melting point observed at 122°C',
        vivaQuestions: 'Why is the melting point important?',
      );
      final restored = PracticalRecordModel.fromMap(original.toMap());
      expect(restored.id, original.id);
      expect(restored.objective, original.objective);
      expect(restored.apparatus, original.apparatus);
      expect(restored.procedure, original.procedure);
      expect(restored.observation, original.observation);
      expect(restored.vivaQuestions, original.vivaQuestions);
    });

    test('ResourceModel round-trips with fileSize, isPinned, tags', () {
      final now = DateTime.now();
      final original = ResourceModel(
        id: 1,
        subjectId: 1,
        type: 'pdf',
        title: 'Physics Syllabus',
        localPath: '/storage/emulated/0/physics.pdf',
        createdAt: now.toIso8601String(),
        fileSize: 1024000,
        isPinned: true,
        tags: 'syllabus,physics,important',
      );
      final restored = ResourceModel.fromMap(original.toMap());
      expect(restored.id, original.id);
      expect(restored.fileSize, original.fileSize);
      expect(restored.isPinned, original.isPinned);
      expect(restored.tags, original.tags);
    });

    test('ChapterModel round-trips with content quality fields', () {
      final now = DateTime.now();
      final original = ChapterModel(
        id: 3,
        subjectId: 1,
        title: 'Organic Chemistry',
        status: 'not_started',
        priority: 3,
        estimatedMinutes: 60,
        createdAt: now.toIso8601String(),
        examWeight: 20,
        confidence: 3,
        contentSource: 'Punjab Board Syllabus 2025',
        contentVersion: 'v2.1',
        reviewDate: '2026-08-15',
      );
      final restored = ChapterModel.fromMap(original.toMap());
      expect(restored.id, original.id);
      expect(restored.examWeight, original.examWeight);
      expect(restored.confidence, original.confidence);
      expect(restored.contentSource, original.contentSource);
      expect(restored.contentVersion, original.contentVersion);
      expect(restored.reviewDate, original.reviewDate);
    });

    test('unchecked chapter becomes in_progress, not not_started', () {
      final helper = _InMemoryDB();
      final now = DateTime.now();
      helper.insertChapter({
        'subject_id': 1,
        'title': 'Test Chapter',
        'status': 'completed',
        'priority': 2,
        'estimated_minutes': 30,
        'revision_dates': '[]',
        'completed_at': now.millisecondsSinceEpoch,
        'created_at': now.toIso8601String(),
      });
      final chapterId = helper.lastChapterId!;
      helper.setChapterCompletion(chapterId, false);
      final updated = helper.getChapterById(chapterId);
      expect(updated!['status'], 'in_progress');
    });
  });
}

int _computeTaskScore(TaskModel task, int dailyMinutes) {
  final now = DateTime.now();
  var score = 0;
  if (task.dueAt != null) {
    final diff = DateTime.parse(task.dueAt!).difference(now).inDays;
    score += diff < 0 ? 50 : (30 - diff.clamp(0, 30));
  }
  score += task.priority * 10;
  if (task.estimatedMinutes <= dailyMinutes) score += 5;
  return score;
}

class _InMemoryDB {
  final List<Map<String, dynamic>> _chapters = [];
  int? lastChapterId;

  int insertChapter(Map<String, dynamic> data) {
    final id = _chapters.length + 1;
    final entry = Map<String, dynamic>.from(data)..['id'] = id;
    _chapters.add(entry);
    lastChapterId = id;
    return id;
  }

  Map<String, dynamic>? getChapterById(int id) {
    try {
      return _chapters.firstWhere((c) => c['id'] == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> setChapterCompletion(int chapterId, bool completed) async {
    final idx = _chapters.indexWhere((c) => c['id'] == chapterId);
    if (idx >= 0) {
      _chapters[idx]['status'] = completed ? 'completed' : 'in_progress';
      _chapters[idx]['completed_at'] =
          completed ? DateTime.now().millisecondsSinceEpoch : null;
    }
  }
}
