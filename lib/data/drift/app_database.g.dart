// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _classLevelMeta = const VerificationMeta(
    'classLevel',
  );
  @override
  late final GeneratedColumn<String> classLevel = GeneratedColumn<String>(
    'class_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _boardMeta = const VerificationMeta('board');
  @override
  late final GeneratedColumn<String> board = GeneratedColumn<String>(
    'board',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _examDateMeta = const VerificationMeta(
    'examDate',
  );
  @override
  late final GeneratedColumn<String> examDate = GeneratedColumn<String>(
    'exam_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dailyStudyMinutesMeta = const VerificationMeta(
    'dailyStudyMinutes',
  );
  @override
  late final GeneratedColumn<int> dailyStudyMinutes = GeneratedColumn<int>(
    'daily_study_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(120),
  );
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
    'theme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('light'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    classLevel,
    board,
    examDate,
    dailyStudyMinutes,
    theme,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('class_level')) {
      context.handle(
        _classLevelMeta,
        classLevel.isAcceptableOrUnknown(data['class_level']!, _classLevelMeta),
      );
    } else if (isInserting) {
      context.missing(_classLevelMeta);
    }
    if (data.containsKey('board')) {
      context.handle(
        _boardMeta,
        board.isAcceptableOrUnknown(data['board']!, _boardMeta),
      );
    } else if (isInserting) {
      context.missing(_boardMeta);
    }
    if (data.containsKey('exam_date')) {
      context.handle(
        _examDateMeta,
        examDate.isAcceptableOrUnknown(data['exam_date']!, _examDateMeta),
      );
    } else if (isInserting) {
      context.missing(_examDateMeta);
    }
    if (data.containsKey('daily_study_minutes')) {
      context.handle(
        _dailyStudyMinutesMeta,
        dailyStudyMinutes.isAcceptableOrUnknown(
          data['daily_study_minutes']!,
          _dailyStudyMinutesMeta,
        ),
      );
    }
    if (data.containsKey('theme')) {
      context.handle(
        _themeMeta,
        theme.isAcceptableOrUnknown(data['theme']!, _themeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      classLevel:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}class_level'],
          )!,
      board:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}board'],
          )!,
      examDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}exam_date'],
          )!,
      dailyStudyMinutes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}daily_study_minutes'],
          )!,
      theme:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}theme'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final int id;
  final String classLevel;
  final String board;
  final String examDate;
  final int dailyStudyMinutes;
  final String theme;
  final String createdAt;
  final String updatedAt;
  const UserProfile({
    required this.id,
    required this.classLevel,
    required this.board,
    required this.examDate,
    required this.dailyStudyMinutes,
    required this.theme,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['class_level'] = Variable<String>(classLevel);
    map['board'] = Variable<String>(board);
    map['exam_date'] = Variable<String>(examDate);
    map['daily_study_minutes'] = Variable<int>(dailyStudyMinutes);
    map['theme'] = Variable<String>(theme);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      classLevel: Value(classLevel),
      board: Value(board),
      examDate: Value(examDate),
      dailyStudyMinutes: Value(dailyStudyMinutes),
      theme: Value(theme),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<int>(json['id']),
      classLevel: serializer.fromJson<String>(json['classLevel']),
      board: serializer.fromJson<String>(json['board']),
      examDate: serializer.fromJson<String>(json['examDate']),
      dailyStudyMinutes: serializer.fromJson<int>(json['dailyStudyMinutes']),
      theme: serializer.fromJson<String>(json['theme']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'classLevel': serializer.toJson<String>(classLevel),
      'board': serializer.toJson<String>(board),
      'examDate': serializer.toJson<String>(examDate),
      'dailyStudyMinutes': serializer.toJson<int>(dailyStudyMinutes),
      'theme': serializer.toJson<String>(theme),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  UserProfile copyWith({
    int? id,
    String? classLevel,
    String? board,
    String? examDate,
    int? dailyStudyMinutes,
    String? theme,
    String? createdAt,
    String? updatedAt,
  }) => UserProfile(
    id: id ?? this.id,
    classLevel: classLevel ?? this.classLevel,
    board: board ?? this.board,
    examDate: examDate ?? this.examDate,
    dailyStudyMinutes: dailyStudyMinutes ?? this.dailyStudyMinutes,
    theme: theme ?? this.theme,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      classLevel:
          data.classLevel.present ? data.classLevel.value : this.classLevel,
      board: data.board.present ? data.board.value : this.board,
      examDate: data.examDate.present ? data.examDate.value : this.examDate,
      dailyStudyMinutes:
          data.dailyStudyMinutes.present
              ? data.dailyStudyMinutes.value
              : this.dailyStudyMinutes,
      theme: data.theme.present ? data.theme.value : this.theme,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('classLevel: $classLevel, ')
          ..write('board: $board, ')
          ..write('examDate: $examDate, ')
          ..write('dailyStudyMinutes: $dailyStudyMinutes, ')
          ..write('theme: $theme, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    classLevel,
    board,
    examDate,
    dailyStudyMinutes,
    theme,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.classLevel == this.classLevel &&
          other.board == this.board &&
          other.examDate == this.examDate &&
          other.dailyStudyMinutes == this.dailyStudyMinutes &&
          other.theme == this.theme &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<int> id;
  final Value<String> classLevel;
  final Value<String> board;
  final Value<String> examDate;
  final Value<int> dailyStudyMinutes;
  final Value<String> theme;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.classLevel = const Value.absent(),
    this.board = const Value.absent(),
    this.examDate = const Value.absent(),
    this.dailyStudyMinutes = const Value.absent(),
    this.theme = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String classLevel,
    required String board,
    required String examDate,
    this.dailyStudyMinutes = const Value.absent(),
    this.theme = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  }) : classLevel = Value(classLevel),
       board = Value(board),
       examDate = Value(examDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserProfile> custom({
    Expression<int>? id,
    Expression<String>? classLevel,
    Expression<String>? board,
    Expression<String>? examDate,
    Expression<int>? dailyStudyMinutes,
    Expression<String>? theme,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (classLevel != null) 'class_level': classLevel,
      if (board != null) 'board': board,
      if (examDate != null) 'exam_date': examDate,
      if (dailyStudyMinutes != null) 'daily_study_minutes': dailyStudyMinutes,
      if (theme != null) 'theme': theme,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? classLevel,
    Value<String>? board,
    Value<String>? examDate,
    Value<int>? dailyStudyMinutes,
    Value<String>? theme,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      classLevel: classLevel ?? this.classLevel,
      board: board ?? this.board,
      examDate: examDate ?? this.examDate,
      dailyStudyMinutes: dailyStudyMinutes ?? this.dailyStudyMinutes,
      theme: theme ?? this.theme,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (classLevel.present) {
      map['class_level'] = Variable<String>(classLevel.value);
    }
    if (board.present) {
      map['board'] = Variable<String>(board.value);
    }
    if (examDate.present) {
      map['exam_date'] = Variable<String>(examDate.value);
    }
    if (dailyStudyMinutes.present) {
      map['daily_study_minutes'] = Variable<int>(dailyStudyMinutes.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('classLevel: $classLevel, ')
          ..write('board: $board, ')
          ..write('examDate: $examDate, ')
          ..write('dailyStudyMinutes: $dailyStudyMinutes, ')
          ..write('theme: $theme, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SubjectsTable extends Subjects with TableInfo<$SubjectsTable, Subject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, color, sortOrder, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subject(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      color:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}color'],
          )!,
      sortOrder:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sort_order'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class Subject extends DataClass implements Insertable<Subject> {
  final int id;
  final String name;
  final int color;
  final int sortOrder;
  final String createdAt;
  const Subject({
    required this.id,
    required this.name,
    required this.color,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  SubjectsCompanion toCompanion(bool nullToAbsent) {
    return SubjectsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory Subject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subject(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  Subject copyWith({
    int? id,
    String? name,
    int? color,
    int? sortOrder,
    String? createdAt,
  }) => Subject(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  Subject copyWithCompanion(SubjectsCompanion data) {
    return Subject(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subject(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subject &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class SubjectsCompanion extends UpdateCompanion<Subject> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> color;
  final Value<int> sortOrder;
  final Value<String> createdAt;
  const SubjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SubjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int color,
    required int sortOrder,
    required String createdAt,
  }) : name = Value(name),
       color = Value(color),
       sortOrder = Value(sortOrder),
       createdAt = Value(createdAt);
  static Insertable<Subject> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? color,
    Expression<int>? sortOrder,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SubjectsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? color,
    Value<int>? sortOrder,
    Value<String>? createdAt,
  }) {
    return SubjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ChaptersTable extends Chapters with TableInfo<$ChaptersTable, Chapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subjects (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('not_started'),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _estimatedMinutesMeta = const VerificationMeta(
    'estimatedMinutes',
  );
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
    'estimated_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _revisionDatesMeta = const VerificationMeta(
    'revisionDates',
  );
  @override
  late final GeneratedColumn<String> revisionDates = GeneratedColumn<String>(
    'revision_dates',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _examWeightMeta = const VerificationMeta(
    'examWeight',
  );
  @override
  late final GeneratedColumn<int> examWeight = GeneratedColumn<int>(
    'exam_weight',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<int> confidence = GeneratedColumn<int>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentSourceMeta = const VerificationMeta(
    'contentSource',
  );
  @override
  late final GeneratedColumn<String> contentSource = GeneratedColumn<String>(
    'content_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentVersionMeta = const VerificationMeta(
    'contentVersion',
  );
  @override
  late final GeneratedColumn<String> contentVersion = GeneratedColumn<String>(
    'content_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewDateMeta = const VerificationMeta(
    'reviewDate',
  );
  @override
  late final GeneratedColumn<String> reviewDate = GeneratedColumn<String>(
    'review_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isWeakTopicMeta = const VerificationMeta(
    'isWeakTopic',
  );
  @override
  late final GeneratedColumn<int> isWeakTopic = GeneratedColumn<int>(
    'is_weak_topic',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _contentTierMeta = const VerificationMeta(
    'contentTier',
  );
  @override
  late final GeneratedColumn<String> contentTier = GeneratedColumn<String>(
    'content_tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('official'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subjectId,
    title,
    status,
    priority,
    estimatedMinutes,
    revisionDates,
    completedAt,
    createdAt,
    examWeight,
    confidence,
    contentSource,
    contentVersion,
    reviewDate,
    isWeakTopic,
    contentTier,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Chapter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
        _estimatedMinutesMeta,
        estimatedMinutes.isAcceptableOrUnknown(
          data['estimated_minutes']!,
          _estimatedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('revision_dates')) {
      context.handle(
        _revisionDatesMeta,
        revisionDates.isAcceptableOrUnknown(
          data['revision_dates']!,
          _revisionDatesMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('exam_weight')) {
      context.handle(
        _examWeightMeta,
        examWeight.isAcceptableOrUnknown(data['exam_weight']!, _examWeightMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('content_source')) {
      context.handle(
        _contentSourceMeta,
        contentSource.isAcceptableOrUnknown(
          data['content_source']!,
          _contentSourceMeta,
        ),
      );
    }
    if (data.containsKey('content_version')) {
      context.handle(
        _contentVersionMeta,
        contentVersion.isAcceptableOrUnknown(
          data['content_version']!,
          _contentVersionMeta,
        ),
      );
    }
    if (data.containsKey('review_date')) {
      context.handle(
        _reviewDateMeta,
        reviewDate.isAcceptableOrUnknown(data['review_date']!, _reviewDateMeta),
      );
    }
    if (data.containsKey('is_weak_topic')) {
      context.handle(
        _isWeakTopicMeta,
        isWeakTopic.isAcceptableOrUnknown(
          data['is_weak_topic']!,
          _isWeakTopicMeta,
        ),
      );
    }
    if (data.containsKey('content_tier')) {
      context.handle(
        _contentTierMeta,
        contentTier.isAcceptableOrUnknown(
          data['content_tier']!,
          _contentTierMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Chapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chapter(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      subjectId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}subject_id'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      priority:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}priority'],
          )!,
      estimatedMinutes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}estimated_minutes'],
          )!,
      revisionDates:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}revision_dates'],
          )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}created_at'],
          )!,
      examWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exam_weight'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confidence'],
      ),
      contentSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_source'],
      ),
      contentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_version'],
      ),
      reviewDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_date'],
      ),
      isWeakTopic:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}is_weak_topic'],
          )!,
      contentTier:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}content_tier'],
          )!,
    );
  }

  @override
  $ChaptersTable createAlias(String alias) {
    return $ChaptersTable(attachedDatabase, alias);
  }
}

class Chapter extends DataClass implements Insertable<Chapter> {
  final int id;
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
  final int isWeakTopic;
  final String contentTier;
  const Chapter({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.status,
    required this.priority,
    required this.estimatedMinutes,
    required this.revisionDates,
    this.completedAt,
    required this.createdAt,
    this.examWeight,
    this.confidence,
    this.contentSource,
    this.contentVersion,
    this.reviewDate,
    required this.isWeakTopic,
    required this.contentTier,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['subject_id'] = Variable<int>(subjectId);
    map['title'] = Variable<String>(title);
    map['status'] = Variable<String>(status);
    map['priority'] = Variable<int>(priority);
    map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    map['revision_dates'] = Variable<String>(revisionDates);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['created_at'] = Variable<String>(createdAt);
    if (!nullToAbsent || examWeight != null) {
      map['exam_weight'] = Variable<int>(examWeight);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<int>(confidence);
    }
    if (!nullToAbsent || contentSource != null) {
      map['content_source'] = Variable<String>(contentSource);
    }
    if (!nullToAbsent || contentVersion != null) {
      map['content_version'] = Variable<String>(contentVersion);
    }
    if (!nullToAbsent || reviewDate != null) {
      map['review_date'] = Variable<String>(reviewDate);
    }
    map['is_weak_topic'] = Variable<int>(isWeakTopic);
    map['content_tier'] = Variable<String>(contentTier);
    return map;
  }

  ChaptersCompanion toCompanion(bool nullToAbsent) {
    return ChaptersCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      title: Value(title),
      status: Value(status),
      priority: Value(priority),
      estimatedMinutes: Value(estimatedMinutes),
      revisionDates: Value(revisionDates),
      completedAt:
          completedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(completedAt),
      createdAt: Value(createdAt),
      examWeight:
          examWeight == null && nullToAbsent
              ? const Value.absent()
              : Value(examWeight),
      confidence:
          confidence == null && nullToAbsent
              ? const Value.absent()
              : Value(confidence),
      contentSource:
          contentSource == null && nullToAbsent
              ? const Value.absent()
              : Value(contentSource),
      contentVersion:
          contentVersion == null && nullToAbsent
              ? const Value.absent()
              : Value(contentVersion),
      reviewDate:
          reviewDate == null && nullToAbsent
              ? const Value.absent()
              : Value(reviewDate),
      isWeakTopic: Value(isWeakTopic),
      contentTier: Value(contentTier),
    );
  }

  factory Chapter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chapter(
      id: serializer.fromJson<int>(json['id']),
      subjectId: serializer.fromJson<int>(json['subjectId']),
      title: serializer.fromJson<String>(json['title']),
      status: serializer.fromJson<String>(json['status']),
      priority: serializer.fromJson<int>(json['priority']),
      estimatedMinutes: serializer.fromJson<int>(json['estimatedMinutes']),
      revisionDates: serializer.fromJson<String>(json['revisionDates']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      examWeight: serializer.fromJson<int?>(json['examWeight']),
      confidence: serializer.fromJson<int?>(json['confidence']),
      contentSource: serializer.fromJson<String?>(json['contentSource']),
      contentVersion: serializer.fromJson<String?>(json['contentVersion']),
      reviewDate: serializer.fromJson<String?>(json['reviewDate']),
      isWeakTopic: serializer.fromJson<int>(json['isWeakTopic']),
      contentTier: serializer.fromJson<String>(json['contentTier']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'subjectId': serializer.toJson<int>(subjectId),
      'title': serializer.toJson<String>(title),
      'status': serializer.toJson<String>(status),
      'priority': serializer.toJson<int>(priority),
      'estimatedMinutes': serializer.toJson<int>(estimatedMinutes),
      'revisionDates': serializer.toJson<String>(revisionDates),
      'completedAt': serializer.toJson<int?>(completedAt),
      'createdAt': serializer.toJson<String>(createdAt),
      'examWeight': serializer.toJson<int?>(examWeight),
      'confidence': serializer.toJson<int?>(confidence),
      'contentSource': serializer.toJson<String?>(contentSource),
      'contentVersion': serializer.toJson<String?>(contentVersion),
      'reviewDate': serializer.toJson<String?>(reviewDate),
      'isWeakTopic': serializer.toJson<int>(isWeakTopic),
      'contentTier': serializer.toJson<String>(contentTier),
    };
  }

  Chapter copyWith({
    int? id,
    int? subjectId,
    String? title,
    String? status,
    int? priority,
    int? estimatedMinutes,
    String? revisionDates,
    Value<int?> completedAt = const Value.absent(),
    String? createdAt,
    Value<int?> examWeight = const Value.absent(),
    Value<int?> confidence = const Value.absent(),
    Value<String?> contentSource = const Value.absent(),
    Value<String?> contentVersion = const Value.absent(),
    Value<String?> reviewDate = const Value.absent(),
    int? isWeakTopic,
    String? contentTier,
  }) => Chapter(
    id: id ?? this.id,
    subjectId: subjectId ?? this.subjectId,
    title: title ?? this.title,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    revisionDates: revisionDates ?? this.revisionDates,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    examWeight: examWeight.present ? examWeight.value : this.examWeight,
    confidence: confidence.present ? confidence.value : this.confidence,
    contentSource:
        contentSource.present ? contentSource.value : this.contentSource,
    contentVersion:
        contentVersion.present ? contentVersion.value : this.contentVersion,
    reviewDate: reviewDate.present ? reviewDate.value : this.reviewDate,
    isWeakTopic: isWeakTopic ?? this.isWeakTopic,
    contentTier: contentTier ?? this.contentTier,
  );
  Chapter copyWithCompanion(ChaptersCompanion data) {
    return Chapter(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      estimatedMinutes:
          data.estimatedMinutes.present
              ? data.estimatedMinutes.value
              : this.estimatedMinutes,
      revisionDates:
          data.revisionDates.present
              ? data.revisionDates.value
              : this.revisionDates,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      examWeight:
          data.examWeight.present ? data.examWeight.value : this.examWeight,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      contentSource:
          data.contentSource.present
              ? data.contentSource.value
              : this.contentSource,
      contentVersion:
          data.contentVersion.present
              ? data.contentVersion.value
              : this.contentVersion,
      reviewDate:
          data.reviewDate.present ? data.reviewDate.value : this.reviewDate,
      isWeakTopic:
          data.isWeakTopic.present ? data.isWeakTopic.value : this.isWeakTopic,
      contentTier:
          data.contentTier.present ? data.contentTier.value : this.contentTier,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Chapter(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('revisionDates: $revisionDates, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('examWeight: $examWeight, ')
          ..write('confidence: $confidence, ')
          ..write('contentSource: $contentSource, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('reviewDate: $reviewDate, ')
          ..write('isWeakTopic: $isWeakTopic, ')
          ..write('contentTier: $contentTier')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    subjectId,
    title,
    status,
    priority,
    estimatedMinutes,
    revisionDates,
    completedAt,
    createdAt,
    examWeight,
    confidence,
    contentSource,
    contentVersion,
    reviewDate,
    isWeakTopic,
    contentTier,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chapter &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.title == this.title &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.revisionDates == this.revisionDates &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.examWeight == this.examWeight &&
          other.confidence == this.confidence &&
          other.contentSource == this.contentSource &&
          other.contentVersion == this.contentVersion &&
          other.reviewDate == this.reviewDate &&
          other.isWeakTopic == this.isWeakTopic &&
          other.contentTier == this.contentTier);
}

class ChaptersCompanion extends UpdateCompanion<Chapter> {
  final Value<int> id;
  final Value<int> subjectId;
  final Value<String> title;
  final Value<String> status;
  final Value<int> priority;
  final Value<int> estimatedMinutes;
  final Value<String> revisionDates;
  final Value<int?> completedAt;
  final Value<String> createdAt;
  final Value<int?> examWeight;
  final Value<int?> confidence;
  final Value<String?> contentSource;
  final Value<String?> contentVersion;
  final Value<String?> reviewDate;
  final Value<int> isWeakTopic;
  final Value<String> contentTier;
  const ChaptersCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.revisionDates = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.examWeight = const Value.absent(),
    this.confidence = const Value.absent(),
    this.contentSource = const Value.absent(),
    this.contentVersion = const Value.absent(),
    this.reviewDate = const Value.absent(),
    this.isWeakTopic = const Value.absent(),
    this.contentTier = const Value.absent(),
  });
  ChaptersCompanion.insert({
    this.id = const Value.absent(),
    required int subjectId,
    required String title,
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.revisionDates = const Value.absent(),
    this.completedAt = const Value.absent(),
    required String createdAt,
    this.examWeight = const Value.absent(),
    this.confidence = const Value.absent(),
    this.contentSource = const Value.absent(),
    this.contentVersion = const Value.absent(),
    this.reviewDate = const Value.absent(),
    this.isWeakTopic = const Value.absent(),
    this.contentTier = const Value.absent(),
  }) : subjectId = Value(subjectId),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<Chapter> custom({
    Expression<int>? id,
    Expression<int>? subjectId,
    Expression<String>? title,
    Expression<String>? status,
    Expression<int>? priority,
    Expression<int>? estimatedMinutes,
    Expression<String>? revisionDates,
    Expression<int>? completedAt,
    Expression<String>? createdAt,
    Expression<int>? examWeight,
    Expression<int>? confidence,
    Expression<String>? contentSource,
    Expression<String>? contentVersion,
    Expression<String>? reviewDate,
    Expression<int>? isWeakTopic,
    Expression<String>? contentTier,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (revisionDates != null) 'revision_dates': revisionDates,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (examWeight != null) 'exam_weight': examWeight,
      if (confidence != null) 'confidence': confidence,
      if (contentSource != null) 'content_source': contentSource,
      if (contentVersion != null) 'content_version': contentVersion,
      if (reviewDate != null) 'review_date': reviewDate,
      if (isWeakTopic != null) 'is_weak_topic': isWeakTopic,
      if (contentTier != null) 'content_tier': contentTier,
    });
  }

  ChaptersCompanion copyWith({
    Value<int>? id,
    Value<int>? subjectId,
    Value<String>? title,
    Value<String>? status,
    Value<int>? priority,
    Value<int>? estimatedMinutes,
    Value<String>? revisionDates,
    Value<int?>? completedAt,
    Value<String>? createdAt,
    Value<int?>? examWeight,
    Value<int?>? confidence,
    Value<String?>? contentSource,
    Value<String?>? contentVersion,
    Value<String?>? reviewDate,
    Value<int>? isWeakTopic,
    Value<String>? contentTier,
  }) {
    return ChaptersCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      revisionDates: revisionDates ?? this.revisionDates,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      examWeight: examWeight ?? this.examWeight,
      confidence: confidence ?? this.confidence,
      contentSource: contentSource ?? this.contentSource,
      contentVersion: contentVersion ?? this.contentVersion,
      reviewDate: reviewDate ?? this.reviewDate,
      isWeakTopic: isWeakTopic ?? this.isWeakTopic,
      contentTier: contentTier ?? this.contentTier,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (revisionDates.present) {
      map['revision_dates'] = Variable<String>(revisionDates.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (examWeight.present) {
      map['exam_weight'] = Variable<int>(examWeight.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<int>(confidence.value);
    }
    if (contentSource.present) {
      map['content_source'] = Variable<String>(contentSource.value);
    }
    if (contentVersion.present) {
      map['content_version'] = Variable<String>(contentVersion.value);
    }
    if (reviewDate.present) {
      map['review_date'] = Variable<String>(reviewDate.value);
    }
    if (isWeakTopic.present) {
      map['is_weak_topic'] = Variable<int>(isWeakTopic.value);
    }
    if (contentTier.present) {
      map['content_tier'] = Variable<String>(contentTier.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('revisionDates: $revisionDates, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('examWeight: $examWeight, ')
          ..write('confidence: $confidence, ')
          ..write('contentSource: $contentSource, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('reviewDate: $reviewDate, ')
          ..write('isWeakTopic: $isWeakTopic, ')
          ..write('contentTier: $contentTier')
          ..write(')'))
        .toString();
  }
}

class $StudyTasksTable extends StudyTasks
    with TableInfo<$StudyTasksTable, StudyTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subjects (id)',
    ),
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<int> chapterId = GeneratedColumn<int>(
    'chapter_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chapters (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('custom'),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<String> dueAt = GeneratedColumn<String>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<String> scheduledAt = GeneratedColumn<String>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedMinutesMeta = const VerificationMeta(
    'estimatedMinutes',
  );
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
    'estimated_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedMinutesMeta = const VerificationMeta(
    'completedMinutes',
  );
  @override
  late final GeneratedColumn<int> completedMinutes = GeneratedColumn<int>(
    'completed_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRescheduledMeta = const VerificationMeta(
    'isRescheduled',
  );
  @override
  late final GeneratedColumn<int> isRescheduled = GeneratedColumn<int>(
    'is_rescheduled',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isPastPaperMeta = const VerificationMeta(
    'isPastPaper',
  );
  @override
  late final GeneratedColumn<int> isPastPaper = GeneratedColumn<int>(
    'is_past_paper',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isTemplateMeta = const VerificationMeta(
    'isTemplate',
  );
  @override
  late final GeneratedColumn<int> isTemplate = GeneratedColumn<int>(
    'is_template',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalEstimatedMinutesMeta =
      const VerificationMeta('originalEstimatedMinutes');
  @override
  late final GeneratedColumn<int> originalEstimatedMinutes =
      GeneratedColumn<int>(
        'original_estimated_minutes',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subjectId,
    chapterId,
    title,
    type,
    dueAt,
    scheduledAt,
    estimatedMinutes,
    completedMinutes,
    priority,
    status,
    isRescheduled,
    isPastPaper,
    isTemplate,
    createdAt,
    updatedAt,
    originalEstimatedMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudyTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
        _estimatedMinutesMeta,
        estimatedMinutes.isAcceptableOrUnknown(
          data['estimated_minutes']!,
          _estimatedMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_estimatedMinutesMeta);
    }
    if (data.containsKey('completed_minutes')) {
      context.handle(
        _completedMinutesMeta,
        completedMinutes.isAcceptableOrUnknown(
          data['completed_minutes']!,
          _completedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('is_rescheduled')) {
      context.handle(
        _isRescheduledMeta,
        isRescheduled.isAcceptableOrUnknown(
          data['is_rescheduled']!,
          _isRescheduledMeta,
        ),
      );
    }
    if (data.containsKey('is_past_paper')) {
      context.handle(
        _isPastPaperMeta,
        isPastPaper.isAcceptableOrUnknown(
          data['is_past_paper']!,
          _isPastPaperMeta,
        ),
      );
    }
    if (data.containsKey('is_template')) {
      context.handle(
        _isTemplateMeta,
        isTemplate.isAcceptableOrUnknown(data['is_template']!, _isTemplateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('original_estimated_minutes')) {
      context.handle(
        _originalEstimatedMinutesMeta,
        originalEstimatedMinutes.isAcceptableOrUnknown(
          data['original_estimated_minutes']!,
          _originalEstimatedMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudyTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyTask(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      subjectId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}subject_id'],
          )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_id'],
      ),
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_at'],
      ),
      scheduledAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}scheduled_at'],
          )!,
      estimatedMinutes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}estimated_minutes'],
          )!,
      completedMinutes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}completed_minutes'],
          )!,
      priority:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}priority'],
          )!,
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      isRescheduled:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}is_rescheduled'],
          )!,
      isPastPaper:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}is_past_paper'],
          )!,
      isTemplate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}is_template'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}updated_at'],
          )!,
      originalEstimatedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_estimated_minutes'],
      ),
    );
  }

  @override
  $StudyTasksTable createAlias(String alias) {
    return $StudyTasksTable(attachedDatabase, alias);
  }
}

