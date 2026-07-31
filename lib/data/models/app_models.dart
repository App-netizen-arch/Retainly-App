class UserModel {
  final int? id;
  final String studentName;
  final String studentId;
  final String institution;
  final String classLevel;
  final String board;
  final String examDate;
  final int dailyStudyMinutes;
  final String theme;
  final String createdAt;
  final String updatedAt;

  UserModel({
    this.id,
    this.studentName = '',
    this.studentId = '',
    this.institution = '',
    required this.classLevel,
    required this.board,
    required this.examDate,
    this.dailyStudyMinutes = 120,
    this.theme = 'light',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_name': studentName,
      'student_id': studentId,
      'institution': institution,
      'class_level': classLevel,
      'board': board,
      'exam_date': examDate,
      'daily_study_minutes': dailyStudyMinutes,
      'theme': theme,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] is int ? map['id'] as int : null,
      studentName:
          map['student_name'] is String ? map['student_name'] as String : '',
      studentId: map['student_id'] is String ? map['student_id'] as String : '',
      institution:
          map['institution'] is String ? map['institution'] as String : '',
      classLevel:
          map['class_level'] is String ? map['class_level'] as String : '',
      board: map['board'] is String ? map['board'] as String : '',
      examDate: map['exam_date'] is String ? map['exam_date'] as String : '',
      dailyStudyMinutes:
          map['daily_study_minutes'] is int
              ? map['daily_study_minutes'] as int
              : 120,
      theme: map['theme'] is String ? map['theme'] as String : 'light',
      createdAt: map['created_at'] is String ? map['created_at'] as String : '',
      updatedAt: map['updated_at'] is String ? map['updated_at'] as String : '',
    );
  }
}

class SubjectModel {
  final int? id;
  final String name;
  final int color;
  final int sortOrder;
  final String createdAt;

  SubjectModel({
    this.id,
    required this.name,
    required this.color,
    required this.sortOrder,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'sort_order': sortOrder,
      'created_at': createdAt,
    };
  }

  static SubjectModel fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      id: map['id'] is int ? map['id'] as int : null,
      name: map['name'] is String ? map['name'] as String : '',
      color: map['color'] is int ? map['color'] as int : 0,
      sortOrder: map['sort_order'] is int ? map['sort_order'] as int : 0,
      createdAt: map['created_at'] is String ? map['created_at'] as String : '',
    );
  }
}

class ChapterModel {
  final int? id;
  final int subjectId;
  final String title;
  final String status;
  final int priority;
  final int estimatedMinutes;
  final String revisionDates;
  final int? completedAt;
  final String createdAt;
  final int? examWeight;
  final int? confidence;
  final String? contentSource;
  final String? contentVersion;
  final String? reviewDate;
  final bool isWeakTopic;
  final String contentTier;

  ChapterModel({
    this.id,
    required this.subjectId,
    required this.title,
    this.status = 'not_started',
    this.priority = 2,
    this.estimatedMinutes = 30,
    this.revisionDates = '[]',
    this.completedAt,
    required this.createdAt,
    this.examWeight,
    this.confidence,
    this.contentSource,
    this.contentVersion,
    this.reviewDate,
    this.isWeakTopic = false,
    this.contentTier = 'official',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_id': subjectId,
      'title': title,
      'status': status,
      'priority': priority,
      'estimated_minutes': estimatedMinutes,
      'revision_dates': revisionDates,
      'completed_at': completedAt,
      'created_at': createdAt,
      'exam_weight': examWeight,
      'confidence': confidence,
      'content_source': contentSource,
      'content_version': contentVersion,
      'review_date': reviewDate,
      'is_weak_topic': isWeakTopic ? 1 : 0,
      'content_tier': contentTier,
    };
  }