class StudyTask extends DataClass implements Insertable<StudyTask> {
  final int id;
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
  final int isRescheduled;
  final int isPastPaper;
  final int isTemplate;
  final String createdAt;
  final String updatedAt;
  final int? originalEstimatedMinutes;
  const StudyTask({
    required this.id,
    required this.subjectId,
    this.chapterId,
    required this.title,
    required this.type,
    this.dueAt,
    required this.scheduledAt,
    required this.estimatedMinutes,
    required this.completedMinutes,
    required this.priority,
    required this.status,
    required this.isRescheduled,
    required this.isPastPaper,
    required this.isTemplate,
    required this.createdAt,
    required this.updatedAt,
    this.originalEstimatedMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['subject_id'] = Variable<int>(subjectId);
    if (!nullToAbsent || chapterId != null) {
      map['chapter_id'] = Variable<int>(chapterId);
    }
    map['title'] = Variable<String>(title);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<String>(dueAt);
    }
    map['scheduled_at'] = Variable<String>(scheduledAt);
    map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    map['completed_minutes'] = Variable<int>(completedMinutes);
    map['priority'] = Variable<int>(priority);
    map['status'] = Variable<String>(status);
    map['is_rescheduled'] = Variable<int>(isRescheduled);
    map['is_past_paper'] = Variable<int>(isPastPaper);
    map['is_template'] = Variable<int>(isTemplate);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || originalEstimatedMinutes != null) {
      map['original_estimated_minutes'] = Variable<int>(
        originalEstimatedMinutes,
      );
    }
    return map;
  }

  StudyTasksCompanion toCompanion(bool nullToAbsent) {
    return StudyTasksCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      chapterId:
          chapterId == null && nullToAbsent
              ? const Value.absent()
              : Value(chapterId),
      title: Value(title),
      type: Value(type),
      dueAt:
          dueAt == null && nullToAbsent ? const Value.absent() : Value(dueAt),
      scheduledAt: Value(scheduledAt),
      estimatedMinutes: Value(estimatedMinutes),
      completedMinutes: Value(completedMinutes),
      priority: Value(priority),
      status: Value(status),
      isRescheduled: Value(isRescheduled),
      isPastPaper: Value(isPastPaper),
      isTemplate: Value(isTemplate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      originalEstimatedMinutes:
          originalEstimatedMinutes == null && nullToAbsent
              ? const Value.absent()
              : Value(originalEstimatedMinutes),
    );
  }

  factory StudyTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyTask(
      id: serializer.fromJson<int>(json['id']),
      subjectId: serializer.fromJson<int>(json['subjectId']),
      chapterId: serializer.fromJson<int?>(json['chapterId']),
      title: serializer.fromJson<String>(json['title']),
      type: serializer.fromJson<String>(json['type']),
      dueAt: serializer.fromJson<String?>(json['dueAt']),
      scheduledAt: serializer.fromJson<String>(json['scheduledAt']),
      estimatedMinutes: serializer.fromJson<int>(json['estimatedMinutes']),
      completedMinutes: serializer.fromJson<int>(json['completedMinutes']),
      priority: serializer.fromJson<int>(json['priority']),
      status: serializer.fromJson<String>(json['status']),
      isRescheduled: serializer.fromJson<int>(json['isRescheduled']),
      isPastPaper: serializer.fromJson<int>(json['isPastPaper']),
      isTemplate: serializer.fromJson<int>(json['isTemplate']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      originalEstimatedMinutes: serializer.fromJson<int?>(
        json['originalEstimatedMinutes'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'subjectId': serializer.toJson<int>(subjectId),
      'chapterId': serializer.toJson<int?>(chapterId),
      'title': serializer.toJson<String>(title),
      'type': serializer.toJson<String>(type),
      'dueAt': serializer.toJson<String?>(dueAt),
      'scheduledAt': serializer.toJson<String>(scheduledAt),
      'estimatedMinutes': serializer.toJson<int>(estimatedMinutes),
      'completedMinutes': serializer.toJson<int>(completedMinutes),
      'priority': serializer.toJson<int>(priority),
      'status': serializer.toJson<String>(status),
      'isRescheduled': serializer.toJson<int>(isRescheduled),
      'isPastPaper': serializer.toJson<int>(isPastPaper),
      'isTemplate': serializer.toJson<int>(isTemplate),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'originalEstimatedMinutes': serializer.toJson<int?>(
        originalEstimatedMinutes,
      ),
    };
  }

  StudyTask copyWith({
    int? id,
    int? subjectId,
    Value<int?> chapterId = const Value.absent(),
    String? title,
    String? type,
    Value<String?> dueAt = const Value.absent(),
    String? scheduledAt,
    int? estimatedMinutes,
    int? completedMinutes,
    int? priority,
    String? status,
    int? isRescheduled,
    int? isPastPaper,
    int? isTemplate,
    String? createdAt,
    String? updatedAt,
    Value<int?> originalEstimatedMinutes = const Value.absent(),
  }) => StudyTask(
    id: id ?? this.id,
    subjectId: subjectId ?? this.subjectId,
    chapterId: chapterId.present ? chapterId.value : this.chapterId,
    title: title ?? this.title,
    type: type ?? this.type,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    completedMinutes: completedMinutes ?? this.completedMinutes,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    isRescheduled: isRescheduled ?? this.isRescheduled,
    isPastPaper: isPastPaper ?? this.isPastPaper,
    isTemplate: isTemplate ?? this.isTemplate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    originalEstimatedMinutes:
        originalEstimatedMinutes.present
            ? originalEstimatedMinutes.value
            : this.originalEstimatedMinutes,
  );
  StudyTask copyWithCompanion(StudyTasksCompanion data) {
    return StudyTask(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      title: data.title.present ? data.title.value : this.title,
      type: data.type.present ? data.type.value : this.type,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      estimatedMinutes:
          data.estimatedMinutes.present
              ? data.estimatedMinutes.value
              : this.estimatedMinutes,
      completedMinutes:
          data.completedMinutes.present
              ? data.completedMinutes.value
              : this.completedMinutes,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      isRescheduled:
          data.isRescheduled.present
              ? data.isRescheduled.value
              : this.isRescheduled,
      isPastPaper:
          data.isPastPaper.present ? data.isPastPaper.value : this.isPastPaper,
      isTemplate:
          data.isTemplate.present ? data.isTemplate.value : this.isTemplate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      originalEstimatedMinutes:
          data.originalEstimatedMinutes.present
              ? data.originalEstimatedMinutes.value
              : this.originalEstimatedMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyTask(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('chapterId: $chapterId, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('dueAt: $dueAt, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('completedMinutes: $completedMinutes, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('isRescheduled: $isRescheduled, ')
          ..write('isPastPaper: $isPastPaper, ')
          ..write('isTemplate: $isTemplate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('originalEstimatedMinutes: $originalEstimatedMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    subjectId,
    chapterId,
    title,
    type,
    dueAt,
    scheduledAt,
    estimatedMinutes,
    completedMinutes,
    priority,
    status,
    isRescheduled,
    isPastPaper,
    isTemplate,
    createdAt,
    updatedAt,
    originalEstimatedMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyTask &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.chapterId == this.chapterId &&
          other.title == this.title &&
          other.type == this.type &&
          other.dueAt == this.dueAt &&
          other.scheduledAt == this.scheduledAt &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.completedMinutes == this.completedMinutes &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.isRescheduled == this.isRescheduled &&
          other.isPastPaper == this.isPastPaper &&
          other.isTemplate == this.isTemplate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.originalEstimatedMinutes == this.originalEstimatedMinutes);
}

class StudyTasksCompanion extends UpdateCompanion<StudyTask> {
  final Value<int> id;
  final Value<int> subjectId;
  final Value<int?> chapterId;
  final Value<String> title;
  final Value<String> type;
  final Value<String?> dueAt;
  final Value<String> scheduledAt;
  final Value<int> estimatedMinutes;
  final Value<int> completedMinutes;
  final Value<int> priority;
  final Value<String> status;
  final Value<int> isRescheduled;
  final Value<int> isPastPaper;
  final Value<int> isTemplate;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int?> originalEstimatedMinutes;
  const StudyTasksCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.completedMinutes = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.isRescheduled = const Value.absent(),
    this.isPastPaper = const Value.absent(),
    this.isTemplate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.originalEstimatedMinutes = const Value.absent(),
  });
  StudyTasksCompanion.insert({
    this.id = const Value.absent(),
    required int subjectId,
    this.chapterId = const Value.absent(),
    required String title,
    this.type = const Value.absent(),
    this.dueAt = const Value.absent(),
    required String scheduledAt,
    required int estimatedMinutes,
    this.completedMinutes = const Value.absent(),
    this.priority = const Value.absent(),
    required String status,
    this.isRescheduled = const Value.absent(),
    this.isPastPaper = const Value.absent(),
    this.isTemplate = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.originalEstimatedMinutes = const Value.absent(),
  }) : subjectId = Value(subjectId),
       title = Value(title),
       scheduledAt = Value(scheduledAt),
       estimatedMinutes = Value(estimatedMinutes),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<StudyTask> custom({
    Expression<int>? id,
    Expression<int>? subjectId,
    Expression<int>? chapterId,
    Expression<String>? title,
    Expression<String>? type,
    Expression<String>? dueAt,
    Expression<String>? scheduledAt,
    Expression<int>? estimatedMinutes,
    Expression<int>? completedMinutes,
    Expression<int>? priority,
    Expression<String>? status,
    Expression<int>? isRescheduled,
    Expression<int>? isPastPaper,
    Expression<int>? isTemplate,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? originalEstimatedMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (dueAt != null) 'due_at': dueAt,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (completedMinutes != null) 'completed_minutes': completedMinutes,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (isRescheduled != null) 'is_rescheduled': isRescheduled,
      if (isPastPaper != null) 'is_past_paper': isPastPaper,
      if (isTemplate != null) 'is_template': isTemplate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (originalEstimatedMinutes != null)
        'original_estimated_minutes': originalEstimatedMinutes,
    });
  }

  StudyTasksCompanion copyWith({
    Value<int>? id,
    Value<int>? subjectId,
    Value<int?>? chapterId,
    Value<String>? title,
    Value<String>? type,
    Value<String?>? dueAt,
    Value<String>? scheduledAt,
    Value<int>? estimatedMinutes,
    Value<int>? completedMinutes,
    Value<int>? priority,
    Value<String>? status,
    Value<int>? isRescheduled,
    Value<int>? isPastPaper,
    Value<int>? isTemplate,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int?>? originalEstimatedMinutes,
  }) {
    return StudyTasksCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      chapterId: chapterId ?? this.chapterId,
      title: title ?? this.title,
      type: type ?? this.type,
      dueAt: dueAt ?? this.dueAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      completedMinutes: completedMinutes ?? this.completedMinutes,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      isRescheduled: isRescheduled ?? this.isRescheduled,
      isPastPaper: isPastPaper ?? this.isPastPaper,
      isTemplate: isTemplate ?? this.isTemplate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      originalEstimatedMinutes:
          originalEstimatedMinutes ?? this.originalEstimatedMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<String>(dueAt.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<String>(scheduledAt.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (completedMinutes.present) {
      map['completed_minutes'] = Variable<int>(completedMinutes.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isRescheduled.present) {
      map['is_rescheduled'] = Variable<int>(isRescheduled.value);
    }
    if (isPastPaper.present) {
      map['is_past_paper'] = Variable<int>(isPastPaper.value);
    }
    if (isTemplate.present) {
      map['is_template'] = Variable<int>(isTemplate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (originalEstimatedMinutes.present) {
      map['original_estimated_minutes'] = Variable<int>(
        originalEstimatedMinutes.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudyTasksCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('chapterId: $chapterId, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('dueAt: $dueAt, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('completedMinutes: $completedMinutes, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('isRescheduled: $isRescheduled, ')
          ..write('isPastPaper: $isPastPaper, ')
          ..write('isTemplate: $isTemplate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('originalEstimatedMinutes: $originalEstimatedMinutes')
          ..write(')'))
        .toString();
  }
}

class $FocusSessionsTable extends FocusSessions
    with TableInfo<$FocusSessionsTable, FocusSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES study_tasks (id)',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<String> startedAt = GeneratedColumn<String>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<String> endedAt = GeneratedColumn<String>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedMinutesMeta = const VerificationMeta(
    'plannedMinutes',
  );
  @override
  late final GeneratedColumn<int> plannedMinutes = GeneratedColumn<int>(
    'planned_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(25),
  );
  static const VerificationMeta _completedMinutesMeta = const VerificationMeta(
    'completedMinutes',
  );
  @override
  late final GeneratedColumn<int> completedMinutes = GeneratedColumn<int>(
    'completed_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reflectionStatusMeta = const VerificationMeta(
    'reflectionStatus',
  );
  @override
  late final GeneratedColumn<String> reflectionStatus = GeneratedColumn<String>(
    'reflection_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parkingLotNotesMeta = const VerificationMeta(
    'parkingLotNotes',
  );
  @override
  late final GeneratedColumn<String> parkingLotNotes = GeneratedColumn<String>(
    'parking_lot_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    startedAt,
    endedAt,
    plannedMinutes,
    completedMinutes,
    status,
    createdAt,
    notes,
    reflectionStatus,
    parkingLotNotes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FocusSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('planned_minutes')) {
      context.handle(
        _plannedMinutesMeta,
        plannedMinutes.isAcceptableOrUnknown(
          data['planned_minutes']!,
          _plannedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('completed_minutes')) {
      context.handle(
        _completedMinutesMeta,
        completedMinutes.isAcceptableOrUnknown(
          data['completed_minutes']!,
          _completedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('reflection_status')) {
      context.handle(
        _reflectionStatusMeta,
        reflectionStatus.isAcceptableOrUnknown(
          data['reflection_status']!,
          _reflectionStatusMeta,
        ),
      );
    }
    if (data.containsKey('parking_lot_notes')) {
      context.handle(
        _parkingLotNotesMeta,
        parkingLotNotes.isAcceptableOrUnknown(
          data['parking_lot_notes']!,
          _parkingLotNotesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FocusSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusSession(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      ),
      startedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}started_at'],
          )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ended_at'],
      ),
      plannedMinutes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}planned_minutes'],
          )!,
      completedMinutes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}completed_minutes'],
          )!,
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}created_at'],
          )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      reflectionStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reflection_status'],
      ),
      parkingLotNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parking_lot_notes'],
      ),
    );
  }

  @override
  $FocusSessionsTable createAlias(String alias) {
    return $FocusSessionsTable(attachedDatabase, alias);
  }
}

class FocusSession extends DataClass implements Insertable<FocusSession> {
  final int id;
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
  const FocusSession({
    required this.id,
    this.taskId,
    required this.startedAt,
    this.endedAt,
    required this.plannedMinutes,
    required this.completedMinutes,
    required this.status,
    required this.createdAt,
    this.notes,
    this.reflectionStatus,
    this.parkingLotNotes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<int>(taskId);
    }
    map['started_at'] = Variable<String>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<String>(endedAt);
    }
    map['planned_minutes'] = Variable<int>(plannedMinutes);
    map['completed_minutes'] = Variable<int>(completedMinutes);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<String>(createdAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || reflectionStatus != null) {
      map['reflection_status'] = Variable<String>(reflectionStatus);
    }
    if (!nullToAbsent || parkingLotNotes != null) {
      map['parking_lot_notes'] = Variable<String>(parkingLotNotes);
    }
    return map;
  }

  FocusSessionsCompanion toCompanion(bool nullToAbsent) {
    return FocusSessionsCompanion(
      id: Value(id),
      taskId:
          taskId == null && nullToAbsent ? const Value.absent() : Value(taskId),
      startedAt: Value(startedAt),
      endedAt:
          endedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(endedAt),
      plannedMinutes: Value(plannedMinutes),
      completedMinutes: Value(completedMinutes),
      status: Value(status),
      createdAt: Value(createdAt),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      reflectionStatus:
          reflectionStatus == null && nullToAbsent
              ? const Value.absent()
              : Value(reflectionStatus),
      parkingLotNotes:
          parkingLotNotes == null && nullToAbsent
              ? const Value.absent()
              : Value(parkingLotNotes),
    );
  }

  factory FocusSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusSession(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<int?>(json['taskId']),
      startedAt: serializer.fromJson<String>(json['startedAt']),
      endedAt: serializer.fromJson<String?>(json['endedAt']),
      plannedMinutes: serializer.fromJson<int>(json['plannedMinutes']),
      completedMinutes: serializer.fromJson<int>(json['completedMinutes']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      reflectionStatus: serializer.fromJson<String?>(json['reflectionStatus']),
      parkingLotNotes: serializer.fromJson<String?>(json['parkingLotNotes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<int?>(taskId),
      'startedAt': serializer.toJson<String>(startedAt),
      'endedAt': serializer.toJson<String?>(endedAt),
      'plannedMinutes': serializer.toJson<int>(plannedMinutes),
      'completedMinutes': serializer.toJson<int>(completedMinutes),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<String>(createdAt),
      'notes': serializer.toJson<String?>(notes),
      'reflectionStatus': serializer.toJson<String?>(reflectionStatus),
      'parkingLotNotes': serializer.toJson<String?>(parkingLotNotes),
    };
  }

  FocusSession copyWith({
    int? id,
    Value<int?> taskId = const Value.absent(),
    String? startedAt,
    Value<String?> endedAt = const Value.absent(),
    int? plannedMinutes,
    int? completedMinutes,
    String? status,
    String? createdAt,
    Value<String?> notes = const Value.absent(),
    Value<String?> reflectionStatus = const Value.absent(),
    Value<String?> parkingLotNotes = const Value.absent(),
  }) => FocusSession(
    id: id ?? this.id,
    taskId: taskId.present ? taskId.value : this.taskId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    plannedMinutes: plannedMinutes ?? this.plannedMinutes,
    completedMinutes: completedMinutes ?? this.completedMinutes,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    notes: notes.present ? notes.value : this.notes,
    reflectionStatus:
        reflectionStatus.present
            ? reflectionStatus.value
            : this.reflectionStatus,
    parkingLotNotes:
        parkingLotNotes.present ? parkingLotNotes.value : this.parkingLotNotes,
  );
  FocusSession copyWithCompanion(FocusSessionsCompanion data) {
    return FocusSession(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      plannedMinutes:
          data.plannedMinutes.present
              ? data.plannedMinutes.value
              : this.plannedMinutes,
      completedMinutes:
          data.completedMinutes.present
              ? data.completedMinutes.value
              : this.completedMinutes,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      reflectionStatus:
          data.reflectionStatus.present
              ? data.reflectionStatus.value
              : this.reflectionStatus,
      parkingLotNotes:
          data.parkingLotNotes.present
              ? data.parkingLotNotes.value
              : this.parkingLotNotes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusSession(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('plannedMinutes: $plannedMinutes, ')
          ..write('completedMinutes: $completedMinutes, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('notes: $notes, ')
          ..write('reflectionStatus: $reflectionStatus, ')
          ..write('parkingLotNotes: $parkingLotNotes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    startedAt,
    endedAt,
    plannedMinutes,
    completedMinutes,
    status,
    createdAt,
    notes,
    reflectionStatus,
    parkingLotNotes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusSession &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.plannedMinutes == this.plannedMinutes &&
          other.completedMinutes == this.completedMinutes &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.notes == this.notes &&
          other.reflectionStatus == this.reflectionStatus &&
          other.parkingLotNotes == this.parkingLotNotes);
}

class FocusSessionsCompanion extends UpdateCompanion<FocusSession> {
  final Value<int> id;
  final Value<int?> taskId;
  final Value<String> startedAt;
  final Value<String?> endedAt;
  final Value<int> plannedMinutes;
  final Value<int> completedMinutes;
  final Value<String> status;
  final Value<String> createdAt;
  final Value<String?> notes;
  final Value<String?> reflectionStatus;
  final Value<String?> parkingLotNotes;
  const FocusSessionsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.plannedMinutes = const Value.absent(),
    this.completedMinutes = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.reflectionStatus = const Value.absent(),
    this.parkingLotNotes = const Value.absent(),
  });
  FocusSessionsCompanion.insert({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    required String startedAt,
    this.endedAt = const Value.absent(),
    this.plannedMinutes = const Value.absent(),
    this.completedMinutes = const Value.absent(),
    required String status,
    required String createdAt,
    this.notes = const Value.absent(),
    this.reflectionStatus = const Value.absent(),
    this.parkingLotNotes = const Value.absent(),
  }) : startedAt = Value(startedAt),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<FocusSession> custom({
    Expression<int>? id,
    Expression<int>? taskId,
    Expression<String>? startedAt,
    Expression<String>? endedAt,
    Expression<int>? plannedMinutes,
    Expression<int>? completedMinutes,
    Expression<String>? status,
    Expression<String>? createdAt,
    Expression<String>? notes,
    Expression<String>? reflectionStatus,
    Expression<String>? parkingLotNotes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (plannedMinutes != null) 'planned_minutes': plannedMinutes,
      if (completedMinutes != null) 'completed_minutes': completedMinutes,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (notes != null) 'notes': notes,
      if (reflectionStatus != null) 'reflection_status': reflectionStatus,
      if (parkingLotNotes != null) 'parking_lot_notes': parkingLotNotes,
    });
  }

  FocusSessionsCompanion copyWith({
    Value<int>? id,
    Value<int?>? taskId,
    Value<String>? startedAt,
    Value<String?>? endedAt,
    Value<int>? plannedMinutes,
    Value<int>? completedMinutes,
    Value<String>? status,
    Value<String>? createdAt,
    Value<String?>? notes,
    Value<String?>? reflectionStatus,
    Value<String?>? parkingLotNotes,
  }) {
    return FocusSessionsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      plannedMinutes: plannedMinutes ?? this.plannedMinutes,
      completedMinutes: completedMinutes ?? this.completedMinutes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      reflectionStatus: reflectionStatus ?? this.reflectionStatus,
      parkingLotNotes: parkingLotNotes ?? this.parkingLotNotes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<String>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<String>(endedAt.value);
    }
    if (plannedMinutes.present) {
      map['planned_minutes'] = Variable<int>(plannedMinutes.value);
    }
    if (completedMinutes.present) {
      map['completed_minutes'] = Variable<int>(completedMinutes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (reflectionStatus.present) {
      map['reflection_status'] = Variable<String>(reflectionStatus.value);
    }
    if (parkingLotNotes.present) {
      map['parking_lot_notes'] = Variable<String>(parkingLotNotes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('plannedMinutes: $plannedMinutes, ')
          ..write('completedMinutes: $completedMinutes, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('notes: $notes, ')
          ..write('reflectionStatus: $reflectionStatus, ')
          ..write('parkingLotNotes: $parkingLotNotes')
          ..write(')'))
        .toString();
  }
}

class $RevisionItemsTable extends RevisionItems
    with TableInfo<$RevisionItemsTable, RevisionItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RevisionItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<int> chapterId = GeneratedColumn<int>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chapters (id)',
    ),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<String> dueAt = GeneratedColumn<String>(
    'due_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recallConfidenceMeta = const VerificationMeta(
    'recallConfidence',
  );
  @override
  late final GeneratedColumn<int> recallConfidence = GeneratedColumn<int>(
    'recall_confidence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _easeFactorMeta = const VerificationMeta(
    'easeFactor',
  );
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
    'ease_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  static const VerificationMeta _repetitionsMeta = const VerificationMeta(
    'repetitions',
  );
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
    'repetitions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastReviewAtMeta = const VerificationMeta(
    'lastReviewAt',
  );
  @override
  late final GeneratedColumn<String> lastReviewAt = GeneratedColumn<String>(
    'last_review_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chapterId,
    dueAt,
    intervalDays,
    status,
    completedAt,
    createdAt,
    recallConfidence,
    easeFactor,
    repetitions,
    lastReviewAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'revision_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<RevisionItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_intervalDaysMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('recall_confidence')) {
      context.handle(
        _recallConfidenceMeta,
        recallConfidence.isAcceptableOrUnknown(
          data['recall_confidence']!,
          _recallConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
        _easeFactorMeta,
        easeFactor.isAcceptableOrUnknown(data['ease_factor']!, _easeFactorMeta),
      );
    }
    if (data.containsKey('repetitions')) {
      context.handle(
        _repetitionsMeta,
        repetitions.isAcceptableOrUnknown(
          data['repetitions']!,
          _repetitionsMeta,
        ),
      );
    }
    if (data.containsKey('last_review_at')) {
      context.handle(
        _lastReviewAtMeta,
        lastReviewAt.isAcceptableOrUnknown(
          data['last_review_at']!,
          _lastReviewAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RevisionItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RevisionItem(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      chapterId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}chapter_id'],
          )!,
      dueAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}due_at'],
          )!,
      intervalDays:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}interval_days'],
          )!,
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}created_at'],
          )!,
      recallConfidence:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}recall_confidence'],
          )!,
      easeFactor:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}ease_factor'],
          )!,
      repetitions:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}repetitions'],
          )!,
      lastReviewAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_review_at'],
      ),
    );
  }

  @override
  $RevisionItemsTable createAlias(String alias) {
    return $RevisionItemsTable(attachedDatabase, alias);
  }
}

class RevisionItem extends DataClass implements Insertable<RevisionItem> {
  final int id;
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
  const RevisionItem({
    required this.id,
    required this.chapterId,
    required this.dueAt,
    required this.intervalDays,
    required this.status,
    this.completedAt,
    required this.createdAt,
    required this.recallConfidence,
    required this.easeFactor,
    required this.repetitions,
    this.lastReviewAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['chapter_id'] = Variable<int>(chapterId);
    map['due_at'] = Variable<String>(dueAt);
    map['interval_days'] = Variable<int>(intervalDays);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['recall_confidence'] = Variable<int>(recallConfidence);
    map['ease_factor'] = Variable<double>(easeFactor);
    map['repetitions'] = Variable<int>(repetitions);
    if (!nullToAbsent || lastReviewAt != null) {
      map['last_review_at'] = Variable<String>(lastReviewAt);
    }
    return map;
  }

  RevisionItemsCompanion toCompanion(bool nullToAbsent) {
    return RevisionItemsCompanion(
      id: Value(id),
      chapterId: Value(chapterId),
      dueAt: Value(dueAt),
      intervalDays: Value(intervalDays),
      status: Value(status),
      completedAt:
          completedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(completedAt),
      createdAt: Value(createdAt),
      recallConfidence: Value(recallConfidence),
      easeFactor: Value(easeFactor),
      repetitions: Value(repetitions),
      lastReviewAt:
          lastReviewAt == null && nullToAbsent
              ? const Value.absent()
              : Value(lastReviewAt),
    );
  }

  factory RevisionItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RevisionItem(
      id: serializer.fromJson<int>(json['id']),
      chapterId: serializer.fromJson<int>(json['chapterId']),
      dueAt: serializer.fromJson<String>(json['dueAt']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      status: serializer.fromJson<String>(json['status']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      recallConfidence: serializer.fromJson<int>(json['recallConfidence']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      lastReviewAt: serializer.fromJson<String?>(json['lastReviewAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'chapterId': serializer.toJson<int>(chapterId),
      'dueAt': serializer.toJson<String>(dueAt),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'status': serializer.toJson<String>(status),
      'completedAt': serializer.toJson<int?>(completedAt),
      'createdAt': serializer.toJson<String>(createdAt),
      'recallConfidence': serializer.toJson<int>(recallConfidence),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'repetitions': serializer.toJson<int>(repetitions),
      'lastReviewAt': serializer.toJson<String?>(lastReviewAt),
    };
  }

  RevisionItem copyWith({
    int? id,
    int? chapterId,
    String? dueAt,
    int? intervalDays,
    String? status,
    Value<int?> completedAt = const Value.absent(),
    String? createdAt,
    int? recallConfidence,
    double? easeFactor,
    int? repetitions,
    Value<String?> lastReviewAt = const Value.absent(),
  }) => RevisionItem(
    id: id ?? this.id,
    chapterId: chapterId ?? this.chapterId,
    dueAt: dueAt ?? this.dueAt,
    intervalDays: intervalDays ?? this.intervalDays,
    status: status ?? this.status,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    recallConfidence: recallConfidence ?? this.recallConfidence,
    easeFactor: easeFactor ?? this.easeFactor,
    repetitions: repetitions ?? this.repetitions,
    lastReviewAt: lastReviewAt.present ? lastReviewAt.value : this.lastReviewAt,
  );
  RevisionItem copyWithCompanion(RevisionItemsCompanion data) {
    return RevisionItem(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      intervalDays:
          data.intervalDays.present
              ? data.intervalDays.value
              : this.intervalDays,
      status: data.status.present ? data.status.value : this.status,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      recallConfidence:
          data.recallConfidence.present
              ? data.recallConfidence.value
              : this.recallConfidence,
      easeFactor:
          data.easeFactor.present ? data.easeFactor.value : this.easeFactor,
      repetitions:
          data.repetitions.present ? data.repetitions.value : this.repetitions,
      lastReviewAt:
          data.lastReviewAt.present
              ? data.lastReviewAt.value
              : this.lastReviewAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RevisionItem(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('dueAt: $dueAt, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('recallConfidence: $recallConfidence, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('repetitions: $repetitions, ')
          ..write('lastReviewAt: $lastReviewAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    chapterId,
    dueAt,
    intervalDays,
    status,
    completedAt,
    createdAt,
    recallConfidence,
    easeFactor,
    repetitions,
    lastReviewAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RevisionItem &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.dueAt == this.dueAt &&
          other.intervalDays == this.intervalDays &&
          other.status == this.status &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.recallConfidence == this.recallConfidence &&
          other.easeFactor == this.easeFactor &&
          other.repetitions == this.repetitions &&
          other.lastReviewAt == this.lastReviewAt);
}

class RevisionItemsCompanion extends UpdateCompanion<RevisionItem> {
  final Value<int> id;
  final Value<int> chapterId;
  final Value<String> dueAt;
  final Value<int> intervalDays;
  final Value<String> status;
  final Value<int?> completedAt;
  final Value<String> createdAt;
  final Value<int> recallConfidence;
  final Value<double> easeFactor;
  final Value<int> repetitions;
  final Value<String?> lastReviewAt;
  const RevisionItemsCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.recallConfidence = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.lastReviewAt = const Value.absent(),
  });
  RevisionItemsCompanion.insert({
    this.id = const Value.absent(),
    required int chapterId,
    required String dueAt,
    required int intervalDays,
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    required String createdAt,
    this.recallConfidence = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.lastReviewAt = const Value.absent(),
  }) : chapterId = Value(chapterId),
       dueAt = Value(dueAt),
       intervalDays = Value(intervalDays),
       createdAt = Value(createdAt);
  static Insertable<RevisionItem> custom({
    Expression<int>? id,
    Expression<int>? chapterId,
    Expression<String>? dueAt,
    Expression<int>? intervalDays,
    Expression<String>? status,
    Expression<int>? completedAt,
    Expression<String>? createdAt,
    Expression<int>? recallConfidence,
    Expression<double>? easeFactor,
    Expression<int>? repetitions,
    Expression<String>? lastReviewAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (dueAt != null) 'due_at': dueAt,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (status != null) 'status': status,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (recallConfidence != null) 'recall_confidence': recallConfidence,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (repetitions != null) 'repetitions': repetitions,
      if (lastReviewAt != null) 'last_review_at': lastReviewAt,
    });
  }

  RevisionItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? chapterId,
    Value<String>? dueAt,
    Value<int>? intervalDays,
    Value<String>? status,
    Value<int?>? completedAt,
    Value<String>? createdAt,
    Value<int>? recallConfidence,
    Value<double>? easeFactor,
    Value<int>? repetitions,
    Value<String?>? lastReviewAt,
  }) {
    return RevisionItemsCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      dueAt: dueAt ?? this.dueAt,
      intervalDays: intervalDays ?? this.intervalDays,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      recallConfidence: recallConfidence ?? this.recallConfidence,
      easeFactor: easeFactor ?? this.easeFactor,
      repetitions: repetitions ?? this.repetitions,
      lastReviewAt: lastReviewAt ?? this.lastReviewAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<String>(dueAt.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (recallConfidence.present) {
      map['recall_confidence'] = Variable<int>(recallConfidence.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (lastReviewAt.present) {
      map['last_review_at'] = Variable<String>(lastReviewAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RevisionItemsCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('dueAt: $dueAt, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('recallConfidence: $recallConfidence, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('repetitions: $repetitions, ')
          ..write('lastReviewAt: $lastReviewAt')
          ..write(')'))
        .toString();
  }
}

class $ResourcesTable extends Resources
    with TableInfo<$ResourcesTable, Resource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subjects (id)',
    ),
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<int> chapterId = GeneratedColumn<int>(
    'chapter_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chapters (id)',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<int> isPinned = GeneratedColumn<int>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _folderMeta = const VerificationMeta('folder');
  @override
  late final GeneratedColumn<String> folder = GeneratedColumn<String>(
    'folder',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _practicalIdMeta = const VerificationMeta(
    'practicalId',
  );
  @override
  late final GeneratedColumn<int> practicalId = GeneratedColumn<int>(
    'practical_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subjectId,
    chapterId,
    type,
    title,
    localPath,
    createdAt,
    fileSize,
    isPinned,
    tags,
    folder,
    taskId,
    practicalId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resources';
  @override
  VerificationContext validateIntegrity(
    Insertable<Resource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('folder')) {
      context.handle(
        _folderMeta,
        folder.isAcceptableOrUnknown(data['folder']!, _folderMeta),
      );
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    }
    if (data.containsKey('practical_id')) {
      context.handle(
        _practicalIdMeta,
        practicalId.isAcceptableOrUnknown(
          data['practical_id']!,
          _practicalIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Resource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Resource(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      subjectId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}subject_id'],
          )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_id'],
      ),
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      localPath:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}local_path'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}created_at'],
          )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      ),
      isPinned:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}is_pinned'],
          )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
      folder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder'],
      ),
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      ),
      practicalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}practical_id'],
      ),
    );
  }

  @override
  $ResourcesTable createAlias(String alias) {
    return $ResourcesTable(attachedDatabase, alias);
  }
}