  static ChapterModel fromMap(Map<String, dynamic> map) {
    return ChapterModel(
      id: map['id'] is int ? map['id'] as int : null,
      subjectId: map['subject_id'] is int ? map['subject_id'] as int : 0,
      title: map['title'] is String ? map['title'] as String : '',
      status: map['status'] is String ? map['status'] as String : 'not_started',
      priority: map['priority'] is int ? map['priority'] as int : 2,
      estimatedMinutes:
          map['estimated_minutes'] is int
              ? map['estimated_minutes'] as int
              : 30,
      revisionDates:
          map['revision_dates'] is String
              ? map['revision_dates'] as String
              : '[]',
      completedAt:
          map['completed_at'] is int ? map['completed_at'] as int : null,
      createdAt: map['created_at'] is String ? map['created_at'] as String : '',
      examWeight: map['exam_weight'] is int ? map['exam_weight'] as int : null,
      confidence: map['confidence'] is int ? map['confidence'] as int : null,
      contentSource:
          map['content_source'] is String
              ? map['content_source'] as String
              : null,
      contentVersion:
          map['content_version'] is String
              ? map['content_version'] as String
              : null,
      reviewDate:
          map['review_date'] is String ? map['review_date'] as String : null,
      isWeakTopic:
          (map['is_weak_topic'] is int ? map['is_weak_topic'] as int : 0) == 1,
      contentTier:
          map['content_tier'] is String
              ? map['content_tier'] as String
              : 'official',
    );
  }
}

class TaskModel {
  final int? id;
  final int subjectId;
  final int? chapterId;
  final String title;
  final String type;
  final String? dueAt;
  final String scheduledAt;
  final int estimatedMinutes;
  final int completedMinutes;
  final int priority;
  final String status;
  final bool isRescheduled;
  final bool isPastPaper;
  final bool isTemplate;
  final String createdAt;
  final String updatedAt;
  final int? originalEstimatedMinutes;

  TaskModel({
    this.id,
    required this.subjectId,
    this.chapterId,
    required this.title,
    this.type = 'custom',
    this.dueAt,
    required this.scheduledAt,
    this.estimatedMinutes = 30,
    this.completedMinutes = 0,
    this.priority = 2,
    this.status = 'not_started',
    this.isRescheduled = false,
    this.isPastPaper = false,
    this.isTemplate = false,
    required this.createdAt,
    required this.updatedAt,
    this.originalEstimatedMinutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_id': subjectId,
      'chapter_id': chapterId,
      'title': title,
      'type': type,
      'due_at': dueAt,
      'scheduled_at': scheduledAt,
      'estimated_minutes': estimatedMinutes,
      'completed_minutes': completedMinutes,
      'priority': priority,
      'status': status,
      'is_rescheduled': isRescheduled ? 1 : 0,
      'is_past_paper': isPastPaper ? 1 : 0,
      'is_template': isTemplate ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'original_estimated_minutes':
          originalEstimatedMinutes ?? estimatedMinutes,
    };
  }

  static TaskModel fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] is int ? map['id'] as int : null,
      subjectId: map['subject_id'] is int ? map['subject_id'] as int : 0,
      chapterId: map['chapter_id'] is int ? map['chapter_id'] as int : null,
      title: map['title'] is String ? map['title'] as String : '',
      type: map['type'] is String ? map['type'] as String : 'custom',
      dueAt: map['due_at'] is String ? map['due_at'] as String : null,
      scheduledAt:
          map['scheduled_at'] is String ? map['scheduled_at'] as String : '',
      estimatedMinutes:
          map['estimated_minutes'] is int
              ? map['estimated_minutes'] as int
              : 30,
      completedMinutes:
          map['completed_minutes'] is int ? map['completed_minutes'] as int : 0,
      priority: map['priority'] is int ? map['priority'] as int : 2,
      status: map['status'] is String ? map['status'] as String : 'not_started',
      isRescheduled:
          (map['is_rescheduled'] is int ? map['is_rescheduled'] as int : 0) ==
          1,
      isPastPaper:
          (map['is_past_paper'] is int ? map['is_past_paper'] as int : 0) == 1,
      isTemplate:
          (map['is_template'] is int ? map['is_template'] as int : 0) == 1,
      createdAt: map['created_at'] is String ? map['created_at'] as String : '',
      updatedAt: map['updated_at'] is String ? map['updated_at'] as String : '',
      originalEstimatedMinutes:
          map['original_estimated_minutes'] is int
              ? map['original_estimated_minutes'] as int
              : null,
    );
  }
}

class FocusSessionModel {
  final int? id;
  final int? taskId;
  final String startedAt;
  final String? endedAt;
  final int plannedMinutes;
  final int completedMinutes;
  final String status;
  final String createdAt;
  final String? notes;
  final String? reflectionStatus;
  final String? parkingLotNotes;

  FocusSessionModel({
    this.id,
    this.taskId,
    required this.startedAt,
    this.endedAt,
    this.plannedMinutes = 25,
    this.completedMinutes = 0,
    this.status = 'running',
    required this.createdAt,
    this.notes,
    this.reflectionStatus,
    this.parkingLotNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'started_at': startedAt,
      'ended_at': endedAt,
      'planned_minutes': plannedMinutes,
      'completed_minutes': completedMinutes,
      'status': status,
      'created_at': createdAt,
      'notes': notes,
      'reflection_status': reflectionStatus,
      'parking_lot_notes': parkingLotNotes,
    };
  }

  static FocusSessionModel fromMap(Map<String, dynamic> map) {
    return FocusSessionModel(
      id: map['id'] is int ? map['id'] as int : null,
      taskId: map['task_id'] is int ? map['task_id'] as int : null,
      startedAt: map['started_at'] is String ? map['started_at'] as String : '',
      endedAt: map['ended_at'] is String ? map['ended_at'] as String : null,
      plannedMinutes:
          map['planned_minutes'] is int ? map['planned_minutes'] as int : 25,
      completedMinutes:
          map['completed_minutes'] is int ? map['completed_minutes'] as int : 0,
      status: map['status'] is String ? map['status'] as String : 'running',
      createdAt: map['created_at'] is String ? map['created_at'] as String : '',
      notes: map['notes'] is String ? map['notes'] as String : null,
      reflectionStatus:
          map['reflection_status'] is String
              ? map['reflection_status'] as String
              : null,
      parkingLotNotes:
          map['parking_lot_notes'] is String
              ? map['parking_lot_notes'] as String
              : null,
    );
  }
}

class RevisionItemModel {
  final int? id;
  final int chapterId;
  final String dueAt;
  final int intervalDays;
  final String status;
  final int? completedAt;
  final String createdAt;
  final int recallConfidence;
  final double easeFactor;
  final int repetitions;
  final String? lastReviewAt;

  RevisionItemModel({
    this.id,
    required this.chapterId,
    required this.dueAt,
    this.intervalDays = 1,
    this.status = 'pending',
    this.completedAt,
    required this.createdAt,
    this.recallConfidence = 0,
    this.easeFactor = 2.5,
    this.repetitions = 0,
    this.lastReviewAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chapter_id': chapterId,
      'due_at': dueAt,
      'interval_days': intervalDays,
      'status': status,
      'completed_at': completedAt,
      'created_at': createdAt,
      'recall_confidence': recallConfidence,
      'ease_factor': easeFactor,
      'repetitions': repetitions,
      'last_review_at': lastReviewAt,
    };
  }

  static RevisionItemModel fromMap(Map<String, dynamic> map) {
    return RevisionItemModel(
      id: map['id'] is int ? map['id'] as int : null,
      chapterId: map['chapter_id'] is int ? map['chapter_id'] as int : 0,
      dueAt: map['due_at'] is String ? map['due_at'] as String : '',
      intervalDays:
          map['interval_days'] is int ? map['interval_days'] as int : 1,
      status: map['status'] is String ? map['status'] as String : 'pending',
      completedAt:
          map['completed_at'] is int ? map['completed_at'] as int : null,
      createdAt: map['created_at'] is String ? map['created_at'] as String : '',
      recallConfidence:
          map['recall_confidence'] is int ? map['recall_confidence'] as int : 0,
      easeFactor:
          map['ease_factor'] is double
              ? map['ease_factor'] as double
              : (map['ease_factor'] is int
                  ? (map['ease_factor'] as int).toDouble()
                  : 2.5),
      repetitions: map['repetitions'] is int ? map['repetitions'] as int : 0,
      lastReviewAt:
          map['last_review_at'] is String
              ? map['last_review_at'] as String
              : null,
    );
  }
}