class Resource extends DataClass implements Insertable<Resource> {
  final int id;
  final int subjectId;
  final int? chapterId;
  final String type;
  final String title;
  final String localPath;
  final String createdAt;
  final int? fileSize;
  final int isPinned;
  final String? tags;
  final String? folder;
  final int? taskId;
  final int? practicalId;
  const Resource({
    required this.id,
    required this.subjectId,
    this.chapterId,
    required this.type,
    required this.title,
    required this.localPath,
    required this.createdAt,
    this.fileSize,
    required this.isPinned,
    this.tags,
    this.folder,
    this.taskId,
    this.practicalId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['subject_id'] = Variable<int>(subjectId);
    if (!nullToAbsent || chapterId != null) {
      map['chapter_id'] = Variable<int>(chapterId);
    }
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['local_path'] = Variable<String>(localPath);
    map['created_at'] = Variable<String>(createdAt);
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    map['is_pinned'] = Variable<int>(isPinned);
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    if (!nullToAbsent || folder != null) {
      map['folder'] = Variable<String>(folder);
    }
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<int>(taskId);
    }
    if (!nullToAbsent || practicalId != null) {
      map['practical_id'] = Variable<int>(practicalId);
    }
    return map;
  }

  ResourcesCompanion toCompanion(bool nullToAbsent) {
    return ResourcesCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      chapterId:
          chapterId == null && nullToAbsent
              ? const Value.absent()
              : Value(chapterId),
      type: Value(type),
      title: Value(title),
      localPath: Value(localPath),
      createdAt: Value(createdAt),
      fileSize:
          fileSize == null && nullToAbsent
              ? const Value.absent()
              : Value(fileSize),
      isPinned: Value(isPinned),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      folder:
          folder == null && nullToAbsent ? const Value.absent() : Value(folder),
      taskId:
          taskId == null && nullToAbsent ? const Value.absent() : Value(taskId),
      practicalId:
          practicalId == null && nullToAbsent
              ? const Value.absent()
              : Value(practicalId),
    );
  }

  factory Resource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Resource(
      id: serializer.fromJson<int>(json['id']),
      subjectId: serializer.fromJson<int>(json['subjectId']),
      chapterId: serializer.fromJson<int?>(json['chapterId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      localPath: serializer.fromJson<String>(json['localPath']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      isPinned: serializer.fromJson<int>(json['isPinned']),
      tags: serializer.fromJson<String?>(json['tags']),
      folder: serializer.fromJson<String?>(json['folder']),
      taskId: serializer.fromJson<int?>(json['taskId']),
      practicalId: serializer.fromJson<int?>(json['practicalId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'subjectId': serializer.toJson<int>(subjectId),
      'chapterId': serializer.toJson<int?>(chapterId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'localPath': serializer.toJson<String>(localPath),
      'createdAt': serializer.toJson<String>(createdAt),
      'fileSize': serializer.toJson<int?>(fileSize),
      'isPinned': serializer.toJson<int>(isPinned),
      'tags': serializer.toJson<String?>(tags),
      'folder': serializer.toJson<String?>(folder),
      'taskId': serializer.toJson<int?>(taskId),
      'practicalId': serializer.toJson<int?>(practicalId),
    };
  }

  Resource copyWith({
    int? id,
    int? subjectId,
    Value<int?> chapterId = const Value.absent(),
    String? type,
    String? title,
    String? localPath,
    String? createdAt,
    Value<int?> fileSize = const Value.absent(),
    int? isPinned,
    Value<String?> tags = const Value.absent(),
    Value<String?> folder = const Value.absent(),
    Value<int?> taskId = const Value.absent(),
    Value<int?> practicalId = const Value.absent(),
  }) => Resource(
    id: id ?? this.id,
    subjectId: subjectId ?? this.subjectId,
    chapterId: chapterId.present ? chapterId.value : this.chapterId,
    type: type ?? this.type,
    title: title ?? this.title,
    localPath: localPath ?? this.localPath,
    createdAt: createdAt ?? this.createdAt,
    fileSize: fileSize.present ? fileSize.value : this.fileSize,
    isPinned: isPinned ?? this.isPinned,
    tags: tags.present ? tags.value : this.tags,
    folder: folder.present ? folder.value : this.folder,
    taskId: taskId.present ? taskId.value : this.taskId,
    practicalId: practicalId.present ? practicalId.value : this.practicalId,
  );
  Resource copyWithCompanion(ResourcesCompanion data) {
    return Resource(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      tags: data.tags.present ? data.tags.value : this.tags,
      folder: data.folder.present ? data.folder.value : this.folder,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      practicalId:
          data.practicalId.present ? data.practicalId.value : this.practicalId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Resource(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('chapterId: $chapterId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('localPath: $localPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('fileSize: $fileSize, ')
          ..write('isPinned: $isPinned, ')
          ..write('tags: $tags, ')
          ..write('folder: $folder, ')
          ..write('taskId: $taskId, ')
          ..write('practicalId: $practicalId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    subjectId,
    chapterId,
    type,
    title,
    localPath,
    createdAt,
    fileSize,
    isPinned,
    tags,
    folder,
    taskId,
    practicalId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Resource &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.chapterId == this.chapterId &&
          other.type == this.type &&
          other.title == this.title &&
          other.localPath == this.localPath &&
          other.createdAt == this.createdAt &&
          other.fileSize == this.fileSize &&
          other.isPinned == this.isPinned &&
          other.tags == this.tags &&
          other.folder == this.folder &&
          other.taskId == this.taskId &&
          other.practicalId == this.practicalId);
}

class ResourcesCompanion extends UpdateCompanion<Resource> {
  final Value<int> id;
  final Value<int> subjectId;
  final Value<int?> chapterId;
  final Value<String> type;
  final Value<String> title;
  final Value<String> localPath;
  final Value<String> createdAt;
  final Value<int?> fileSize;
  final Value<int> isPinned;
  final Value<String?> tags;
  final Value<String?> folder;
  final Value<int?> taskId;
  final Value<int?> practicalId;
  const ResourcesCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.localPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.tags = const Value.absent(),
    this.folder = const Value.absent(),
    this.taskId = const Value.absent(),
    this.practicalId = const Value.absent(),
  });
  ResourcesCompanion.insert({
    this.id = const Value.absent(),
    required int subjectId,
    this.chapterId = const Value.absent(),
    required String type,
    required String title,
    required String localPath,
    required String createdAt,
    this.fileSize = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.tags = const Value.absent(),
    this.folder = const Value.absent(),
    this.taskId = const Value.absent(),
    this.practicalId = const Value.absent(),
  }) : subjectId = Value(subjectId),
       type = Value(type),
       title = Value(title),
       localPath = Value(localPath),
       createdAt = Value(createdAt);
  static Insertable<Resource> custom({
    Expression<int>? id,
    Expression<int>? subjectId,
    Expression<int>? chapterId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? localPath,
    Expression<String>? createdAt,
    Expression<int>? fileSize,
    Expression<int>? isPinned,
    Expression<String>? tags,
    Expression<String>? folder,
    Expression<int>? taskId,
    Expression<int>? practicalId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (localPath != null) 'local_path': localPath,
      if (createdAt != null) 'created_at': createdAt,
      if (fileSize != null) 'file_size': fileSize,
      if (isPinned != null) 'is_pinned': isPinned,
      if (tags != null) 'tags': tags,
      if (folder != null) 'folder': folder,
      if (taskId != null) 'task_id': taskId,
      if (practicalId != null) 'practical_id': practicalId,
    });
  }

  ResourcesCompanion copyWith({
    Value<int>? id,
    Value<int>? subjectId,
    Value<int?>? chapterId,
    Value<String>? type,
    Value<String>? title,
    Value<String>? localPath,
    Value<String>? createdAt,
    Value<int?>? fileSize,
    Value<int>? isPinned,
    Value<String?>? tags,
    Value<String?>? folder,
    Value<int?>? taskId,
    Value<int?>? practicalId,
  }) {
    return ResourcesCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      chapterId: chapterId ?? this.chapterId,
      type: type ?? this.type,
      title: title ?? this.title,
      localPath: localPath ?? this.localPath,
      createdAt: createdAt ?? this.createdAt,
      fileSize: fileSize ?? this.fileSize,
      isPinned: isPinned ?? this.isPinned,
      tags: tags ?? this.tags,
      folder: folder ?? this.folder,
      taskId: taskId ?? this.taskId,
      practicalId: practicalId ?? this.practicalId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<int>(isPinned.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (folder.present) {
      map['folder'] = Variable<String>(folder.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (practicalId.present) {
      map['practical_id'] = Variable<int>(practicalId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResourcesCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('chapterId: $chapterId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('localPath: $localPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('fileSize: $fileSize, ')
          ..write('isPinned: $isPinned, ')
          ..write('tags: $tags, ')
          ..write('folder: $folder, ')
          ..write('taskId: $taskId, ')
          ..write('practicalId: $practicalId')
          ..write(')'))
        .toString();
  }
}

class $PracticalRecordsTable extends PracticalRecords
    with TableInfo<$PracticalRecordsTable, PracticalRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PracticalRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subjects (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<String> dueAt = GeneratedColumn<String>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<int> resourceId = GeneratedColumn<int>(
    'resource_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _objectiveMeta = const VerificationMeta(
    'objective',
  );
  @override
  late final GeneratedColumn<String> objective = GeneratedColumn<String>(
    'objective',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _apparatusMeta = const VerificationMeta(
    'apparatus',
  );
  @override
  late final GeneratedColumn<String> apparatus = GeneratedColumn<String>(
    'apparatus',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _procedureMeta = const VerificationMeta(
    'procedure',
  );
  @override
  late final GeneratedColumn<String> procedure = GeneratedColumn<String>(
    'procedure',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observationMeta = const VerificationMeta(
    'observation',
  );
  @override
  late final GeneratedColumn<String> observation = GeneratedColumn<String>(
    'observation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vivaQuestionsMeta = const VerificationMeta(
    'vivaQuestions',
  );
  @override
  late final GeneratedColumn<String> vivaQuestions = GeneratedColumn<String>(
    'viva_questions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subjectId,
    title,
    dueAt,
    status,
    resourceId,
    createdAt,
    objective,
    apparatus,
    procedure,
    observation,
    vivaQuestions,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practical_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<PracticalRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('objective')) {
      context.handle(
        _objectiveMeta,
        objective.isAcceptableOrUnknown(data['objective']!, _objectiveMeta),
      );
    }
    if (data.containsKey('apparatus')) {
      context.handle(
        _apparatusMeta,
        apparatus.isAcceptableOrUnknown(data['apparatus']!, _apparatusMeta),
      );
    }
    if (data.containsKey('procedure')) {
      context.handle(
        _procedureMeta,
        procedure.isAcceptableOrUnknown(data['procedure']!, _procedureMeta),
      );
    }
    if (data.containsKey('observation')) {
      context.handle(
        _observationMeta,
        observation.isAcceptableOrUnknown(
          data['observation']!,
          _observationMeta,
        ),
      );
    }
    if (data.containsKey('viva_questions')) {
      context.handle(
        _vivaQuestionsMeta,
        vivaQuestions.isAcceptableOrUnknown(
          data['viva_questions']!,
          _vivaQuestionsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PracticalRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PracticalRecord(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      subjectId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}subject_id'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_at'],
      ),
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resource_id'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}created_at'],
          )!,
      objective: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}objective'],
      ),
      apparatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apparatus'],
      ),
      procedure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}procedure'],
      ),
      observation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation'],
      ),
      vivaQuestions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}viva_questions'],
      ),
    );
  }

  @override
  $PracticalRecordsTable createAlias(String alias) {
    return $PracticalRecordsTable(attachedDatabase, alias);
  }
}

class PracticalRecord extends DataClass implements Insertable<PracticalRecord> {
  final int id;
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
  const PracticalRecord({
    required this.id,
    required this.subjectId,
    required this.title,
    this.dueAt,
    required this.status,
    this.resourceId,
    required this.createdAt,
    this.objective,
    this.apparatus,
    this.procedure,
    this.observation,
    this.vivaQuestions,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['subject_id'] = Variable<int>(subjectId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<String>(dueAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || resourceId != null) {
      map['resource_id'] = Variable<int>(resourceId);
    }
    map['created_at'] = Variable<String>(createdAt);
    if (!nullToAbsent || objective != null) {
      map['objective'] = Variable<String>(objective);
    }
    if (!nullToAbsent || apparatus != null) {
      map['apparatus'] = Variable<String>(apparatus);
    }
    if (!nullToAbsent || procedure != null) {
      map['procedure'] = Variable<String>(procedure);
    }
    if (!nullToAbsent || observation != null) {
      map['observation'] = Variable<String>(observation);
    }
    if (!nullToAbsent || vivaQuestions != null) {
      map['viva_questions'] = Variable<String>(vivaQuestions);
    }
    return map;
  }

  PracticalRecordsCompanion toCompanion(bool nullToAbsent) {
    return PracticalRecordsCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      title: Value(title),
      dueAt:
          dueAt == null && nullToAbsent ? const Value.absent() : Value(dueAt),
      status: Value(status),
      resourceId:
          resourceId == null && nullToAbsent
              ? const Value.absent()
              : Value(resourceId),
      createdAt: Value(createdAt),
      objective:
          objective == null && nullToAbsent
              ? const Value.absent()
              : Value(objective),
      apparatus:
          apparatus == null && nullToAbsent
              ? const Value.absent()
              : Value(apparatus),
      procedure:
          procedure == null && nullToAbsent
              ? const Value.absent()
              : Value(procedure),
      observation:
          observation == null && nullToAbsent
              ? const Value.absent()
              : Value(observation),
      vivaQuestions:
          vivaQuestions == null && nullToAbsent
              ? const Value.absent()
              : Value(vivaQuestions),
    );
  }

  factory PracticalRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PracticalRecord(
      id: serializer.fromJson<int>(json['id']),
      subjectId: serializer.fromJson<int>(json['subjectId']),
      title: serializer.fromJson<String>(json['title']),
      dueAt: serializer.fromJson<String?>(json['dueAt']),
      status: serializer.fromJson<String>(json['status']),
      resourceId: serializer.fromJson<int?>(json['resourceId']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      objective: serializer.fromJson<String?>(json['objective']),
      apparatus: serializer.fromJson<String?>(json['apparatus']),
      procedure: serializer.fromJson<String?>(json['procedure']),
      observation: serializer.fromJson<String?>(json['observation']),
      vivaQuestions: serializer.fromJson<String?>(json['vivaQuestions']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'subjectId': serializer.toJson<int>(subjectId),
      'title': serializer.toJson<String>(title),
      'dueAt': serializer.toJson<String?>(dueAt),
      'status': serializer.toJson<String>(status),
      'resourceId': serializer.toJson<int?>(resourceId),
      'createdAt': serializer.toJson<String>(createdAt),
      'objective': serializer.toJson<String?>(objective),
      'apparatus': serializer.toJson<String?>(apparatus),
      'procedure': serializer.toJson<String?>(procedure),
      'observation': serializer.toJson<String?>(observation),
      'vivaQuestions': serializer.toJson<String?>(vivaQuestions),
    };
  }

  PracticalRecord copyWith({
    int? id,
    int? subjectId,
    String? title,
    Value<String?> dueAt = const Value.absent(),
    String? status,
    Value<int?> resourceId = const Value.absent(),
    String? createdAt,
    Value<String?> objective = const Value.absent(),
    Value<String?> apparatus = const Value.absent(),
    Value<String?> procedure = const Value.absent(),
    Value<String?> observation = const Value.absent(),
    Value<String?> vivaQuestions = const Value.absent(),
  }) => PracticalRecord(
    id: id ?? this.id,
    subjectId: subjectId ?? this.subjectId,
    title: title ?? this.title,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    status: status ?? this.status,
    resourceId: resourceId.present ? resourceId.value : this.resourceId,
    createdAt: createdAt ?? this.createdAt,
    objective: objective.present ? objective.value : this.objective,
    apparatus: apparatus.present ? apparatus.value : this.apparatus,
    procedure: procedure.present ? procedure.value : this.procedure,
    observation: observation.present ? observation.value : this.observation,
    vivaQuestions:
        vivaQuestions.present ? vivaQuestions.value : this.vivaQuestions,
  );
  PracticalRecord copyWithCompanion(PracticalRecordsCompanion data) {
    return PracticalRecord(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      title: data.title.present ? data.title.value : this.title,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      status: data.status.present ? data.status.value : this.status,
      resourceId:
          data.resourceId.present ? data.resourceId.value : this.resourceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      objective: data.objective.present ? data.objective.value : this.objective,
      apparatus: data.apparatus.present ? data.apparatus.value : this.apparatus,
      procedure: data.procedure.present ? data.procedure.value : this.procedure,
      observation:
          data.observation.present ? data.observation.value : this.observation,
      vivaQuestions:
          data.vivaQuestions.present
              ? data.vivaQuestions.value
              : this.vivaQuestions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PracticalRecord(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('title: $title, ')
          ..write('dueAt: $dueAt, ')
          ..write('status: $status, ')
          ..write('resourceId: $resourceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('objective: $objective, ')
          ..write('apparatus: $apparatus, ')
          ..write('procedure: $procedure, ')
          ..write('observation: $observation, ')
          ..write('vivaQuestions: $vivaQuestions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    subjectId,
    title,
    dueAt,
    status,
    resourceId,
    createdAt,
    objective,
    apparatus,
    procedure,
    observation,
    vivaQuestions,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PracticalRecord &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.title == this.title &&
          other.dueAt == this.dueAt &&
          other.status == this.status &&
          other.resourceId == this.resourceId &&
          other.createdAt == this.createdAt &&
          other.objective == this.objective &&
          other.apparatus == this.apparatus &&
          other.procedure == this.procedure &&
          other.observation == this.observation &&
          other.vivaQuestions == this.vivaQuestions);
}

class PracticalRecordsCompanion extends UpdateCompanion<PracticalRecord> {
  final Value<int> id;
  final Value<int> subjectId;
  final Value<String> title;
  final Value<String?> dueAt;
  final Value<String> status;
  final Value<int?> resourceId;
  final Value<String> createdAt;
  final Value<String?> objective;
  final Value<String?> apparatus;
  final Value<String?> procedure;
  final Value<String?> observation;
  final Value<String?> vivaQuestions;
  const PracticalRecordsCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.title = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.status = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.objective = const Value.absent(),
    this.apparatus = const Value.absent(),
    this.procedure = const Value.absent(),
    this.observation = const Value.absent(),
    this.vivaQuestions = const Value.absent(),
  });
  PracticalRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int subjectId,
    required String title,
    this.dueAt = const Value.absent(),
    this.status = const Value.absent(),
    this.resourceId = const Value.absent(),
    required String createdAt,
    this.objective = const Value.absent(),
    this.apparatus = const Value.absent(),
    this.procedure = const Value.absent(),
    this.observation = const Value.absent(),
    this.vivaQuestions = const Value.absent(),
  }) : subjectId = Value(subjectId),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<PracticalRecord> custom({
    Expression<int>? id,
    Expression<int>? subjectId,
    Expression<String>? title,
    Expression<String>? dueAt,
    Expression<String>? status,
    Expression<int>? resourceId,
    Expression<String>? createdAt,
    Expression<String>? objective,
    Expression<String>? apparatus,
    Expression<String>? procedure,
    Expression<String>? observation,
    Expression<String>? vivaQuestions,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (title != null) 'title': title,
      if (dueAt != null) 'due_at': dueAt,
      if (status != null) 'status': status,
      if (resourceId != null) 'resource_id': resourceId,
      if (createdAt != null) 'created_at': createdAt,
      if (objective != null) 'objective': objective,
      if (apparatus != null) 'apparatus': apparatus,
      if (procedure != null) 'procedure': procedure,
      if (observation != null) 'observation': observation,
      if (vivaQuestions != null) 'viva_questions': vivaQuestions,
    });
  }

  PracticalRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? subjectId,
    Value<String>? title,
    Value<String?>? dueAt,
    Value<String>? status,
    Value<int?>? resourceId,
    Value<String>? createdAt,
    Value<String?>? objective,
    Value<String?>? apparatus,
    Value<String?>? procedure,
    Value<String?>? observation,
    Value<String?>? vivaQuestions,
  }) {
    return PracticalRecordsCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      dueAt: dueAt ?? this.dueAt,
      status: status ?? this.status,
      resourceId: resourceId ?? this.resourceId,
      createdAt: createdAt ?? this.createdAt,
      objective: objective ?? this.objective,
      apparatus: apparatus ?? this.apparatus,
      procedure: procedure ?? this.procedure,
      observation: observation ?? this.observation,
      vivaQuestions: vivaQuestions ?? this.vivaQuestions,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<String>(dueAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<int>(resourceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (objective.present) {
      map['objective'] = Variable<String>(objective.value);
    }
    if (apparatus.present) {
      map['apparatus'] = Variable<String>(apparatus.value);
    }
    if (procedure.present) {
      map['procedure'] = Variable<String>(procedure.value);
    }
    if (observation.present) {
      map['observation'] = Variable<String>(observation.value);
    }
    if (vivaQuestions.present) {
      map['viva_questions'] = Variable<String>(vivaQuestions.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PracticalRecordsCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('title: $title, ')
          ..write('dueAt: $dueAt, ')
          ..write('status: $status, ')
          ..write('resourceId: $resourceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('objective: $objective, ')
          ..write('apparatus: $apparatus, ')
          ..write('procedure: $procedure, ')
          ..write('observation: $observation, ')
          ..write('vivaQuestions: $vivaQuestions')
          ..write(')'))
        .toString();
  }
}

class $BackupRecordsTable extends BackupRecords
    with TableInfo<$BackupRecordsTable, BackupRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationMeta = const VerificationMeta(
    'destination',
  );
  @override
  late final GeneratedColumn<String> destination = GeneratedColumn<String>(
    'destination',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, destination, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<BackupRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('destination')) {
      context.handle(
        _destinationMeta,
        destination.isAcceptableOrUnknown(
          data['destination']!,
          _destinationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BackupRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupRecord(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}created_at'],
          )!,
      destination:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}destination'],
          )!,
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
    );
  }

  @override
  $BackupRecordsTable createAlias(String alias) {
    return $BackupRecordsTable(attachedDatabase, alias);
  }
}

class BackupRecord extends DataClass implements Insertable<BackupRecord> {
  final int id;
  final String createdAt;
  final String destination;
  final String status;
  const BackupRecord({
    required this.id,
    required this.createdAt,
    required this.destination,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['destination'] = Variable<String>(destination);
    map['status'] = Variable<String>(status);
    return map;
  }

  BackupRecordsCompanion toCompanion(bool nullToAbsent) {
    return BackupRecordsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      destination: Value(destination),
      status: Value(status),
    );
  }

  factory BackupRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupRecord(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      destination: serializer.fromJson<String>(json['destination']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'destination': serializer.toJson<String>(destination),
      'status': serializer.toJson<String>(status),
    };
  }

  BackupRecord copyWith({
    int? id,
    String? createdAt,
    String? destination,
    String? status,
  }) => BackupRecord(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    destination: destination ?? this.destination,
    status: status ?? this.status,
  );
  BackupRecord copyWithCompanion(BackupRecordsCompanion data) {
    return BackupRecord(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      destination:
          data.destination.present ? data.destination.value : this.destination,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupRecord(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('destination: $destination, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, destination, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupRecord &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.destination == this.destination &&
          other.status == this.status);
}

class BackupRecordsCompanion extends UpdateCompanion<BackupRecord> {
  final Value<int> id;
  final Value<String> createdAt;
  final Value<String> destination;
  final Value<String> status;
  const BackupRecordsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.destination = const Value.absent(),
    this.status = const Value.absent(),
  });
  BackupRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String createdAt,
    required String destination,
    required String status,
  }) : createdAt = Value(createdAt),
       destination = Value(destination),
       status = Value(status);
  static Insertable<BackupRecord> custom({
    Expression<int>? id,
    Expression<String>? createdAt,
    Expression<String>? destination,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (destination != null) 'destination': destination,
      if (status != null) 'status': status,
    });
  }

  BackupRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? createdAt,
    Value<String>? destination,
    Value<String>? status,
  }) {
    return BackupRecordsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      destination: destination ?? this.destination,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (destination.present) {
      map['destination'] = Variable<String>(destination.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupRecordsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('destination: $destination, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $SyllabusTemplatesTable extends SyllabusTemplates
    with TableInfo<$SyllabusTemplatesTable, SyllabusTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyllabusTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _templateVersionMeta = const VerificationMeta(
    'templateVersion',
  );
  @override
  late final GeneratedColumn<int> templateVersion = GeneratedColumn<int>(
    'template_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _exportedAtMeta = const VerificationMeta(
    'exportedAt',
  );
  @override
  late final GeneratedColumn<String> exportedAt = GeneratedColumn<String>(
    'exported_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceAppMeta = const VerificationMeta(
    'sourceApp',
  );
  @override
  late final GeneratedColumn<String> sourceApp = GeneratedColumn<String>(
    'source_app',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceAttributionMeta = const VerificationMeta(
    'sourceAttribution',
  );
  @override
  late final GeneratedColumn<String> sourceAttribution =
      GeneratedColumn<String>(
        'source_attribution',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<String> importedAt = GeneratedColumn<String>(
    'imported_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentTierMeta = const VerificationMeta(
    'contentTier',
  );
  @override
  late final GeneratedColumn<String> contentTier = GeneratedColumn<String>(
    'content_tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('official'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    templateVersion,
    exportedAt,
    sourceApp,
    sourceAttribution,
    importedAt,
    content,
    contentTier,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'syllabus_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyllabusTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('template_version')) {
      context.handle(
        _templateVersionMeta,
        templateVersion.isAcceptableOrUnknown(
          data['template_version']!,
          _templateVersionMeta,
        ),
      );
    }
    if (data.containsKey('exported_at')) {
      context.handle(
        _exportedAtMeta,
        exportedAt.isAcceptableOrUnknown(data['exported_at']!, _exportedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_exportedAtMeta);
    }
    if (data.containsKey('source_app')) {
      context.handle(
        _sourceAppMeta,
        sourceApp.isAcceptableOrUnknown(data['source_app']!, _sourceAppMeta),
      );
    }
    if (data.containsKey('source_attribution')) {
      context.handle(
        _sourceAttributionMeta,
        sourceAttribution.isAcceptableOrUnknown(
          data['source_attribution']!,
          _sourceAttributionMeta,
        ),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('content_tier')) {
      context.handle(
        _contentTierMeta,
        contentTier.isAcceptableOrUnknown(
          data['content_tier']!,
          _contentTierMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyllabusTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyllabusTemplate(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      templateVersion:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}template_version'],
          )!,
      exportedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}exported_at'],
          )!,
      sourceApp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_app'],
      ),
      sourceAttribution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_attribution'],
      ),
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}imported_at'],
      ),
      content:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}content'],
          )!,
      contentTier:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}content_tier'],
          )!,
    );
  }

  @override
  $SyllabusTemplatesTable createAlias(String alias) {
    return $SyllabusTemplatesTable(attachedDatabase, alias);
  }
}