class ResourceModel {
  final int? id;
  final int subjectId;
  final int? chapterId;
  final int? taskId;
  final int? practicalId;
  final String type;
  final String title;
  final String localPath;
  final String createdAt;
  final int? fileSize;
  final bool isPinned;
  final String? tags;
  final String? folder;

  ResourceModel({
    this.id,
    required this.subjectId,
    this.chapterId,
    this.taskId,
    this.practicalId,
    required this.type,
    required this.title,
    required this.localPath,
    required this.createdAt,
    this.fileSize,
    this.isPinned = false,
    this.tags,
    this.folder,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_id': subjectId,
      'chapter_id': chapterId,
      'task_id': taskId,
      'practical_id': practicalId,
      'type': type,
      'title': title,
      'local_path': localPath,
      'created_at': createdAt,
      'file_size': fileSize,
      'is_pinned': isPinned ? 1 : 0,
      'tags': tags,
      'folder': folder,
    };
  }

  static ResourceModel fromMap(Map<String, dynamic> map) {
    return ResourceModel(
      id: map['id'] is int ? map['id'] as int : null,
      subjectId: map['subject_id'] is int ? map['subject_id'] as int : 0,
      chapterId: map['chapter_id'] is int ? map['chapter_id'] as int : null,
      taskId: map['task_id'] is int ? map['task_id'] as int : null,
      practicalId:
          map['practical_id'] is int ? map['practical_id'] as int : null,
      type: map['type'] is String ? map['type'] as String : 'other',
      title: map['title'] is String ? map['title'] as String : '',
      localPath: map['local_path'] is String ? map['local_path'] as String : '',
      createdAt: map['created_at'] is String ? map['created_at'] as String : '',
      fileSize: map['file_size'] is int ? map['file_size'] as int : null,
      isPinned: (map['is_pinned'] is int ? map['is_pinned'] as int : 0) == 1,
      tags: map['tags'] is String ? map['tags'] as String : null,
      folder: map['folder'] is String ? map['folder'] as String : null,
    );
  }
}

class PracticalRecordModel {
  final int? id;
  final int subjectId;
  final String title;
  final String? dueAt;
  final String status;
  final int? resourceId;
  final String createdAt;
  final String? objective;
  final String? apparatus;
  final String? procedure;
  final String? observation;
  final String? vivaQuestions;

  PracticalRecordModel({
    this.id,
    required this.subjectId,
    required this.title,
    this.dueAt,
    this.status = 'pending',
    this.resourceId,
    required this.createdAt,
    this.objective,
    this.apparatus,
    this.procedure,
    this.observation,
    this.vivaQuestions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_id': subjectId,
      'title': title,
      'due_at': dueAt,
      'status': status,
      'resource_id': resourceId,
      'created_at': createdAt,
      'objective': objective,
      'apparatus': apparatus,
      'procedure': procedure,
      'observation': observation,
      'viva_questions': vivaQuestions,
    };
  }

  static PracticalRecordModel fromMap(Map<String, dynamic> map) {
    return PracticalRecordModel(
      id: map['id'] is int ? map['id'] as int : null,
      subjectId: map['subject_id'] is int ? map['subject_id'] as int : 0,
      title: map['title'] is String ? map['title'] as String : '',
      dueAt: map['due_at'] is String ? map['due_at'] as String : null,
      status: map['status'] is String ? map['status'] as String : 'pending',
      resourceId: map['resource_id'] is int ? map['resource_id'] as int : null,
      createdAt: map['created_at'] is String ? map['created_at'] as String : '',
      objective: map['objective'] is String ? map['objective'] as String : null,
      apparatus: map['apparatus'] is String ? map['apparatus'] as String : null,
      procedure: map['procedure'] is String ? map['procedure'] as String : null,
      observation:
          map['observation'] is String ? map['observation'] as String : null,
      vivaQuestions:
          map['viva_questions'] is String
              ? map['viva_questions'] as String
              : null,
    );
  }
}