class SyllabusTemplate extends DataClass
    implements Insertable<SyllabusTemplate> {
  final int id;
  final int templateVersion;
  final String exportedAt;
  final String? sourceApp;
  final String? sourceAttribution;
  final String? importedAt;
  final String content;
  final String contentTier;
  const SyllabusTemplate({
    required this.id,
    required this.templateVersion,
    required this.exportedAt,
    this.sourceApp,
    this.sourceAttribution,
    this.importedAt,
    required this.content,
    required this.contentTier,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['template_version'] = Variable<int>(templateVersion);
    map['exported_at'] = Variable<String>(exportedAt);
    if (!nullToAbsent || sourceApp != null) {
      map['source_app'] = Variable<String>(sourceApp);
    }
    if (!nullToAbsent || sourceAttribution != null) {
      map['source_attribution'] = Variable<String>(sourceAttribution);
    }
    if (!nullToAbsent || importedAt != null) {
      map['imported_at'] = Variable<String>(importedAt);
    }
    map['content'] = Variable<String>(content);
    map['content_tier'] = Variable<String>(contentTier);
    return map;
  }

  SyllabusTemplatesCompanion toCompanion(bool nullToAbsent) {
    return SyllabusTemplatesCompanion(
      id: Value(id),
      templateVersion: Value(templateVersion),
      exportedAt: Value(exportedAt),
      sourceApp:
          sourceApp == null && nullToAbsent
              ? const Value.absent()
              : Value(sourceApp),
      sourceAttribution:
          sourceAttribution == null && nullToAbsent
              ? const Value.absent()
              : Value(sourceAttribution),
      importedAt:
          importedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(importedAt),
      content: Value(content),
      contentTier: Value(contentTier),
    );
  }

  factory SyllabusTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyllabusTemplate(
      id: serializer.fromJson<int>(json['id']),
      templateVersion: serializer.fromJson<int>(json['templateVersion']),
      exportedAt: serializer.fromJson<String>(json['exportedAt']),
      sourceApp: serializer.fromJson<String?>(json['sourceApp']),
      sourceAttribution: serializer.fromJson<String?>(
        json['sourceAttribution'],
      ),
      importedAt: serializer.fromJson<String?>(json['importedAt']),
      content: serializer.fromJson<String>(json['content']),
      contentTier: serializer.fromJson<String>(json['contentTier']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'templateVersion': serializer.toJson<int>(templateVersion),
      'exportedAt': serializer.toJson<String>(exportedAt),
      'sourceApp': serializer.toJson<String?>(sourceApp),
      'sourceAttribution': serializer.toJson<String?>(sourceAttribution),
      'importedAt': serializer.toJson<String?>(importedAt),
      'content': serializer.toJson<String>(content),
      'contentTier': serializer.toJson<String>(contentTier),
    };
  }

  SyllabusTemplate copyWith({
    int? id,
    int? templateVersion,
    String? exportedAt,
    Value<String?> sourceApp = const Value.absent(),
    Value<String?> sourceAttribution = const Value.absent(),
    Value<String?> importedAt = const Value.absent(),
    String? content,
    String? contentTier,
  }) => SyllabusTemplate(
    id: id ?? this.id,
    templateVersion: templateVersion ?? this.templateVersion,
    exportedAt: exportedAt ?? this.exportedAt,
    sourceApp: sourceApp.present ? sourceApp.value : this.sourceApp,
    sourceAttribution:
        sourceAttribution.present
            ? sourceAttribution.value
            : this.sourceAttribution,
    importedAt: importedAt.present ? importedAt.value : this.importedAt,
    content: content ?? this.content,
    contentTier: contentTier ?? this.contentTier,
  );
  SyllabusTemplate copyWithCompanion(SyllabusTemplatesCompanion data) {
    return SyllabusTemplate(
      id: data.id.present ? data.id.value : this.id,
      templateVersion:
          data.templateVersion.present
              ? data.templateVersion.value
              : this.templateVersion,
      exportedAt:
          data.exportedAt.present ? data.exportedAt.value : this.exportedAt,
      sourceApp: data.sourceApp.present ? data.sourceApp.value : this.sourceApp,
      sourceAttribution:
          data.sourceAttribution.present
              ? data.sourceAttribution.value
              : this.sourceAttribution,
      importedAt:
          data.importedAt.present ? data.importedAt.value : this.importedAt,
      content: data.content.present ? data.content.value : this.content,
      contentTier:
          data.contentTier.present ? data.contentTier.value : this.contentTier,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyllabusTemplate(')
          ..write('id: $id, ')
          ..write('templateVersion: $templateVersion, ')
          ..write('exportedAt: $exportedAt, ')
          ..write('sourceApp: $sourceApp, ')
          ..write('sourceAttribution: $sourceAttribution, ')
          ..write('importedAt: $importedAt, ')
          ..write('content: $content, ')
          ..write('contentTier: $contentTier')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    templateVersion,
    exportedAt,
    sourceApp,
    sourceAttribution,
    importedAt,
    content,
    contentTier,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyllabusTemplate &&
          other.id == this.id &&
          other.templateVersion == this.templateVersion &&
          other.exportedAt == this.exportedAt &&
          other.sourceApp == this.sourceApp &&
          other.sourceAttribution == this.sourceAttribution &&
          other.importedAt == this.importedAt &&
          other.content == this.content &&
          other.contentTier == this.contentTier);
}

class SyllabusTemplatesCompanion extends UpdateCompanion<SyllabusTemplate> {
  final Value<int> id;
  final Value<int> templateVersion;
  final Value<String> exportedAt;
  final Value<String?> sourceApp;
  final Value<String?> sourceAttribution;
  final Value<String?> importedAt;
  final Value<String> content;
  final Value<String> contentTier;
  const SyllabusTemplatesCompanion({
    this.id = const Value.absent(),
    this.templateVersion = const Value.absent(),
    this.exportedAt = const Value.absent(),
    this.sourceApp = const Value.absent(),
    this.sourceAttribution = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.content = const Value.absent(),
    this.contentTier = const Value.absent(),
  });
  SyllabusTemplatesCompanion.insert({
    this.id = const Value.absent(),
    this.templateVersion = const Value.absent(),
    required String exportedAt,
    this.sourceApp = const Value.absent(),
    this.sourceAttribution = const Value.absent(),
    this.importedAt = const Value.absent(),
    required String content,
    this.contentTier = const Value.absent(),
  }) : exportedAt = Value(exportedAt),
       content = Value(content);
  static Insertable<SyllabusTemplate> custom({
    Expression<int>? id,
    Expression<int>? templateVersion,
    Expression<String>? exportedAt,
    Expression<String>? sourceApp,
    Expression<String>? sourceAttribution,
    Expression<String>? importedAt,
    Expression<String>? content,
    Expression<String>? contentTier,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateVersion != null) 'template_version': templateVersion,
      if (exportedAt != null) 'exported_at': exportedAt,
      if (sourceApp != null) 'source_app': sourceApp,
      if (sourceAttribution != null) 'source_attribution': sourceAttribution,
      if (importedAt != null) 'imported_at': importedAt,
      if (content != null) 'content': content,
      if (contentTier != null) 'content_tier': contentTier,
    });
  }

  SyllabusTemplatesCompanion copyWith({
    Value<int>? id,
    Value<int>? templateVersion,
    Value<String>? exportedAt,
    Value<String?>? sourceApp,
    Value<String?>? sourceAttribution,
    Value<String?>? importedAt,
    Value<String>? content,
    Value<String>? contentTier,
  }) {
    return SyllabusTemplatesCompanion(
      id: id ?? this.id,
      templateVersion: templateVersion ?? this.templateVersion,
      exportedAt: exportedAt ?? this.exportedAt,
      sourceApp: sourceApp ?? this.sourceApp,
      sourceAttribution: sourceAttribution ?? this.sourceAttribution,
      importedAt: importedAt ?? this.importedAt,
      content: content ?? this.content,
      contentTier: contentTier ?? this.contentTier,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (templateVersion.present) {
      map['template_version'] = Variable<int>(templateVersion.value);
    }
    if (exportedAt.present) {
      map['exported_at'] = Variable<String>(exportedAt.value);
    }
    if (sourceApp.present) {
      map['source_app'] = Variable<String>(sourceApp.value);
    }
    if (sourceAttribution.present) {
      map['source_attribution'] = Variable<String>(sourceAttribution.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<String>(importedAt.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (contentTier.present) {
      map['content_tier'] = Variable<String>(contentTier.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyllabusTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('templateVersion: $templateVersion, ')
          ..write('exportedAt: $exportedAt, ')
          ..write('sourceApp: $sourceApp, ')
          ..write('sourceAttribution: $sourceAttribution, ')
          ..write('importedAt: $importedAt, ')
          ..write('content: $content, ')
          ..write('contentTier: $contentTier')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaTable extends SyncMeta
    with TableInfo<$SyncMetaTable, SyncMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<String> lastSyncedAt = GeneratedColumn<String>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteVersionMeta = const VerificationMeta(
    'remoteVersion',
  );
  @override
  late final GeneratedColumn<String> remoteVersion = GeneratedColumn<String>(
    'remote_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conflictDataMeta = const VerificationMeta(
    'conflictData',
  );
  @override
  late final GeneratedColumn<String> conflictData = GeneratedColumn<String>(
    'conflict_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entity,
    localId,
    syncStatus,
    lastSyncedAt,
    remoteVersion,
    conflictData,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('remote_version')) {
      context.handle(
        _remoteVersionMeta,
        remoteVersion.isAcceptableOrUnknown(
          data['remote_version']!,
          _remoteVersionMeta,
        ),
      );
    }
    if (data.containsKey('conflict_data')) {
      context.handle(
        _conflictDataMeta,
        conflictData.isAcceptableOrUnknown(
          data['conflict_data']!,
          _conflictDataMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      entity:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entity'],
          )!,
      localId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}local_id'],
          )!,
      syncStatus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}sync_status'],
          )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_synced_at'],
      ),
      remoteVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_version'],
      ),
      conflictData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_data'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $SyncMetaTable createAlias(String alias) {
    return $SyncMetaTable(attachedDatabase, alias);
  }
}

class SyncMetaData extends DataClass implements Insertable<SyncMetaData> {
  final int id;
  final String entity;
  final String localId;
  final String syncStatus;
  final String? lastSyncedAt;
  final String? remoteVersion;
  final String? conflictData;
  final String createdAt;
  final String updatedAt;
  const SyncMetaData({
    required this.id,
    required this.entity,
    required this.localId,
    required this.syncStatus,
    this.lastSyncedAt,
    this.remoteVersion,
    this.conflictData,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity'] = Variable<String>(entity);
    map['local_id'] = Variable<String>(localId);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<String>(lastSyncedAt);
    }
    if (!nullToAbsent || remoteVersion != null) {
      map['remote_version'] = Variable<String>(remoteVersion);
    }
    if (!nullToAbsent || conflictData != null) {
      map['conflict_data'] = Variable<String>(conflictData);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  SyncMetaCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaCompanion(
      id: Value(id),
      entity: Value(entity),
      localId: Value(localId),
      syncStatus: Value(syncStatus),
      lastSyncedAt:
          lastSyncedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(lastSyncedAt),
      remoteVersion:
          remoteVersion == null && nullToAbsent
              ? const Value.absent()
              : Value(remoteVersion),
      conflictData:
          conflictData == null && nullToAbsent
              ? const Value.absent()
              : Value(conflictData),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaData(
      id: serializer.fromJson<int>(json['id']),
      entity: serializer.fromJson<String>(json['entity']),
      localId: serializer.fromJson<String>(json['localId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<String?>(json['lastSyncedAt']),
      remoteVersion: serializer.fromJson<String?>(json['remoteVersion']),
      conflictData: serializer.fromJson<String?>(json['conflictData']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entity': serializer.toJson<String>(entity),
      'localId': serializer.toJson<String>(localId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<String?>(lastSyncedAt),
      'remoteVersion': serializer.toJson<String?>(remoteVersion),
      'conflictData': serializer.toJson<String?>(conflictData),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  SyncMetaData copyWith({
    int? id,
    String? entity,
    String? localId,
    String? syncStatus,
    Value<String?> lastSyncedAt = const Value.absent(),
    Value<String?> remoteVersion = const Value.absent(),
    Value<String?> conflictData = const Value.absent(),
    String? createdAt,
    String? updatedAt,
  }) => SyncMetaData(
    id: id ?? this.id,
    entity: entity ?? this.entity,
    localId: localId ?? this.localId,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    remoteVersion:
        remoteVersion.present ? remoteVersion.value : this.remoteVersion,
    conflictData: conflictData.present ? conflictData.value : this.conflictData,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncMetaData copyWithCompanion(SyncMetaCompanion data) {
    return SyncMetaData(
      id: data.id.present ? data.id.value : this.id,
      entity: data.entity.present ? data.entity.value : this.entity,
      localId: data.localId.present ? data.localId.value : this.localId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastSyncedAt:
          data.lastSyncedAt.present
              ? data.lastSyncedAt.value
              : this.lastSyncedAt,
      remoteVersion:
          data.remoteVersion.present
              ? data.remoteVersion.value
              : this.remoteVersion,
      conflictData:
          data.conflictData.present
              ? data.conflictData.value
              : this.conflictData,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaData(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('localId: $localId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('remoteVersion: $remoteVersion, ')
          ..write('conflictData: $conflictData, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entity,
    localId,
    syncStatus,
    lastSyncedAt,
    remoteVersion,
    conflictData,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaData &&
          other.id == this.id &&
          other.entity == this.entity &&
          other.localId == this.localId &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.remoteVersion == this.remoteVersion &&
          other.conflictData == this.conflictData &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SyncMetaCompanion extends UpdateCompanion<SyncMetaData> {
  final Value<int> id;
  final Value<String> entity;
  final Value<String> localId;
  final Value<String> syncStatus;
  final Value<String?> lastSyncedAt;
  final Value<String?> remoteVersion;
  final Value<String?> conflictData;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const SyncMetaCompanion({
    this.id = const Value.absent(),
    this.entity = const Value.absent(),
    this.localId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.remoteVersion = const Value.absent(),
    this.conflictData = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SyncMetaCompanion.insert({
    this.id = const Value.absent(),
    required String entity,
    required String localId,
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.remoteVersion = const Value.absent(),
    this.conflictData = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  }) : entity = Value(entity),
       localId = Value(localId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SyncMetaData> custom({
    Expression<int>? id,
    Expression<String>? entity,
    Expression<String>? localId,
    Expression<String>? syncStatus,
    Expression<String>? lastSyncedAt,
    Expression<String>? remoteVersion,
    Expression<String>? conflictData,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entity != null) 'entity': entity,
      if (localId != null) 'local_id': localId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (remoteVersion != null) 'remote_version': remoteVersion,
      if (conflictData != null) 'conflict_data': conflictData,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SyncMetaCompanion copyWith({
    Value<int>? id,
    Value<String>? entity,
    Value<String>? localId,
    Value<String>? syncStatus,
    Value<String?>? lastSyncedAt,
    Value<String?>? remoteVersion,
    Value<String?>? conflictData,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return SyncMetaCompanion(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      localId: localId ?? this.localId,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      remoteVersion: remoteVersion ?? this.remoteVersion,
      conflictData: conflictData ?? this.conflictData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<String>(lastSyncedAt.value);
    }
    if (remoteVersion.present) {
      map['remote_version'] = Variable<String>(remoteVersion.value);
    }
    if (conflictData.present) {
      map['conflict_data'] = Variable<String>(conflictData.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaCompanion(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('localId: $localId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('remoteVersion: $remoteVersion, ')
          ..write('conflictData: $conflictData, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $ChaptersTable chapters = $ChaptersTable(this);
  late final $StudyTasksTable studyTasks = $StudyTasksTable(this);
  late final $FocusSessionsTable focusSessions = $FocusSessionsTable(this);
  late final $RevisionItemsTable revisionItems = $RevisionItemsTable(this);
  late final $ResourcesTable resources = $ResourcesTable(this);
  late final $PracticalRecordsTable practicalRecords = $PracticalRecordsTable(
    this,
  );
  late final $BackupRecordsTable backupRecords = $BackupRecordsTable(this);
  late final $SyllabusTemplatesTable syllabusTemplates =
      $SyllabusTemplatesTable(this);
  late final $SyncMetaTable syncMeta = $SyncMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    subjects,
    chapters,
    studyTasks,
    focusSessions,
    revisionItems,
    resources,
    practicalRecords,
    backupRecords,
    syllabusTemplates,
    syncMeta,
  ];
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      required String classLevel,
      required String board,
      required String examDate,
      Value<int> dailyStudyMinutes,
      Value<String> theme,
      required String createdAt,
      required String updatedAt,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String> classLevel,
      Value<String> board,
      Value<String> examDate,
      Value<int> dailyStudyMinutes,
      Value<String> theme,
      Value<String> createdAt,
      Value<String> updatedAt,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classLevel => $composableBuilder(
    column: $table.classLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get board => $composableBuilder(
    column: $table.board,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examDate => $composableBuilder(
    column: $table.examDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyStudyMinutes => $composableBuilder(
    column: $table.dailyStudyMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classLevel => $composableBuilder(
    column: $table.classLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get board => $composableBuilder(
    column: $table.board,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examDate => $composableBuilder(
    column: $table.examDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyStudyMinutes => $composableBuilder(
    column: $table.dailyStudyMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get classLevel => $composableBuilder(
    column: $table.classLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get board =>
      $composableBuilder(column: $table.board, builder: (column) => column);

  GeneratedColumn<String> get examDate =>
      $composableBuilder(column: $table.examDate, builder: (column) => column);

  GeneratedColumn<int> get dailyStudyMinutes => $composableBuilder(
    column: $table.dailyStudyMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> classLevel = const Value.absent(),
                Value<String> board = const Value.absent(),
                Value<String> examDate = const Value.absent(),
                Value<int> dailyStudyMinutes = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                classLevel: classLevel,
                board: board,
                examDate: examDate,
                dailyStudyMinutes: dailyStudyMinutes,
                theme: theme,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String classLevel,
                required String board,
                required String examDate,
                Value<int> dailyStudyMinutes = const Value.absent(),
                Value<String> theme = const Value.absent(),
                required String createdAt,
                required String updatedAt,
              }) => UserProfilesCompanion.insert(
                id: id,
                classLevel: classLevel,
                board: board,
                examDate: examDate,
                dailyStudyMinutes: dailyStudyMinutes,
                theme: theme,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$SubjectsTableCreateCompanionBuilder =
    SubjectsCompanion Function({
      Value<int> id,
      required String name,
      required int color,
      required int sortOrder,
      required String createdAt,
    });
typedef $$SubjectsTableUpdateCompanionBuilder =
    SubjectsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> color,
      Value<int> sortOrder,
      Value<String> createdAt,
    });

final class $$SubjectsTableReferences
    extends BaseReferences<_$AppDatabase, $SubjectsTable, Subject> {
  $$SubjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ChaptersTable, List<Chapter>> _chaptersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.chapters,
    aliasName: 'subjects__id__chapters__subject_id',
  );

  $$ChaptersTableProcessedTableManager get chaptersRefs {
    final manager = $$ChaptersTableTableManager(
      $_db,
      $_db.chapters,
    ).filter((f) => f.subjectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chaptersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StudyTasksTable, List<StudyTask>>
  _studyTasksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.studyTasks,
    aliasName: 'subjects__id__study_tasks__subject_id',
  );

  $$StudyTasksTableProcessedTableManager get studyTasksRefs {
    final manager = $$StudyTasksTableTableManager(
      $_db,
      $_db.studyTasks,
    ).filter((f) => f.subjectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_studyTasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ResourcesTable, List<Resource>>
  _resourcesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.resources,
    aliasName: 'subjects__id__resources__subject_id',
  );

  $$ResourcesTableProcessedTableManager get resourcesRefs {
    final manager = $$ResourcesTableTableManager(
      $_db,
      $_db.resources,
    ).filter((f) => f.subjectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_resourcesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PracticalRecordsTable, List<PracticalRecord>>
  _practicalRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.practicalRecords,
    aliasName: 'subjects__id__practical_records__subject_id',
  );

  $$PracticalRecordsTableProcessedTableManager get practicalRecordsRefs {
    final manager = $$PracticalRecordsTableTableManager(
      $_db,
      $_db.practicalRecords,
    ).filter((f) => f.subjectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _practicalRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> chaptersRefs(
    Expression<bool> Function($$ChaptersTableFilterComposer f) f,
  ) {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableFilterComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> studyTasksRefs(
    Expression<bool> Function($$StudyTasksTableFilterComposer f) f,
  ) {
    final $$StudyTasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyTasks,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyTasksTableFilterComposer(
            $db: $db,
            $table: $db.studyTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> resourcesRefs(
    Expression<bool> Function($$ResourcesTableFilterComposer f) f,
  ) {
    final $$ResourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resources,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesTableFilterComposer(
            $db: $db,
            $table: $db.resources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> practicalRecordsRefs(
    Expression<bool> Function($$PracticalRecordsTableFilterComposer f) f,
  ) {
    final $$PracticalRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.practicalRecords,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticalRecordsTableFilterComposer(
            $db: $db,
            $table: $db.practicalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> chaptersRefs<T extends Object>(
    Expression<T> Function($$ChaptersTableAnnotationComposer a) f,
  ) {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableAnnotationComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> studyTasksRefs<T extends Object>(
    Expression<T> Function($$StudyTasksTableAnnotationComposer a) f,
  ) {
    final $$StudyTasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyTasks,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyTasksTableAnnotationComposer(
            $db: $db,
            $table: $db.studyTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> resourcesRefs<T extends Object>(
    Expression<T> Function($$ResourcesTableAnnotationComposer a) f,
  ) {
    final $$ResourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resources,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.resources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> practicalRecordsRefs<T extends Object>(
    Expression<T> Function($$PracticalRecordsTableAnnotationComposer a) f,
  ) {
    final $$PracticalRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.practicalRecords,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticalRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.practicalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubjectsTable,
          Subject,
          $$SubjectsTableFilterComposer,
          $$SubjectsTableOrderingComposer,
          $$SubjectsTableAnnotationComposer,
          $$SubjectsTableCreateCompanionBuilder,
          $$SubjectsTableUpdateCompanionBuilder,
          (Subject, $$SubjectsTableReferences),
          Subject,
          PrefetchHooks Function({
            bool chaptersRefs,
            bool studyTasksRefs,
            bool resourcesRefs,
            bool practicalRecordsRefs,
          })
        > {
  $$SubjectsTableTableManager(_$AppDatabase db, $SubjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => SubjectsCompanion(
                id: id,
                name: name,
                color: color,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int color,
                required int sortOrder,
                required String createdAt,
              }) => SubjectsCompanion.insert(
                id: id,
                name: name,
                color: color,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$SubjectsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            chaptersRefs = false,
            studyTasksRefs = false,
            resourcesRefs = false,
            practicalRecordsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (chaptersRefs) db.chapters,
                if (studyTasksRefs) db.studyTasks,
                if (resourcesRefs) db.resources,
                if (practicalRecordsRefs) db.practicalRecords,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (chaptersRefs)
                    await $_getPrefetchedData<Subject, $SubjectsTable, Chapter>(
                      currentTable: table,
                      referencedTable: $$SubjectsTableReferences
                          ._chaptersRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$SubjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).chaptersRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.subjectId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (studyTasksRefs)
                    await $_getPrefetchedData<
                      Subject,
                      $SubjectsTable,
                      StudyTask
                    >(
                      currentTable: table,
                      referencedTable: $$SubjectsTableReferences
                          ._studyTasksRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$SubjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).studyTasksRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.subjectId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (resourcesRefs)
                    await $_getPrefetchedData<
                      Subject,
                      $SubjectsTable,
                      Resource
                    >(
                      currentTable: table,
                      referencedTable: $$SubjectsTableReferences
                          ._resourcesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$SubjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).resourcesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.subjectId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (practicalRecordsRefs)
                    await $_getPrefetchedData<
                      Subject,
                      $SubjectsTable,
                      PracticalRecord
                    >(
                      currentTable: table,
                      referencedTable: $$SubjectsTableReferences
                          ._practicalRecordsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$SubjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).practicalRecordsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.subjectId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubjectsTable,
      Subject,
      $$SubjectsTableFilterComposer,
      $$SubjectsTableOrderingComposer,
      $$SubjectsTableAnnotationComposer,
      $$SubjectsTableCreateCompanionBuilder,
      $$SubjectsTableUpdateCompanionBuilder,
      (Subject, $$SubjectsTableReferences),
      Subject,
      PrefetchHooks Function({
        bool chaptersRefs,
        bool studyTasksRefs,
        bool resourcesRefs,
        bool practicalRecordsRefs,
      })
    >;
typedef $$ChaptersTableCreateCompanionBuilder =
    ChaptersCompanion Function({
      Value<int> id,
      required int subjectId,
      required String title,
      Value<String> status,
      Value<int> priority,
      Value<int> estimatedMinutes,
      Value<String> revisionDates,
      Value<int?> completedAt,
      required String createdAt,
      Value<int?> examWeight,
      Value<int?> confidence,
      Value<String?> contentSource,
      Value<String?> contentVersion,
      Value<String?> reviewDate,
      Value<int> isWeakTopic,
      Value<String> contentTier,
    });
typedef $$ChaptersTableUpdateCompanionBuilder =
    ChaptersCompanion Function({
      Value<int> id,
      Value<int> subjectId,
      Value<String> title,
      Value<String> status,
      Value<int> priority,
      Value<int> estimatedMinutes,
      Value<String> revisionDates,
      Value<int?> completedAt,
      Value<String> createdAt,
      Value<int?> examWeight,
      Value<int?> confidence,
      Value<String?> contentSource,
      Value<String?> contentVersion,
      Value<String?> reviewDate,
      Value<int> isWeakTopic,
      Value<String> contentTier,
    });

final class $$ChaptersTableReferences
    extends BaseReferences<_$AppDatabase, $ChaptersTable, Chapter> {
  $$ChaptersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SubjectsTable _subjectIdTable(_$AppDatabase db) =>
      db.subjects.createAlias('chapters__subject_id__subjects__id');

  $$SubjectsTableProcessedTableManager get subjectId {
    final $_column = $_itemColumn<int>('subject_id')!;

    final manager = $$SubjectsTableTableManager(
      $_db,
      $_db.subjects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StudyTasksTable, List<StudyTask>>
  _studyTasksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.studyTasks,
    aliasName: 'chapters__id__study_tasks__chapter_id',
  );

  $$StudyTasksTableProcessedTableManager get studyTasksRefs {
    final manager = $$StudyTasksTableTableManager(
      $_db,
      $_db.studyTasks,
    ).filter((f) => f.chapterId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_studyTasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RevisionItemsTable, List<RevisionItem>>
  _revisionItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.revisionItems,
    aliasName: 'chapters__id__revision_items__chapter_id',
  );

  $$RevisionItemsTableProcessedTableManager get revisionItemsRefs {
    final manager = $$RevisionItemsTableTableManager(
      $_db,
      $_db.revisionItems,
    ).filter((f) => f.chapterId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_revisionItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ResourcesTable, List<Resource>>
  _resourcesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.resources,
    aliasName: 'chapters__id__resources__chapter_id',
  );

  $$ResourcesTableProcessedTableManager get resourcesRefs {
    final manager = $$ResourcesTableTableManager(
      $_db,
      $_db.resources,
    ).filter((f) => f.chapterId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_resourcesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revisionDates => $composableBuilder(
    column: $table.revisionDates,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get examWeight => $composableBuilder(
    column: $table.examWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentSource => $composableBuilder(
    column: $table.contentSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewDate => $composableBuilder(
    column: $table.reviewDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isWeakTopic => $composableBuilder(
    column: $table.isWeakTopic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentTier => $composableBuilder(
    column: $table.contentTier,
    builder: (column) => ColumnFilters(column),
  );

  $$SubjectsTableFilterComposer get subjectId {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableFilterComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> studyTasksRefs(
    Expression<bool> Function($$StudyTasksTableFilterComposer f) f,
  ) {
    final $$StudyTasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyTasks,
      getReferencedColumn: (t) => t.chapterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyTasksTableFilterComposer(
            $db: $db,
            $table: $db.studyTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> revisionItemsRefs(
    Expression<bool> Function($$RevisionItemsTableFilterComposer f) f,
  ) {
    final $$RevisionItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.revisionItems,
      getReferencedColumn: (t) => t.chapterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RevisionItemsTableFilterComposer(
            $db: $db,
            $table: $db.revisionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> resourcesRefs(
    Expression<bool> Function($$ResourcesTableFilterComposer f) f,
  ) {
    final $$ResourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resources,
      getReferencedColumn: (t) => t.chapterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesTableFilterComposer(
            $db: $db,
            $table: $db.resources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revisionDates => $composableBuilder(
    column: $table.revisionDates,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get examWeight => $composableBuilder(
    column: $table.examWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentSource => $composableBuilder(
    column: $table.contentSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewDate => $composableBuilder(
    column: $table.reviewDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isWeakTopic => $composableBuilder(
    column: $table.isWeakTopic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentTier => $composableBuilder(
    column: $table.contentTier,
    builder: (column) => ColumnOrderings(column),
  );

  $$SubjectsTableOrderingComposer get subjectId {
    final $$SubjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableOrderingComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get revisionDates => $composableBuilder(
    column: $table.revisionDates,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get examWeight => $composableBuilder(
    column: $table.examWeight,
    builder: (column) => column,
  );

  GeneratedColumn<int> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentSource => $composableBuilder(
    column: $table.contentSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewDate => $composableBuilder(
    column: $table.reviewDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isWeakTopic => $composableBuilder(
    column: $table.isWeakTopic,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentTier => $composableBuilder(
    column: $table.contentTier,
    builder: (column) => column,
  );

  $$SubjectsTableAnnotationComposer get subjectId {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> studyTasksRefs<T extends Object>(
    Expression<T> Function($$StudyTasksTableAnnotationComposer a) f,
  ) {
    final $$StudyTasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyTasks,
      getReferencedColumn: (t) => t.chapterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyTasksTableAnnotationComposer(
            $db: $db,
            $table: $db.studyTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> revisionItemsRefs<T extends Object>(
    Expression<T> Function($$RevisionItemsTableAnnotationComposer a) f,
  ) {
    final $$RevisionItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.revisionItems,
      getReferencedColumn: (t) => t.chapterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RevisionItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.revisionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> resourcesRefs<T extends Object>(
    Expression<T> Function($$ResourcesTableAnnotationComposer a) f,
  ) {
    final $$ResourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resources,
      getReferencedColumn: (t) => t.chapterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.resources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChaptersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChaptersTable,
          Chapter,
          $$ChaptersTableFilterComposer,
          $$ChaptersTableOrderingComposer,
          $$ChaptersTableAnnotationComposer,
          $$ChaptersTableCreateCompanionBuilder,
          $$ChaptersTableUpdateCompanionBuilder,
          (Chapter, $$ChaptersTableReferences),
          Chapter,
          PrefetchHooks Function({
            bool subjectId,
            bool studyTasksRefs,
            bool revisionItemsRefs,
            bool resourcesRefs,
          })
        > {
  $$ChaptersTableTableManager(_$AppDatabase db, $ChaptersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> subjectId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> estimatedMinutes = const Value.absent(),
                Value<String> revisionDates = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int?> examWeight = const Value.absent(),
                Value<int?> confidence = const Value.absent(),
                Value<String?> contentSource = const Value.absent(),
                Value<String?> contentVersion = const Value.absent(),
                Value<String?> reviewDate = const Value.absent(),
                Value<int> isWeakTopic = const Value.absent(),
                Value<String> contentTier = const Value.absent(),
              }) => ChaptersCompanion(
                id: id,
                subjectId: subjectId,
                title: title,
                status: status,
                priority: priority,
                estimatedMinutes: estimatedMinutes,
                revisionDates: revisionDates,
                completedAt: completedAt,
                createdAt: createdAt,
                examWeight: examWeight,
                confidence: confidence,
                contentSource: contentSource,
                contentVersion: contentVersion,
                reviewDate: reviewDate,
                isWeakTopic: isWeakTopic,
                contentTier: contentTier,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int subjectId,
                required String title,
                Value<String> status = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> estimatedMinutes = const Value.absent(),
                Value<String> revisionDates = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                required String createdAt,
                Value<int?> examWeight = const Value.absent(),
                Value<int?> confidence = const Value.absent(),
                Value<String?> contentSource = const Value.absent(),
                Value<String?> contentVersion = const Value.absent(),
                Value<String?> reviewDate = const Value.absent(),
                Value<int> isWeakTopic = const Value.absent(),
                Value<String> contentTier = const Value.absent(),
              }) => ChaptersCompanion.insert(
                id: id,
                subjectId: subjectId,
                title: title,
                status: status,
                priority: priority,
                estimatedMinutes: estimatedMinutes,
                revisionDates: revisionDates,
                completedAt: completedAt,
                createdAt: createdAt,
                examWeight: examWeight,
                confidence: confidence,
                contentSource: contentSource,
                contentVersion: contentVersion,
                reviewDate: reviewDate,
                isWeakTopic: isWeakTopic,
                contentTier: contentTier,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ChaptersTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            subjectId = false,
            studyTasksRefs = false,
            revisionItemsRefs = false,
            resourcesRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (studyTasksRefs) db.studyTasks,
                if (revisionItemsRefs) db.revisionItems,
                if (resourcesRefs) db.resources,
              ],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (subjectId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.subjectId,
                            referencedTable: $$ChaptersTableReferences
                                ._subjectIdTable(db),
                            referencedColumn:
                                $$ChaptersTableReferences
                                    ._subjectIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (studyTasksRefs)
                    await $_getPrefetchedData<
                      Chapter,
                      $ChaptersTable,
                      StudyTask
                    >(
                      currentTable: table,
                      referencedTable: $$ChaptersTableReferences
                          ._studyTasksRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ChaptersTableReferences(
                                db,
                                table,
                                p0,
                              ).studyTasksRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.chapterId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (revisionItemsRefs)
                    await $_getPrefetchedData<
                      Chapter,
                      $ChaptersTable,
                      RevisionItem
                    >(
                      currentTable: table,
                      referencedTable: $$ChaptersTableReferences
                          ._revisionItemsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ChaptersTableReferences(
                                db,
                                table,
                                p0,
                              ).revisionItemsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.chapterId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (resourcesRefs)
                    await $_getPrefetchedData<
                      Chapter,
                      $ChaptersTable,
                      Resource
                    >(
                      currentTable: table,
                      referencedTable: $$ChaptersTableReferences
                          ._resourcesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ChaptersTableReferences(
                                db,
                                table,
                                p0,
                              ).resourcesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.chapterId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChaptersTable,
      Chapter,
      $$ChaptersTableFilterComposer,
      $$ChaptersTableOrderingComposer,
      $$ChaptersTableAnnotationComposer,
      $$ChaptersTableCreateCompanionBuilder,
      $$ChaptersTableUpdateCompanionBuilder,
      (Chapter, $$ChaptersTableReferences),
      Chapter,
      PrefetchHooks Function({
        bool subjectId,
        bool studyTasksRefs,
        bool revisionItemsRefs,
        bool resourcesRefs,
      })
    >;
typedef $$StudyTasksTableCreateCompanionBuilder =
    StudyTasksCompanion Function({
      Value<int> id,
      required int subjectId,
      Value<int?> chapterId,
      required String title,
      Value<String> type,
      Value<String?> dueAt,
      required String scheduledAt,
      required int estimatedMinutes,
      Value<int> completedMinutes,
      Value<int> priority,
      required String status,
      Value<int> isRescheduled,
      Value<int> isPastPaper,
      Value<int> isTemplate,
      required String createdAt,
      required String updatedAt,
      Value<int?> originalEstimatedMinutes,
    });
typedef $$StudyTasksTableUpdateCompanionBuilder =
    StudyTasksCompanion Function({
      Value<int> id,
      Value<int> subjectId,
      Value<int?> chapterId,
      Value<String> title,
      Value<String> type,
      Value<String?> dueAt,
      Value<String> scheduledAt,
      Value<int> estimatedMinutes,
      Value<int> completedMinutes,
      Value<int> priority,
      Value<String> status,
      Value<int> isRescheduled,
      Value<int> isPastPaper,
      Value<int> isTemplate,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<int?> originalEstimatedMinutes,
    });

final class $$StudyTasksTableReferences
    extends BaseReferences<_$AppDatabase, $StudyTasksTable, StudyTask> {
  $$StudyTasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SubjectsTable _subjectIdTable(_$AppDatabase db) =>
      db.subjects.createAlias('study_tasks__subject_id__subjects__id');

  $$SubjectsTableProcessedTableManager get subjectId {
    final $_column = $_itemColumn<int>('subject_id')!;

    final manager = $$SubjectsTableTableManager(
      $_db,
      $_db.subjects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) =>
      db.chapters.createAlias('study_tasks__chapter_id__chapters__id');

  $$ChaptersTableProcessedTableManager? get chapterId {
    final $_column = $_itemColumn<int>('chapter_id');
    if ($_column == null) return null;
    final manager = $$ChaptersTableTableManager(
      $_db,
      $_db.chapters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$FocusSessionsTable, List<FocusSession>>
  _focusSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.focusSessions,
    aliasName: 'study_tasks__id__focus_sessions__task_id',
  );

  $$FocusSessionsTableProcessedTableManager get focusSessionsRefs {
    final manager = $$FocusSessionsTableTableManager(
      $_db,
      $_db.focusSessions,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_focusSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StudyTasksTableFilterComposer
    extends Composer<_$AppDatabase, $StudyTasksTable> {
  $$StudyTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedMinutes => $composableBuilder(
    column: $table.completedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isRescheduled => $composableBuilder(
    column: $table.isRescheduled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isPastPaper => $composableBuilder(
    column: $table.isPastPaper,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isTemplate => $composableBuilder(
    column: $table.isTemplate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalEstimatedMinutes => $composableBuilder(
    column: $table.originalEstimatedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  $$SubjectsTableFilterComposer get subjectId {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableFilterComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableFilterComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> focusSessionsRefs(
    Expression<bool> Function($$FocusSessionsTableFilterComposer f) f,
  ) {
    final $$FocusSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableFilterComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudyTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $StudyTasksTable> {
  $$StudyTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedMinutes => $composableBuilder(
    column: $table.completedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isRescheduled => $composableBuilder(
    column: $table.isRescheduled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isPastPaper => $composableBuilder(
    column: $table.isPastPaper,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isTemplate => $composableBuilder(
    column: $table.isTemplate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalEstimatedMinutes => $composableBuilder(
    column: $table.originalEstimatedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  $$SubjectsTableOrderingComposer get subjectId {
    final $$SubjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableOrderingComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableOrderingComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudyTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudyTasksTable> {
  $$StudyTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<String> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedMinutes => $composableBuilder(
    column: $table.completedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get isRescheduled => $composableBuilder(
    column: $table.isRescheduled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isPastPaper => $composableBuilder(
    column: $table.isPastPaper,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isTemplate => $composableBuilder(
    column: $table.isTemplate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get originalEstimatedMinutes => $composableBuilder(
    column: $table.originalEstimatedMinutes,
    builder: (column) => column,
  );

  $$SubjectsTableAnnotationComposer get subjectId {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableAnnotationComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> focusSessionsRefs<T extends Object>(
    Expression<T> Function($$FocusSessionsTableAnnotationComposer a) f,
  ) {
    final $$FocusSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudyTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudyTasksTable,
          StudyTask,
          $$StudyTasksTableFilterComposer,
          $$StudyTasksTableOrderingComposer,
          $$StudyTasksTableAnnotationComposer,
          $$StudyTasksTableCreateCompanionBuilder,
          $$StudyTasksTableUpdateCompanionBuilder,
          (StudyTask, $$StudyTasksTableReferences),
          StudyTask,
          PrefetchHooks Function({
            bool subjectId,
            bool chapterId,
            bool focusSessionsRefs,
          })
        > {
  $$StudyTasksTableTableManager(_$AppDatabase db, $StudyTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$StudyTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$StudyTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$StudyTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> subjectId = const Value.absent(),
                Value<int?> chapterId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> dueAt = const Value.absent(),
                Value<String> scheduledAt = const Value.absent(),
                Value<int> estimatedMinutes = const Value.absent(),
                Value<int> completedMinutes = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> isRescheduled = const Value.absent(),
                Value<int> isPastPaper = const Value.absent(),
                Value<int> isTemplate = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int?> originalEstimatedMinutes = const Value.absent(),
              }) => StudyTasksCompanion(
                id: id,
                subjectId: subjectId,
                chapterId: chapterId,
                title: title,
                type: type,
                dueAt: dueAt,
                scheduledAt: scheduledAt,
                estimatedMinutes: estimatedMinutes,
                completedMinutes: completedMinutes,
                priority: priority,
                status: status,
                isRescheduled: isRescheduled,
                isPastPaper: isPastPaper,
                isTemplate: isTemplate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                originalEstimatedMinutes: originalEstimatedMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int subjectId,
                Value<int?> chapterId = const Value.absent(),
                required String title,
                Value<String> type = const Value.absent(),
                Value<String?> dueAt = const Value.absent(),
                required String scheduledAt,
                required int estimatedMinutes,
                Value<int> completedMinutes = const Value.absent(),
                Value<int> priority = const Value.absent(),
                required String status,
                Value<int> isRescheduled = const Value.absent(),
                Value<int> isPastPaper = const Value.absent(),
                Value<int> isTemplate = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<int?> originalEstimatedMinutes = const Value.absent(),
              }) => StudyTasksCompanion.insert(
                id: id,
                subjectId: subjectId,
                chapterId: chapterId,
                title: title,
                type: type,
                dueAt: dueAt,
                scheduledAt: scheduledAt,
                estimatedMinutes: estimatedMinutes,
                completedMinutes: completedMinutes,
                priority: priority,
                status: status,
                isRescheduled: isRescheduled,
                isPastPaper: isPastPaper,
                isTemplate: isTemplate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                originalEstimatedMinutes: originalEstimatedMinutes,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$StudyTasksTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            subjectId = false,
            chapterId = false,
            focusSessionsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (focusSessionsRefs) db.focusSessions,
              ],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (subjectId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.subjectId,
                            referencedTable: $$StudyTasksTableReferences
                                ._subjectIdTable(db),
                            referencedColumn:
                                $$StudyTasksTableReferences
                                    ._subjectIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (chapterId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.chapterId,
                            referencedTable: $$StudyTasksTableReferences
                                ._chapterIdTable(db),
                            referencedColumn:
                                $$StudyTasksTableReferences
                                    ._chapterIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (focusSessionsRefs)
                    await $_getPrefetchedData<
                      StudyTask,
                      $StudyTasksTable,
                      FocusSession
                    >(
                      currentTable: table,
                      referencedTable: $$StudyTasksTableReferences
                          ._focusSessionsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$StudyTasksTableReferences(
                                db,
                                table,
                                p0,
                              ).focusSessionsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.taskId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StudyTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudyTasksTable,
      StudyTask,
      $$StudyTasksTableFilterComposer,
      $$StudyTasksTableOrderingComposer,
      $$StudyTasksTableAnnotationComposer,
      $$StudyTasksTableCreateCompanionBuilder,
      $$StudyTasksTableUpdateCompanionBuilder,
      (StudyTask, $$StudyTasksTableReferences),
      StudyTask,
      PrefetchHooks Function({
        bool subjectId,
        bool chapterId,
        bool focusSessionsRefs,
      })
    >;
typedef $$FocusSessionsTableCreateCompanionBuilder =
    FocusSessionsCompanion Function({
      Value<int> id,
      Value<int?> taskId,
      required String startedAt,
      Value<String?> endedAt,
      Value<int> plannedMinutes,
      Value<int> completedMinutes,
      required String status,
      required String createdAt,
      Value<String?> notes,
      Value<String?> reflectionStatus,
      Value<String?> parkingLotNotes,
    });
typedef $$FocusSessionsTableUpdateCompanionBuilder =
    FocusSessionsCompanion Function({
      Value<int> id,
      Value<int?> taskId,
      Value<String> startedAt,
      Value<String?> endedAt,
      Value<int> plannedMinutes,
      Value<int> completedMinutes,
      Value<String> status,
      Value<String> createdAt,
      Value<String?> notes,
      Value<String?> reflectionStatus,
      Value<String?> parkingLotNotes,
    });

final class $$FocusSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $FocusSessionsTable, FocusSession> {
  $$FocusSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StudyTasksTable _taskIdTable(_$AppDatabase db) =>
      db.studyTasks.createAlias('focus_sessions__task_id__study_tasks__id');

  $$StudyTasksTableProcessedTableManager? get taskId {
    final $_column = $_itemColumn<int>('task_id');
    if ($_column == null) return null;
    final manager = $$StudyTasksTableTableManager(
      $_db,
      $_db.studyTasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FocusSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedMinutes => $composableBuilder(
    column: $table.plannedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedMinutes => $composableBuilder(
    column: $table.completedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reflectionStatus => $composableBuilder(
    column: $table.reflectionStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parkingLotNotes => $composableBuilder(
    column: $table.parkingLotNotes,
    builder: (column) => ColumnFilters(column),
  );

  $$StudyTasksTableFilterComposer get taskId {
    final $$StudyTasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.studyTasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyTasksTableFilterComposer(
            $db: $db,
            $table: $db.studyTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedMinutes => $composableBuilder(
    column: $table.plannedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedMinutes => $composableBuilder(
    column: $table.completedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reflectionStatus => $composableBuilder(
    column: $table.reflectionStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parkingLotNotes => $composableBuilder(
    column: $table.parkingLotNotes,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudyTasksTableOrderingComposer get taskId {
    final $$StudyTasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.studyTasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyTasksTableOrderingComposer(
            $db: $db,
            $table: $db.studyTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get plannedMinutes => $composableBuilder(
    column: $table.plannedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedMinutes => $composableBuilder(
    column: $table.completedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get reflectionStatus => $composableBuilder(
    column: $table.reflectionStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parkingLotNotes => $composableBuilder(
    column: $table.parkingLotNotes,
    builder: (column) => column,
  );

  $$StudyTasksTableAnnotationComposer get taskId {
    final $$StudyTasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.studyTasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyTasksTableAnnotationComposer(
            $db: $db,
            $table: $db.studyTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FocusSessionsTable,
          FocusSession,
          $$FocusSessionsTableFilterComposer,
          $$FocusSessionsTableOrderingComposer,
          $$FocusSessionsTableAnnotationComposer,
          $$FocusSessionsTableCreateCompanionBuilder,
          $$FocusSessionsTableUpdateCompanionBuilder,
          (FocusSession, $$FocusSessionsTableReferences),
          FocusSession,
          PrefetchHooks Function({bool taskId})
        > {
  $$FocusSessionsTableTableManager(_$AppDatabase db, $FocusSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$FocusSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$FocusSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$FocusSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> taskId = const Value.absent(),
                Value<String> startedAt = const Value.absent(),
                Value<String?> endedAt = const Value.absent(),
                Value<int> plannedMinutes = const Value.absent(),
                Value<int> completedMinutes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> reflectionStatus = const Value.absent(),
                Value<String?> parkingLotNotes = const Value.absent(),
              }) => FocusSessionsCompanion(
                id: id,
                taskId: taskId,
                startedAt: startedAt,
                endedAt: endedAt,
                plannedMinutes: plannedMinutes,
                completedMinutes: completedMinutes,
                status: status,
                createdAt: createdAt,
                notes: notes,
                reflectionStatus: reflectionStatus,
                parkingLotNotes: parkingLotNotes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> taskId = const Value.absent(),
                required String startedAt,
                Value<String?> endedAt = const Value.absent(),
                Value<int> plannedMinutes = const Value.absent(),
                Value<int> completedMinutes = const Value.absent(),
                required String status,
                required String createdAt,
                Value<String?> notes = const Value.absent(),
                Value<String?> reflectionStatus = const Value.absent(),
                Value<String?> parkingLotNotes = const Value.absent(),
              }) => FocusSessionsCompanion.insert(
                id: id,
                taskId: taskId,
                startedAt: startedAt,
                endedAt: endedAt,
                plannedMinutes: plannedMinutes,
                completedMinutes: completedMinutes,
                status: status,
                createdAt: createdAt,
                notes: notes,
                reflectionStatus: reflectionStatus,
                parkingLotNotes: parkingLotNotes,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$FocusSessionsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (taskId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.taskId,
                            referencedTable: $$FocusSessionsTableReferences
                                ._taskIdTable(db),
                            referencedColumn:
                                $$FocusSessionsTableReferences
                                    ._taskIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FocusSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FocusSessionsTable,
      FocusSession,
      $$FocusSessionsTableFilterComposer,
      $$FocusSessionsTableOrderingComposer,
      $$FocusSessionsTableAnnotationComposer,
      $$FocusSessionsTableCreateCompanionBuilder,
      $$FocusSessionsTableUpdateCompanionBuilder,
      (FocusSession, $$FocusSessionsTableReferences),
      FocusSession,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$RevisionItemsTableCreateCompanionBuilder =
    RevisionItemsCompanion Function({
      Value<int> id,
      required int chapterId,
      required String dueAt,
      required int intervalDays,
      Value<String> status,
      Value<int?> completedAt,
      required String createdAt,
      Value<int> recallConfidence,
      Value<double> easeFactor,
      Value<int> repetitions,
      Value<String?> lastReviewAt,
    });
typedef $$RevisionItemsTableUpdateCompanionBuilder =
    RevisionItemsCompanion Function({
      Value<int> id,
      Value<int> chapterId,
      Value<String> dueAt,
      Value<int> intervalDays,
      Value<String> status,
      Value<int?> completedAt,
      Value<String> createdAt,
      Value<int> recallConfidence,
      Value<double> easeFactor,
      Value<int> repetitions,
      Value<String?> lastReviewAt,
    });

final class $$RevisionItemsTableReferences
    extends BaseReferences<_$AppDatabase, $RevisionItemsTable, RevisionItem> {
  $$RevisionItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) =>
      db.chapters.createAlias('revision_items__chapter_id__chapters__id');

  $$ChaptersTableProcessedTableManager get chapterId {
    final $_column = $_itemColumn<int>('chapter_id')!;

    final manager = $$ChaptersTableTableManager(
      $_db,
      $_db.chapters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RevisionItemsTableFilterComposer
    extends Composer<_$AppDatabase, $RevisionItemsTable> {
  $$RevisionItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recallConfidence => $composableBuilder(
    column: $table.recallConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastReviewAt => $composableBuilder(
    column: $table.lastReviewAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableFilterComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RevisionItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $RevisionItemsTable> {
  $$RevisionItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recallConfidence => $composableBuilder(
    column: $table.recallConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastReviewAt => $composableBuilder(
    column: $table.lastReviewAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableOrderingComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RevisionItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RevisionItemsTable> {
  $$RevisionItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get recallConfidence => $composableBuilder(
    column: $table.recallConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastReviewAt => $composableBuilder(
    column: $table.lastReviewAt,
    builder: (column) => column,
  );

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableAnnotationComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RevisionItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RevisionItemsTable,
          RevisionItem,
          $$RevisionItemsTableFilterComposer,
          $$RevisionItemsTableOrderingComposer,
          $$RevisionItemsTableAnnotationComposer,
          $$RevisionItemsTableCreateCompanionBuilder,
          $$RevisionItemsTableUpdateCompanionBuilder,
          (RevisionItem, $$RevisionItemsTableReferences),
          RevisionItem,
          PrefetchHooks Function({bool chapterId})
        > {
  $$RevisionItemsTableTableManager(_$AppDatabase db, $RevisionItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$RevisionItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$RevisionItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$RevisionItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> chapterId = const Value.absent(),
                Value<String> dueAt = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> recallConfidence = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<String?> lastReviewAt = const Value.absent(),
              }) => RevisionItemsCompanion(
                id: id,
                chapterId: chapterId,
                dueAt: dueAt,
                intervalDays: intervalDays,
                status: status,
                completedAt: completedAt,
                createdAt: createdAt,
                recallConfidence: recallConfidence,
                easeFactor: easeFactor,
                repetitions: repetitions,
                lastReviewAt: lastReviewAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int chapterId,
                required String dueAt,
                required int intervalDays,
                Value<String> status = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                required String createdAt,
                Value<int> recallConfidence = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<String?> lastReviewAt = const Value.absent(),
              }) => RevisionItemsCompanion.insert(
                id: id,
                chapterId: chapterId,
                dueAt: dueAt,
                intervalDays: intervalDays,
                status: status,
                completedAt: completedAt,
                createdAt: createdAt,
                recallConfidence: recallConfidence,
                easeFactor: easeFactor,
                repetitions: repetitions,
                lastReviewAt: lastReviewAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$RevisionItemsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({chapterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (chapterId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.chapterId,
                            referencedTable: $$RevisionItemsTableReferences
                                ._chapterIdTable(db),
                            referencedColumn:
                                $$RevisionItemsTableReferences
                                    ._chapterIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RevisionItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RevisionItemsTable,
      RevisionItem,
      $$RevisionItemsTableFilterComposer,
      $$RevisionItemsTableOrderingComposer,
      $$RevisionItemsTableAnnotationComposer,
      $$RevisionItemsTableCreateCompanionBuilder,
      $$RevisionItemsTableUpdateCompanionBuilder,
      (RevisionItem, $$RevisionItemsTableReferences),
      RevisionItem,
      PrefetchHooks Function({bool chapterId})
    >;
typedef $$ResourcesTableCreateCompanionBuilder =
    ResourcesCompanion Function({
      Value<int> id,
      required int subjectId,
      Value<int?> chapterId,
      required String type,
      required String title,
      required String localPath,
      required String createdAt,
      Value<int?> fileSize,
      Value<int> isPinned,
      Value<String?> tags,
      Value<String?> folder,
      Value<int?> taskId,
      Value<int?> practicalId,
    });
typedef $$ResourcesTableUpdateCompanionBuilder =
    ResourcesCompanion Function({
      Value<int> id,
      Value<int> subjectId,
      Value<int?> chapterId,
      Value<String> type,
      Value<String> title,
      Value<String> localPath,
      Value<String> createdAt,
      Value<int?> fileSize,
      Value<int> isPinned,
      Value<String?> tags,
      Value<String?> folder,
      Value<int?> taskId,
      Value<int?> practicalId,
    });

final class $$ResourcesTableReferences
    extends BaseReferences<_$AppDatabase, $ResourcesTable, Resource> {
  $$ResourcesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SubjectsTable _subjectIdTable(_$AppDatabase db) =>
      db.subjects.createAlias('resources__subject_id__subjects__id');

  $$SubjectsTableProcessedTableManager get subjectId {
    final $_column = $_itemColumn<int>('subject_id')!;

    final manager = $$SubjectsTableTableManager(
      $_db,
      $_db.subjects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) =>
      db.chapters.createAlias('resources__chapter_id__chapters__id');

  $$ChaptersTableProcessedTableManager? get chapterId {
    final $_column = $_itemColumn<int>('chapter_id');
    if ($_column == null) return null;
    final manager = $$ChaptersTableTableManager(
      $_db,
      $_db.chapters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ResourcesTableFilterComposer
    extends Composer<_$AppDatabase, $ResourcesTable> {
  $$ResourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folder => $composableBuilder(
    column: $table.folder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get practicalId => $composableBuilder(
    column: $table.practicalId,
    builder: (column) => ColumnFilters(column),
  );

  $$SubjectsTableFilterComposer get subjectId {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableFilterComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableFilterComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $ResourcesTable> {
  $$ResourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folder => $composableBuilder(
    column: $table.folder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get practicalId => $composableBuilder(
    column: $table.practicalId,
    builder: (column) => ColumnOrderings(column),
  );

  $$SubjectsTableOrderingComposer get subjectId {
    final $$SubjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableOrderingComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableOrderingComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResourcesTable> {
  $$ResourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<int> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get folder =>
      $composableBuilder(column: $table.folder, builder: (column) => column);

  GeneratedColumn<int> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<int> get practicalId => $composableBuilder(
    column: $table.practicalId,
    builder: (column) => column,
  );

  $$SubjectsTableAnnotationComposer get subjectId {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableAnnotationComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResourcesTable,
          Resource,
          $$ResourcesTableFilterComposer,
          $$ResourcesTableOrderingComposer,
          $$ResourcesTableAnnotationComposer,
          $$ResourcesTableCreateCompanionBuilder,
          $$ResourcesTableUpdateCompanionBuilder,
          (Resource, $$ResourcesTableReferences),
          Resource,
          PrefetchHooks Function({bool subjectId, bool chapterId})
        > {
  $$ResourcesTableTableManager(_$AppDatabase db, $ResourcesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ResourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ResourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ResourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> subjectId = const Value.absent(),
                Value<int?> chapterId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<int> isPinned = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String?> folder = const Value.absent(),
                Value<int?> taskId = const Value.absent(),
                Value<int?> practicalId = const Value.absent(),
              }) => ResourcesCompanion(
                id: id,
                subjectId: subjectId,
                chapterId: chapterId,
                type: type,
                title: title,
                localPath: localPath,
                createdAt: createdAt,
                fileSize: fileSize,
                isPinned: isPinned,
                tags: tags,
                folder: folder,
                taskId: taskId,
                practicalId: practicalId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int subjectId,
                Value<int?> chapterId = const Value.absent(),
                required String type,
                required String title,
                required String localPath,
                required String createdAt,
                Value<int?> fileSize = const Value.absent(),
                Value<int> isPinned = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String?> folder = const Value.absent(),
                Value<int?> taskId = const Value.absent(),
                Value<int?> practicalId = const Value.absent(),
              }) => ResourcesCompanion.insert(
                id: id,
                subjectId: subjectId,
                chapterId: chapterId,
                type: type,
                title: title,
                localPath: localPath,
                createdAt: createdAt,
                fileSize: fileSize,
                isPinned: isPinned,
                tags: tags,
                folder: folder,
                taskId: taskId,
                practicalId: practicalId,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ResourcesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({subjectId = false, chapterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (subjectId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.subjectId,
                            referencedTable: $$ResourcesTableReferences
                                ._subjectIdTable(db),
                            referencedColumn:
                                $$ResourcesTableReferences
                                    ._subjectIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (chapterId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.chapterId,
                            referencedTable: $$ResourcesTableReferences
                                ._chapterIdTable(db),
                            referencedColumn:
                                $$ResourcesTableReferences
                                    ._chapterIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ResourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResourcesTable,
      Resource,
      $$ResourcesTableFilterComposer,
      $$ResourcesTableOrderingComposer,
      $$ResourcesTableAnnotationComposer,
      $$ResourcesTableCreateCompanionBuilder,
      $$ResourcesTableUpdateCompanionBuilder,
      (Resource, $$ResourcesTableReferences),
      Resource,
      PrefetchHooks Function({bool subjectId, bool chapterId})
    >;
typedef $$PracticalRecordsTableCreateCompanionBuilder =
    PracticalRecordsCompanion Function({
      Value<int> id,
      required int subjectId,
      required String title,
      Value<String?> dueAt,
      Value<String> status,
      Value<int?> resourceId,
      required String createdAt,
      Value<String?> objective,
      Value<String?> apparatus,
      Value<String?> procedure,
      Value<String?> observation,
      Value<String?> vivaQuestions,
    });
typedef $$PracticalRecordsTableUpdateCompanionBuilder =
    PracticalRecordsCompanion Function({
      Value<int> id,
      Value<int> subjectId,
      Value<String> title,
      Value<String?> dueAt,
      Value<String> status,
      Value<int?> resourceId,
      Value<String> createdAt,
      Value<String?> objective,
      Value<String?> apparatus,
      Value<String?> procedure,
      Value<String?> observation,
      Value<String?> vivaQuestions,
    });

final class $$PracticalRecordsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PracticalRecordsTable, PracticalRecord> {
  $$PracticalRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SubjectsTable _subjectIdTable(_$AppDatabase db) =>
      db.subjects.createAlias('practical_records__subject_id__subjects__id');

  $$SubjectsTableProcessedTableManager get subjectId {
    final $_column = $_itemColumn<int>('subject_id')!;

    final manager = $$SubjectsTableTableManager(
      $_db,
      $_db.subjects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PracticalRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $PracticalRecordsTable> {
  $$PracticalRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get objective => $composableBuilder(
    column: $table.objective,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apparatus => $composableBuilder(
    column: $table.apparatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get procedure => $composableBuilder(
    column: $table.procedure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vivaQuestions => $composableBuilder(
    column: $table.vivaQuestions,
    builder: (column) => ColumnFilters(column),
  );

  $$SubjectsTableFilterComposer get subjectId {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableFilterComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PracticalRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $PracticalRecordsTable> {
  $$PracticalRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get objective => $composableBuilder(
    column: $table.objective,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apparatus => $composableBuilder(
    column: $table.apparatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get procedure => $composableBuilder(
    column: $table.procedure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vivaQuestions => $composableBuilder(
    column: $table.vivaQuestions,
    builder: (column) => ColumnOrderings(column),
  );

  $$SubjectsTableOrderingComposer get subjectId {
    final $$SubjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableOrderingComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PracticalRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PracticalRecordsTable> {
  $$PracticalRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get objective =>
      $composableBuilder(column: $table.objective, builder: (column) => column);

  GeneratedColumn<String> get apparatus =>
      $composableBuilder(column: $table.apparatus, builder: (column) => column);

  GeneratedColumn<String> get procedure =>
      $composableBuilder(column: $table.procedure, builder: (column) => column);

  GeneratedColumn<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vivaQuestions => $composableBuilder(
    column: $table.vivaQuestions,
    builder: (column) => column,
  );

  $$SubjectsTableAnnotationComposer get subjectId {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PracticalRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PracticalRecordsTable,
          PracticalRecord,
          $$PracticalRecordsTableFilterComposer,
          $$PracticalRecordsTableOrderingComposer,
          $$PracticalRecordsTableAnnotationComposer,
          $$PracticalRecordsTableCreateCompanionBuilder,
          $$PracticalRecordsTableUpdateCompanionBuilder,
          (PracticalRecord, $$PracticalRecordsTableReferences),
          PracticalRecord,
          PrefetchHooks Function({bool subjectId})
        > {
  $$PracticalRecordsTableTableManager(
    _$AppDatabase db,
    $PracticalRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$PracticalRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PracticalRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$PracticalRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> subjectId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> dueAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> resourceId = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String?> objective = const Value.absent(),
                Value<String?> apparatus = const Value.absent(),
                Value<String?> procedure = const Value.absent(),
                Value<String?> observation = const Value.absent(),
                Value<String?> vivaQuestions = const Value.absent(),
              }) => PracticalRecordsCompanion(
                id: id,
                subjectId: subjectId,
                title: title,
                dueAt: dueAt,
                status: status,
                resourceId: resourceId,
                createdAt: createdAt,
                objective: objective,
                apparatus: apparatus,
                procedure: procedure,
                observation: observation,
                vivaQuestions: vivaQuestions,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int subjectId,
                required String title,
                Value<String?> dueAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> resourceId = const Value.absent(),
                required String createdAt,
                Value<String?> objective = const Value.absent(),
                Value<String?> apparatus = const Value.absent(),
                Value<String?> procedure = const Value.absent(),
                Value<String?> observation = const Value.absent(),
                Value<String?> vivaQuestions = const Value.absent(),
              }) => PracticalRecordsCompanion.insert(
                id: id,
                subjectId: subjectId,
                title: title,
                dueAt: dueAt,
                status: status,
                resourceId: resourceId,
                createdAt: createdAt,
                objective: objective,
                apparatus: apparatus,
                procedure: procedure,
                observation: observation,
                vivaQuestions: vivaQuestions,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$PracticalRecordsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({subjectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (subjectId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.subjectId,
                            referencedTable: $$PracticalRecordsTableReferences
                                ._subjectIdTable(db),
                            referencedColumn:
                                $$PracticalRecordsTableReferences
                                    ._subjectIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PracticalRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PracticalRecordsTable,
      PracticalRecord,
      $$PracticalRecordsTableFilterComposer,
      $$PracticalRecordsTableOrderingComposer,
      $$PracticalRecordsTableAnnotationComposer,
      $$PracticalRecordsTableCreateCompanionBuilder,
      $$PracticalRecordsTableUpdateCompanionBuilder,
      (PracticalRecord, $$PracticalRecordsTableReferences),
      PracticalRecord,
      PrefetchHooks Function({bool subjectId})
    >;
typedef $$BackupRecordsTableCreateCompanionBuilder =
    BackupRecordsCompanion Function({
      Value<int> id,
      required String createdAt,
      required String destination,
      required String status,
    });
typedef $$BackupRecordsTableUpdateCompanionBuilder =
    BackupRecordsCompanion Function({
      Value<int> id,
      Value<String> createdAt,
      Value<String> destination,
      Value<String> status,
    });

class $$BackupRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $BackupRecordsTable> {
  $$BackupRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BackupRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $BackupRecordsTable> {
  $$BackupRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BackupRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BackupRecordsTable> {
  $$BackupRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$BackupRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BackupRecordsTable,
          BackupRecord,
          $$BackupRecordsTableFilterComposer,
          $$BackupRecordsTableOrderingComposer,
          $$BackupRecordsTableAnnotationComposer,
          $$BackupRecordsTableCreateCompanionBuilder,
          $$BackupRecordsTableUpdateCompanionBuilder,
          (
            BackupRecord,
            BaseReferences<_$AppDatabase, $BackupRecordsTable, BackupRecord>,
          ),
          BackupRecord,
          PrefetchHooks Function()
        > {
  $$BackupRecordsTableTableManager(_$AppDatabase db, $BackupRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$BackupRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$BackupRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$BackupRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> destination = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => BackupRecordsCompanion(
                id: id,
                createdAt: createdAt,
                destination: destination,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String createdAt,
                required String destination,
                required String status,
              }) => BackupRecordsCompanion.insert(
                id: id,
                createdAt: createdAt,
                destination: destination,
                status: status,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BackupRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BackupRecordsTable,
      BackupRecord,
      $$BackupRecordsTableFilterComposer,
      $$BackupRecordsTableOrderingComposer,
      $$BackupRecordsTableAnnotationComposer,
      $$BackupRecordsTableCreateCompanionBuilder,
      $$BackupRecordsTableUpdateCompanionBuilder,
      (
        BackupRecord,
        BaseReferences<_$AppDatabase, $BackupRecordsTable, BackupRecord>,
      ),
      BackupRecord,
      PrefetchHooks Function()
    >;
typedef $$SyllabusTemplatesTableCreateCompanionBuilder =
    SyllabusTemplatesCompanion Function({
      Value<int> id,
      Value<int> templateVersion,
      required String exportedAt,
      Value<String?> sourceApp,
      Value<String?> sourceAttribution,
      Value<String?> importedAt,
      required String content,
      Value<String> contentTier,
    });
typedef $$SyllabusTemplatesTableUpdateCompanionBuilder =
    SyllabusTemplatesCompanion Function({
      Value<int> id,
      Value<int> templateVersion,
      Value<String> exportedAt,
      Value<String?> sourceApp,
      Value<String?> sourceAttribution,
      Value<String?> importedAt,
      Value<String> content,
      Value<String> contentTier,
    });

class $$SyllabusTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $SyllabusTemplatesTable> {
  $$SyllabusTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get templateVersion => $composableBuilder(
    column: $table.templateVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exportedAt => $composableBuilder(
    column: $table.exportedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceApp => $composableBuilder(
    column: $table.sourceApp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceAttribution => $composableBuilder(
    column: $table.sourceAttribution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentTier => $composableBuilder(
    column: $table.contentTier,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyllabusTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyllabusTemplatesTable> {
  $$SyllabusTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get templateVersion => $composableBuilder(
    column: $table.templateVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exportedAt => $composableBuilder(
    column: $table.exportedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceApp => $composableBuilder(
    column: $table.sourceApp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceAttribution => $composableBuilder(
    column: $table.sourceAttribution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentTier => $composableBuilder(
    column: $table.contentTier,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyllabusTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyllabusTemplatesTable> {
  $$SyllabusTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get templateVersion => $composableBuilder(
    column: $table.templateVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exportedAt => $composableBuilder(
    column: $table.exportedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceApp =>
      $composableBuilder(column: $table.sourceApp, builder: (column) => column);

  GeneratedColumn<String> get sourceAttribution => $composableBuilder(
    column: $table.sourceAttribution,
    builder: (column) => column,
  );

  GeneratedColumn<String> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get contentTier => $composableBuilder(
    column: $table.contentTier,
    builder: (column) => column,
  );
}

class $$SyllabusTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyllabusTemplatesTable,
          SyllabusTemplate,
          $$SyllabusTemplatesTableFilterComposer,
          $$SyllabusTemplatesTableOrderingComposer,
          $$SyllabusTemplatesTableAnnotationComposer,
          $$SyllabusTemplatesTableCreateCompanionBuilder,
          $$SyllabusTemplatesTableUpdateCompanionBuilder,
          (
            SyllabusTemplate,
            BaseReferences<
              _$AppDatabase,
              $SyllabusTemplatesTable,
              SyllabusTemplate
            >,
          ),
          SyllabusTemplate,
          PrefetchHooks Function()
        > {
  $$SyllabusTemplatesTableTableManager(
    _$AppDatabase db,
    $SyllabusTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SyllabusTemplatesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$SyllabusTemplatesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$SyllabusTemplatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> templateVersion = const Value.absent(),
                Value<String> exportedAt = const Value.absent(),
                Value<String?> sourceApp = const Value.absent(),
                Value<String?> sourceAttribution = const Value.absent(),
                Value<String?> importedAt = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> contentTier = const Value.absent(),
              }) => SyllabusTemplatesCompanion(
                id: id,
                templateVersion: templateVersion,
                exportedAt: exportedAt,
                sourceApp: sourceApp,
                sourceAttribution: sourceAttribution,
                importedAt: importedAt,
                content: content,
                contentTier: contentTier,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> templateVersion = const Value.absent(),
                required String exportedAt,
                Value<String?> sourceApp = const Value.absent(),
                Value<String?> sourceAttribution = const Value.absent(),
                Value<String?> importedAt = const Value.absent(),
                required String content,
                Value<String> contentTier = const Value.absent(),
              }) => SyllabusTemplatesCompanion.insert(
                id: id,
                templateVersion: templateVersion,
                exportedAt: exportedAt,
                sourceApp: sourceApp,
                sourceAttribution: sourceAttribution,
                importedAt: importedAt,
                content: content,
                contentTier: contentTier,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyllabusTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyllabusTemplatesTable,
      SyllabusTemplate,
      $$SyllabusTemplatesTableFilterComposer,
      $$SyllabusTemplatesTableOrderingComposer,
      $$SyllabusTemplatesTableAnnotationComposer,
      $$SyllabusTemplatesTableCreateCompanionBuilder,
      $$SyllabusTemplatesTableUpdateCompanionBuilder,
      (
        SyllabusTemplate,
        BaseReferences<
          _$AppDatabase,
          $SyllabusTemplatesTable,
          SyllabusTemplate
        >,
      ),
      SyllabusTemplate,
      PrefetchHooks Function()
    >;
typedef $$SyncMetaTableCreateCompanionBuilder =
    SyncMetaCompanion Function({
      Value<int> id,
      required String entity,
      required String localId,
      Value<String> syncStatus,
      Value<String?> lastSyncedAt,
      Value<String?> remoteVersion,
      Value<String?> conflictData,
      required String createdAt,
      required String updatedAt,
    });
typedef $$SyncMetaTableUpdateCompanionBuilder =
    SyncMetaCompanion Function({
      Value<int> id,
      Value<String> entity,
      Value<String> localId,
      Value<String> syncStatus,
      Value<String?> lastSyncedAt,
      Value<String?> remoteVersion,
      Value<String?> conflictData,
      Value<String> createdAt,
      Value<String> updatedAt,
    });

class $$SyncMetaTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteVersion => $composableBuilder(
    column: $table.remoteVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conflictData => $composableBuilder(
    column: $table.conflictData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteVersion => $composableBuilder(
    column: $table.remoteVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conflictData => $composableBuilder(
    column: $table.conflictData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteVersion => $composableBuilder(
    column: $table.remoteVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conflictData => $composableBuilder(
    column: $table.conflictData,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetaTable,
          SyncMetaData,
          $$SyncMetaTableFilterComposer,
          $$SyncMetaTableOrderingComposer,
          $$SyncMetaTableAnnotationComposer,
          $$SyncMetaTableCreateCompanionBuilder,
          $$SyncMetaTableUpdateCompanionBuilder,
          (
            SyncMetaData,
            BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaData>,
          ),
          SyncMetaData,
          PrefetchHooks Function()
        > {
  $$SyncMetaTableTableManager(_$AppDatabase db, $SyncMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SyncMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SyncMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SyncMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> localId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> lastSyncedAt = const Value.absent(),
                Value<String?> remoteVersion = const Value.absent(),
                Value<String?> conflictData = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => SyncMetaCompanion(
                id: id,
                entity: entity,
                localId: localId,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                remoteVersion: remoteVersion,
                conflictData: conflictData,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entity,
                required String localId,
                Value<String> syncStatus = const Value.absent(),
                Value<String?> lastSyncedAt = const Value.absent(),
                Value<String?> remoteVersion = const Value.absent(),
                Value<String?> conflictData = const Value.absent(),
                required String createdAt,
                required String updatedAt,
              }) => SyncMetaCompanion.insert(
                id: id,
                entity: entity,
                localId: localId,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                remoteVersion: remoteVersion,
                conflictData: conflictData,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetaTable,
      SyncMetaData,
      $$SyncMetaTableFilterComposer,
      $$SyncMetaTableOrderingComposer,
      $$SyncMetaTableAnnotationComposer,
      $$SyncMetaTableCreateCompanionBuilder,
      $$SyncMetaTableUpdateCompanionBuilder,
      (
        SyncMetaData,
        BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaData>,
      ),
      SyncMetaData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$ChaptersTableTableManager get chapters =>
      $$ChaptersTableTableManager(_db, _db.chapters);
  $$StudyTasksTableTableManager get studyTasks =>
      $$StudyTasksTableTableManager(_db, _db.studyTasks);
  $$FocusSessionsTableTableManager get focusSessions =>
      $$FocusSessionsTableTableManager(_db, _db.focusSessions);
  $$RevisionItemsTableTableManager get revisionItems =>
      $$RevisionItemsTableTableManager(_db, _db.revisionItems);
  $$ResourcesTableTableManager get resources =>
      $$ResourcesTableTableManager(_db, _db.resources);
  $$PracticalRecordsTableTableManager get practicalRecords =>
      $$PracticalRecordsTableTableManager(_db, _db.practicalRecords);
  $$BackupRecordsTableTableManager get backupRecords =>
      $$BackupRecordsTableTableManager(_db, _db.backupRecords);
  $$SyllabusTemplatesTableTableManager get syllabusTemplates =>
      $$SyllabusTemplatesTableTableManager(_db, _db.syllabusTemplates);
  $$SyncMetaTableTableManager get syncMeta =>
      $$SyncMetaTableTableManager(_db, _db.syncMeta);
}