class SubjectProgressModel {
  final int? id;
  final String name;
  final int color;
  final int sortOrder;
  final int totalChapters;
  final int completedChapters;

  SubjectProgressModel({
    this.id,
    required this.name,
    required this.color,
    required this.sortOrder,
    this.totalChapters = 0,
    this.completedChapters = 0,
  });

  static SubjectProgressModel fromMap(Map<String, dynamic> map) {
    return SubjectProgressModel(
      id: map['id'] is int ? map['id'] as int : null,
      name: map['name'] is String ? map['name'] as String : '',
      color: map['color'] is int ? map['color'] as int : 0,
      sortOrder: map['sort_order'] is int ? map['sort_order'] as int : 0,
      totalChapters:
          map['total_chapters'] is int ? map['total_chapters'] as int : 0,
      completedChapters:
          map['completed_chapters'] is int
              ? map['completed_chapters'] as int
              : 0,
    );
  }
}

class ChapterWithSubjectModel {
  final int id;
  final int subjectId;
  final String title;
  final String status;
  final int priority;
  final int estimatedMinutes;
  final String revisionDates;
  final int? completedAt;
  final String createdAt;
  final String subjectName;

  ChapterWithSubjectModel({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.status,
    required this.priority,
    required this.estimatedMinutes,
    required this.revisionDates,
    this.completedAt,
    required this.createdAt,
    required this.subjectName,
  });

  static ChapterWithSubjectModel fromMap(Map<String, dynamic> map) {
    return ChapterWithSubjectModel(
      id: map['id'] is int ? map['id'] as int : 0,
      subjectId: map['subject_id'] is int ? map['subject_id'] as int : 0,
      title: map['title'] is String ? map['title'] as String : '',
      status: map['status'] is String ? map['status'] as String : 'not_started',
      priority: map['priority'] is int ? map['priority'] as int : 2,
      estimatedMinutes:
          map['estimated_minutes'] is int
              ? map['estimated_minutes'] as int
              : 30,
      revisionDates:
          map['revision_dates'] is String
              ? map['revision_dates'] as String
              : '[]',
      completedAt:
          map['completed_at'] is int ? map['completed_at'] as int : null,
      createdAt: map['created_at'] is String ? map['created_at'] as String : '',
      subjectName:
          map['subject_name'] is String ? map['subject_name'] as String : '',
    );
  }
}

class SyllabusTemplateModel {
  final int? id;
  final int templateVersion;
  final String exportedAt;
  final String sourceApp;
  final String sourceAttribution;
  final String importedAt;
  final String content;
  final String contentTier;

  SyllabusTemplateModel({
    this.id,
    this.templateVersion = 1,
    required this.exportedAt,
    this.sourceApp = 'retainly',
    this.sourceAttribution = '',
    this.importedAt = '',
    required this.content,
    this.contentTier = 'official',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'template_version': templateVersion,
      'exported_at': exportedAt,
      'source_app': sourceApp,
      'source_attribution': sourceAttribution,
      'imported_at': importedAt,
      'content': content,
      'content_tier': contentTier,
    };
  }

  static SyllabusTemplateModel fromMap(Map<String, dynamic> map) {
    return SyllabusTemplateModel(
      id: map['id'] is int ? map['id'] as int : null,
      templateVersion:
          map['template_version'] is int ? map['template_version'] as int : 1,
      exportedAt:
          map['exported_at'] is String ? map['exported_at'] as String : '',
      sourceApp:
          map['source_app'] is String
              ? map['source_app'] as String
              : 'retainly',
      sourceAttribution:
          map['source_attribution'] is String
              ? map['source_attribution'] as String
              : '',
      importedAt:
          map['imported_at'] is String ? map['imported_at'] as String : '',
      content: map['content'] is String ? map['content'] as String : '',
      contentTier:
          map['content_tier'] is String
              ? map['content_tier'] as String
              : 'official',
    );
  }
}
