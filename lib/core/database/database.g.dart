// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $IdeasTable extends Ideas with TableInfo<$IdeasTable, Idea> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IdeasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isPromotedMeta =
      const VerificationMeta('isPromoted');
  @override
  late final GeneratedColumn<bool> isPromoted = GeneratedColumn<bool>(
      'is_promoted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_promoted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, content, category, createdAt, isPromoted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ideas';
  @override
  VerificationContext validateIntegrity(Insertable<Idea> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('is_promoted')) {
      context.handle(
          _isPromotedMeta,
          isPromoted.isAcceptableOrUnknown(
              data['is_promoted']!, _isPromotedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Idea map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Idea(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isPromoted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_promoted'])!,
    );
  }

  @override
  $IdeasTable createAlias(String alias) {
    return $IdeasTable(attachedDatabase, alias);
  }
}

class Idea extends DataClass implements Insertable<Idea> {
  final int id;
  final String content;
  final String category;
  final DateTime createdAt;
  final bool isPromoted;
  const Idea(
      {required this.id,
      required this.content,
      required this.category,
      required this.createdAt,
      required this.isPromoted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['content'] = Variable<String>(content);
    map['category'] = Variable<String>(category);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_promoted'] = Variable<bool>(isPromoted);
    return map;
  }

  IdeasCompanion toCompanion(bool nullToAbsent) {
    return IdeasCompanion(
      id: Value(id),
      content: Value(content),
      category: Value(category),
      createdAt: Value(createdAt),
      isPromoted: Value(isPromoted),
    );
  }

  factory Idea.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Idea(
      id: serializer.fromJson<int>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      category: serializer.fromJson<String>(json['category']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isPromoted: serializer.fromJson<bool>(json['isPromoted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'content': serializer.toJson<String>(content),
      'category': serializer.toJson<String>(category),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isPromoted': serializer.toJson<bool>(isPromoted),
    };
  }

  Idea copyWith(
          {int? id,
          String? content,
          String? category,
          DateTime? createdAt,
          bool? isPromoted}) =>
      Idea(
        id: id ?? this.id,
        content: content ?? this.content,
        category: category ?? this.category,
        createdAt: createdAt ?? this.createdAt,
        isPromoted: isPromoted ?? this.isPromoted,
      );
  Idea copyWithCompanion(IdeasCompanion data) {
    return Idea(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      category: data.category.present ? data.category.value : this.category,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isPromoted:
          data.isPromoted.present ? data.isPromoted.value : this.isPromoted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Idea(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('category: $category, ')
          ..write('createdAt: $createdAt, ')
          ..write('isPromoted: $isPromoted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, content, category, createdAt, isPromoted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Idea &&
          other.id == this.id &&
          other.content == this.content &&
          other.category == this.category &&
          other.createdAt == this.createdAt &&
          other.isPromoted == this.isPromoted);
}

class IdeasCompanion extends UpdateCompanion<Idea> {
  final Value<int> id;
  final Value<String> content;
  final Value<String> category;
  final Value<DateTime> createdAt;
  final Value<bool> isPromoted;
  const IdeasCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.category = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isPromoted = const Value.absent(),
  });
  IdeasCompanion.insert({
    this.id = const Value.absent(),
    required String content,
    required String category,
    this.createdAt = const Value.absent(),
    this.isPromoted = const Value.absent(),
  })  : content = Value(content),
        category = Value(category);
  static Insertable<Idea> custom({
    Expression<int>? id,
    Expression<String>? content,
    Expression<String>? category,
    Expression<DateTime>? createdAt,
    Expression<bool>? isPromoted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (category != null) 'category': category,
      if (createdAt != null) 'created_at': createdAt,
      if (isPromoted != null) 'is_promoted': isPromoted,
    });
  }

  IdeasCompanion copyWith(
      {Value<int>? id,
      Value<String>? content,
      Value<String>? category,
      Value<DateTime>? createdAt,
      Value<bool>? isPromoted}) {
    return IdeasCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isPromoted: isPromoted ?? this.isPromoted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isPromoted.present) {
      map['is_promoted'] = Variable<bool>(isPromoted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdeasCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('category: $category, ')
          ..write('createdAt: $createdAt, ')
          ..write('isPromoted: $isPromoted')
          ..write(')'))
        .toString();
  }
}

class $ActivityLogsTable extends ActivityLogs
    with TableInfo<$ActivityLogsTable, ActivityLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, category, description, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_logs';
  @override
  VerificationContext validateIntegrity(Insertable<ActivityLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $ActivityLogsTable createAlias(String alias) {
    return $ActivityLogsTable(attachedDatabase, alias);
  }
}

class ActivityLog extends DataClass implements Insertable<ActivityLog> {
  final int id;
  final String category;
  final String description;
  final DateTime timestamp;
  const ActivityLog(
      {required this.id,
      required this.category,
      required this.description,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category'] = Variable<String>(category);
    map['description'] = Variable<String>(description);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  ActivityLogsCompanion toCompanion(bool nullToAbsent) {
    return ActivityLogsCompanion(
      id: Value(id),
      category: Value(category),
      description: Value(description),
      timestamp: Value(timestamp),
    );
  }

  factory ActivityLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityLog(
      id: serializer.fromJson<int>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      description: serializer.fromJson<String>(json['description']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'category': serializer.toJson<String>(category),
      'description': serializer.toJson<String>(description),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  ActivityLog copyWith(
          {int? id,
          String? category,
          String? description,
          DateTime? timestamp}) =>
      ActivityLog(
        id: id ?? this.id,
        category: category ?? this.category,
        description: description ?? this.description,
        timestamp: timestamp ?? this.timestamp,
      );
  ActivityLog copyWithCompanion(ActivityLogsCompanion data) {
    return ActivityLog(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      description:
          data.description.present ? data.description.value : this.description,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLog(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, category, description, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityLog &&
          other.id == this.id &&
          other.category == this.category &&
          other.description == this.description &&
          other.timestamp == this.timestamp);
}

class ActivityLogsCompanion extends UpdateCompanion<ActivityLog> {
  final Value<int> id;
  final Value<String> category;
  final Value<String> description;
  final Value<DateTime> timestamp;
  const ActivityLogsCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  ActivityLogsCompanion.insert({
    this.id = const Value.absent(),
    required String category,
    required String description,
    this.timestamp = const Value.absent(),
  })  : category = Value(category),
        description = Value(description);
  static Insertable<ActivityLog> custom({
    Expression<int>? id,
    Expression<String>? category,
    Expression<String>? description,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  ActivityLogsCompanion copyWith(
      {Value<int>? id,
      Value<String>? category,
      Value<String>? description,
      Value<DateTime>? timestamp}) {
    return ActivityLogsCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLogsCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _techStackMeta =
      const VerificationMeta('techStack');
  @override
  late final GeneratedColumn<String> techStack = GeneratedColumn<String>(
      'tech_stack', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originIdeaIdMeta =
      const VerificationMeta('originIdeaId');
  @override
  late final GeneratedColumn<int> originIdeaId = GeneratedColumn<int>(
      'origin_idea_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES ideas (id) ON DELETE SET NULL'));
  static const VerificationMeta _storageOsMeta =
      const VerificationMeta('storageOs');
  @override
  late final GeneratedColumn<String> storageOs = GeneratedColumn<String>(
      'storage_os', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _storageDriveMeta =
      const VerificationMeta('storageDrive');
  @override
  late final GeneratedColumn<String> storageDrive = GeneratedColumn<String>(
      'storage_drive', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _storagePathMeta =
      const VerificationMeta('storagePath');
  @override
  late final GeneratedColumn<String> storagePath = GeneratedColumn<String>(
      'storage_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _storageSubfoldersJsonMeta =
      const VerificationMeta('storageSubfoldersJson');
  @override
  late final GeneratedColumn<String> storageSubfoldersJson =
      GeneratedColumn<String>('storage_subfolders_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _backupPathMeta =
      const VerificationMeta('backupPath');
  @override
  late final GeneratedColumn<String> backupPath = GeneratedColumn<String>(
      'backup_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _storageChecksumMeta =
      const VerificationMeta('storageChecksum');
  @override
  late final GeneratedColumn<String> storageChecksum = GeneratedColumn<String>(
      'storage_checksum', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deadlineMeta =
      const VerificationMeta('deadline');
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
      'deadline', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _repoUrlMeta =
      const VerificationMeta('repoUrl');
  @override
  late final GeneratedColumn<String> repoUrl = GeneratedColumn<String>(
      'repo_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        techStack,
        status,
        priority,
        tags,
        originIdeaId,
        storageOs,
        storageDrive,
        storagePath,
        storageSubfoldersJson,
        backupPath,
        storageChecksum,
        deadline,
        repoUrl,
        notes,
        createdAt,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(Insertable<Project> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('tech_stack')) {
      context.handle(_techStackMeta,
          techStack.isAcceptableOrUnknown(data['tech_stack']!, _techStackMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('origin_idea_id')) {
      context.handle(
          _originIdeaIdMeta,
          originIdeaId.isAcceptableOrUnknown(
              data['origin_idea_id']!, _originIdeaIdMeta));
    }
    if (data.containsKey('storage_os')) {
      context.handle(_storageOsMeta,
          storageOs.isAcceptableOrUnknown(data['storage_os']!, _storageOsMeta));
    }
    if (data.containsKey('storage_drive')) {
      context.handle(
          _storageDriveMeta,
          storageDrive.isAcceptableOrUnknown(
              data['storage_drive']!, _storageDriveMeta));
    }
    if (data.containsKey('storage_path')) {
      context.handle(
          _storagePathMeta,
          storagePath.isAcceptableOrUnknown(
              data['storage_path']!, _storagePathMeta));
    }
    if (data.containsKey('storage_subfolders_json')) {
      context.handle(
          _storageSubfoldersJsonMeta,
          storageSubfoldersJson.isAcceptableOrUnknown(
              data['storage_subfolders_json']!, _storageSubfoldersJsonMeta));
    }
    if (data.containsKey('backup_path')) {
      context.handle(
          _backupPathMeta,
          backupPath.isAcceptableOrUnknown(
              data['backup_path']!, _backupPathMeta));
    }
    if (data.containsKey('storage_checksum')) {
      context.handle(
          _storageChecksumMeta,
          storageChecksum.isAcceptableOrUnknown(
              data['storage_checksum']!, _storageChecksumMeta));
    }
    if (data.containsKey('deadline')) {
      context.handle(_deadlineMeta,
          deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta));
    }
    if (data.containsKey('repo_url')) {
      context.handle(_repoUrlMeta,
          repoUrl.isAcceptableOrUnknown(data['repo_url']!, _repoUrlMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      techStack: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tech_stack']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags']),
      originIdeaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}origin_idea_id']),
      storageOs: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}storage_os']),
      storageDrive: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}storage_drive']),
      storagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}storage_path']),
      storageSubfoldersJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}storage_subfolders_json']),
      backupPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}backup_path']),
      storageChecksum: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}storage_checksum']),
      deadline: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deadline']),
      repoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}repo_url']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final int id;
  final String name;
  final String? description;
  final String? techStack;
  final String status;
  final String priority;
  final String? tags;
  final int? originIdeaId;
  final String? storageOs;
  final String? storageDrive;
  final String? storagePath;
  final String? storageSubfoldersJson;
  final String? backupPath;
  final String? storageChecksum;
  final DateTime? deadline;
  final String? repoUrl;
  final String? notes;
  final DateTime createdAt;
  final DateTime? lastSyncedAt;
  const Project(
      {required this.id,
      required this.name,
      this.description,
      this.techStack,
      required this.status,
      required this.priority,
      this.tags,
      this.originIdeaId,
      this.storageOs,
      this.storageDrive,
      this.storagePath,
      this.storageSubfoldersJson,
      this.backupPath,
      this.storageChecksum,
      this.deadline,
      this.repoUrl,
      this.notes,
      required this.createdAt,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || techStack != null) {
      map['tech_stack'] = Variable<String>(techStack);
    }
    map['status'] = Variable<String>(status);
    map['priority'] = Variable<String>(priority);
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    if (!nullToAbsent || originIdeaId != null) {
      map['origin_idea_id'] = Variable<int>(originIdeaId);
    }
    if (!nullToAbsent || storageOs != null) {
      map['storage_os'] = Variable<String>(storageOs);
    }
    if (!nullToAbsent || storageDrive != null) {
      map['storage_drive'] = Variable<String>(storageDrive);
    }
    if (!nullToAbsent || storagePath != null) {
      map['storage_path'] = Variable<String>(storagePath);
    }
    if (!nullToAbsent || storageSubfoldersJson != null) {
      map['storage_subfolders_json'] = Variable<String>(storageSubfoldersJson);
    }
    if (!nullToAbsent || backupPath != null) {
      map['backup_path'] = Variable<String>(backupPath);
    }
    if (!nullToAbsent || storageChecksum != null) {
      map['storage_checksum'] = Variable<String>(storageChecksum);
    }
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    if (!nullToAbsent || repoUrl != null) {
      map['repo_url'] = Variable<String>(repoUrl);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      techStack: techStack == null && nullToAbsent
          ? const Value.absent()
          : Value(techStack),
      status: Value(status),
      priority: Value(priority),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      originIdeaId: originIdeaId == null && nullToAbsent
          ? const Value.absent()
          : Value(originIdeaId),
      storageOs: storageOs == null && nullToAbsent
          ? const Value.absent()
          : Value(storageOs),
      storageDrive: storageDrive == null && nullToAbsent
          ? const Value.absent()
          : Value(storageDrive),
      storagePath: storagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(storagePath),
      storageSubfoldersJson: storageSubfoldersJson == null && nullToAbsent
          ? const Value.absent()
          : Value(storageSubfoldersJson),
      backupPath: backupPath == null && nullToAbsent
          ? const Value.absent()
          : Value(backupPath),
      storageChecksum: storageChecksum == null && nullToAbsent
          ? const Value.absent()
          : Value(storageChecksum),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      repoUrl: repoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(repoUrl),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory Project.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      techStack: serializer.fromJson<String?>(json['techStack']),
      status: serializer.fromJson<String>(json['status']),
      priority: serializer.fromJson<String>(json['priority']),
      tags: serializer.fromJson<String?>(json['tags']),
      originIdeaId: serializer.fromJson<int?>(json['originIdeaId']),
      storageOs: serializer.fromJson<String?>(json['storageOs']),
      storageDrive: serializer.fromJson<String?>(json['storageDrive']),
      storagePath: serializer.fromJson<String?>(json['storagePath']),
      storageSubfoldersJson:
          serializer.fromJson<String?>(json['storageSubfoldersJson']),
      backupPath: serializer.fromJson<String?>(json['backupPath']),
      storageChecksum: serializer.fromJson<String?>(json['storageChecksum']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      repoUrl: serializer.fromJson<String?>(json['repoUrl']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'techStack': serializer.toJson<String?>(techStack),
      'status': serializer.toJson<String>(status),
      'priority': serializer.toJson<String>(priority),
      'tags': serializer.toJson<String?>(tags),
      'originIdeaId': serializer.toJson<int?>(originIdeaId),
      'storageOs': serializer.toJson<String?>(storageOs),
      'storageDrive': serializer.toJson<String?>(storageDrive),
      'storagePath': serializer.toJson<String?>(storagePath),
      'storageSubfoldersJson':
          serializer.toJson<String?>(storageSubfoldersJson),
      'backupPath': serializer.toJson<String?>(backupPath),
      'storageChecksum': serializer.toJson<String?>(storageChecksum),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'repoUrl': serializer.toJson<String?>(repoUrl),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  Project copyWith(
          {int? id,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<String?> techStack = const Value.absent(),
          String? status,
          String? priority,
          Value<String?> tags = const Value.absent(),
          Value<int?> originIdeaId = const Value.absent(),
          Value<String?> storageOs = const Value.absent(),
          Value<String?> storageDrive = const Value.absent(),
          Value<String?> storagePath = const Value.absent(),
          Value<String?> storageSubfoldersJson = const Value.absent(),
          Value<String?> backupPath = const Value.absent(),
          Value<String?> storageChecksum = const Value.absent(),
          Value<DateTime?> deadline = const Value.absent(),
          Value<String?> repoUrl = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      Project(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        techStack: techStack.present ? techStack.value : this.techStack,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        tags: tags.present ? tags.value : this.tags,
        originIdeaId:
            originIdeaId.present ? originIdeaId.value : this.originIdeaId,
        storageOs: storageOs.present ? storageOs.value : this.storageOs,
        storageDrive:
            storageDrive.present ? storageDrive.value : this.storageDrive,
        storagePath: storagePath.present ? storagePath.value : this.storagePath,
        storageSubfoldersJson: storageSubfoldersJson.present
            ? storageSubfoldersJson.value
            : this.storageSubfoldersJson,
        backupPath: backupPath.present ? backupPath.value : this.backupPath,
        storageChecksum: storageChecksum.present
            ? storageChecksum.value
            : this.storageChecksum,
        deadline: deadline.present ? deadline.value : this.deadline,
        repoUrl: repoUrl.present ? repoUrl.value : this.repoUrl,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      techStack: data.techStack.present ? data.techStack.value : this.techStack,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      tags: data.tags.present ? data.tags.value : this.tags,
      originIdeaId: data.originIdeaId.present
          ? data.originIdeaId.value
          : this.originIdeaId,
      storageOs: data.storageOs.present ? data.storageOs.value : this.storageOs,
      storageDrive: data.storageDrive.present
          ? data.storageDrive.value
          : this.storageDrive,
      storagePath:
          data.storagePath.present ? data.storagePath.value : this.storagePath,
      storageSubfoldersJson: data.storageSubfoldersJson.present
          ? data.storageSubfoldersJson.value
          : this.storageSubfoldersJson,
      backupPath:
          data.backupPath.present ? data.backupPath.value : this.backupPath,
      storageChecksum: data.storageChecksum.present
          ? data.storageChecksum.value
          : this.storageChecksum,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      repoUrl: data.repoUrl.present ? data.repoUrl.value : this.repoUrl,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('techStack: $techStack, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('tags: $tags, ')
          ..write('originIdeaId: $originIdeaId, ')
          ..write('storageOs: $storageOs, ')
          ..write('storageDrive: $storageDrive, ')
          ..write('storagePath: $storagePath, ')
          ..write('storageSubfoldersJson: $storageSubfoldersJson, ')
          ..write('backupPath: $backupPath, ')
          ..write('storageChecksum: $storageChecksum, ')
          ..write('deadline: $deadline, ')
          ..write('repoUrl: $repoUrl, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      description,
      techStack,
      status,
      priority,
      tags,
      originIdeaId,
      storageOs,
      storageDrive,
      storagePath,
      storageSubfoldersJson,
      backupPath,
      storageChecksum,
      deadline,
      repoUrl,
      notes,
      createdAt,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.techStack == this.techStack &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.tags == this.tags &&
          other.originIdeaId == this.originIdeaId &&
          other.storageOs == this.storageOs &&
          other.storageDrive == this.storageDrive &&
          other.storagePath == this.storagePath &&
          other.storageSubfoldersJson == this.storageSubfoldersJson &&
          other.backupPath == this.backupPath &&
          other.storageChecksum == this.storageChecksum &&
          other.deadline == this.deadline &&
          other.repoUrl == this.repoUrl &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> techStack;
  final Value<String> status;
  final Value<String> priority;
  final Value<String?> tags;
  final Value<int?> originIdeaId;
  final Value<String?> storageOs;
  final Value<String?> storageDrive;
  final Value<String?> storagePath;
  final Value<String?> storageSubfoldersJson;
  final Value<String?> backupPath;
  final Value<String?> storageChecksum;
  final Value<DateTime?> deadline;
  final Value<String?> repoUrl;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastSyncedAt;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.techStack = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.tags = const Value.absent(),
    this.originIdeaId = const Value.absent(),
    this.storageOs = const Value.absent(),
    this.storageDrive = const Value.absent(),
    this.storagePath = const Value.absent(),
    this.storageSubfoldersJson = const Value.absent(),
    this.backupPath = const Value.absent(),
    this.storageChecksum = const Value.absent(),
    this.deadline = const Value.absent(),
    this.repoUrl = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.techStack = const Value.absent(),
    required String status,
    required String priority,
    this.tags = const Value.absent(),
    this.originIdeaId = const Value.absent(),
    this.storageOs = const Value.absent(),
    this.storageDrive = const Value.absent(),
    this.storagePath = const Value.absent(),
    this.storageSubfoldersJson = const Value.absent(),
    this.backupPath = const Value.absent(),
    this.storageChecksum = const Value.absent(),
    this.deadline = const Value.absent(),
    this.repoUrl = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  })  : name = Value(name),
        status = Value(status),
        priority = Value(priority);
  static Insertable<Project> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? techStack,
    Expression<String>? status,
    Expression<String>? priority,
    Expression<String>? tags,
    Expression<int>? originIdeaId,
    Expression<String>? storageOs,
    Expression<String>? storageDrive,
    Expression<String>? storagePath,
    Expression<String>? storageSubfoldersJson,
    Expression<String>? backupPath,
    Expression<String>? storageChecksum,
    Expression<DateTime>? deadline,
    Expression<String>? repoUrl,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (techStack != null) 'tech_stack': techStack,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (tags != null) 'tags': tags,
      if (originIdeaId != null) 'origin_idea_id': originIdeaId,
      if (storageOs != null) 'storage_os': storageOs,
      if (storageDrive != null) 'storage_drive': storageDrive,
      if (storagePath != null) 'storage_path': storagePath,
      if (storageSubfoldersJson != null)
        'storage_subfolders_json': storageSubfoldersJson,
      if (backupPath != null) 'backup_path': backupPath,
      if (storageChecksum != null) 'storage_checksum': storageChecksum,
      if (deadline != null) 'deadline': deadline,
      if (repoUrl != null) 'repo_url': repoUrl,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  ProjectsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String?>? techStack,
      Value<String>? status,
      Value<String>? priority,
      Value<String?>? tags,
      Value<int?>? originIdeaId,
      Value<String?>? storageOs,
      Value<String?>? storageDrive,
      Value<String?>? storagePath,
      Value<String?>? storageSubfoldersJson,
      Value<String?>? backupPath,
      Value<String?>? storageChecksum,
      Value<DateTime?>? deadline,
      Value<String?>? repoUrl,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastSyncedAt}) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      techStack: techStack ?? this.techStack,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      originIdeaId: originIdeaId ?? this.originIdeaId,
      storageOs: storageOs ?? this.storageOs,
      storageDrive: storageDrive ?? this.storageDrive,
      storagePath: storagePath ?? this.storagePath,
      storageSubfoldersJson:
          storageSubfoldersJson ?? this.storageSubfoldersJson,
      backupPath: backupPath ?? this.backupPath,
      storageChecksum: storageChecksum ?? this.storageChecksum,
      deadline: deadline ?? this.deadline,
      repoUrl: repoUrl ?? this.repoUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (techStack.present) {
      map['tech_stack'] = Variable<String>(techStack.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (originIdeaId.present) {
      map['origin_idea_id'] = Variable<int>(originIdeaId.value);
    }
    if (storageOs.present) {
      map['storage_os'] = Variable<String>(storageOs.value);
    }
    if (storageDrive.present) {
      map['storage_drive'] = Variable<String>(storageDrive.value);
    }
    if (storagePath.present) {
      map['storage_path'] = Variable<String>(storagePath.value);
    }
    if (storageSubfoldersJson.present) {
      map['storage_subfolders_json'] =
          Variable<String>(storageSubfoldersJson.value);
    }
    if (backupPath.present) {
      map['backup_path'] = Variable<String>(backupPath.value);
    }
    if (storageChecksum.present) {
      map['storage_checksum'] = Variable<String>(storageChecksum.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (repoUrl.present) {
      map['repo_url'] = Variable<String>(repoUrl.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('techStack: $techStack, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('tags: $tags, ')
          ..write('originIdeaId: $originIdeaId, ')
          ..write('storageOs: $storageOs, ')
          ..write('storageDrive: $storageDrive, ')
          ..write('storagePath: $storagePath, ')
          ..write('storageSubfoldersJson: $storageSubfoldersJson, ')
          ..write('backupPath: $backupPath, ')
          ..write('storageChecksum: $storageChecksum, ')
          ..write('deadline: $deadline, ')
          ..write('repoUrl: $repoUrl, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $ProjectTasksTable extends ProjectTasks
    with TableInfo<$ProjectTasksTable, ProjectTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
      'project_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES projects (id) ON DELETE CASCADE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, projectId, title, isCompleted, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_tasks';
  @override
  VerificationContext validateIntegrity(Insertable<ProjectTask> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectTask(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}project_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ProjectTasksTable createAlias(String alias) {
    return $ProjectTasksTable(attachedDatabase, alias);
  }
}

class ProjectTask extends DataClass implements Insertable<ProjectTask> {
  final int id;
  final int projectId;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  const ProjectTask(
      {required this.id,
      required this.projectId,
      required this.title,
      required this.isCompleted,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<int>(projectId);
    map['title'] = Variable<String>(title);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProjectTasksCompanion toCompanion(bool nullToAbsent) {
    return ProjectTasksCompanion(
      id: Value(id),
      projectId: Value(projectId),
      title: Value(title),
      isCompleted: Value(isCompleted),
      createdAt: Value(createdAt),
    );
  }

  factory ProjectTask.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectTask(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      title: serializer.fromJson<String>(json['title']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int>(projectId),
      'title': serializer.toJson<String>(title),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ProjectTask copyWith(
          {int? id,
          int? projectId,
          String? title,
          bool? isCompleted,
          DateTime? createdAt}) =>
      ProjectTask(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        title: title ?? this.title,
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt ?? this.createdAt,
      );
  ProjectTask copyWithCompanion(ProjectTasksCompanion data) {
    return ProjectTask(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      title: data.title.present ? data.title.value : this.title,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectTask(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, title, isCompleted, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectTask &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.title == this.title &&
          other.isCompleted == this.isCompleted &&
          other.createdAt == this.createdAt);
}

class ProjectTasksCompanion extends UpdateCompanion<ProjectTask> {
  final Value<int> id;
  final Value<int> projectId;
  final Value<String> title;
  final Value<bool> isCompleted;
  final Value<DateTime> createdAt;
  const ProjectTasksCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.title = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ProjectTasksCompanion.insert({
    this.id = const Value.absent(),
    required int projectId,
    required String title,
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : projectId = Value(projectId),
        title = Value(title);
  static Insertable<ProjectTask> custom({
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<String>? title,
    Expression<bool>? isCompleted,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (title != null) 'title': title,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ProjectTasksCompanion copyWith(
      {Value<int>? id,
      Value<int>? projectId,
      Value<String>? title,
      Value<bool>? isCompleted,
      Value<DateTime>? createdAt}) {
    return ProjectTasksCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectTasksCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ResearchPapersTable extends ResearchPapers
    with TableInfo<$ResearchPapersTable, ResearchPaper> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResearchPapersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _abstractIdMeta =
      const VerificationMeta('abstractId');
  @override
  late final GeneratedColumn<String> abstractId = GeneratedColumn<String>(
      'abstract_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _coAuthorsMeta =
      const VerificationMeta('coAuthors');
  @override
  late final GeneratedColumn<String> coAuthors = GeneratedColumn<String>(
      'co_authors', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _paperLinkMeta =
      const VerificationMeta('paperLink');
  @override
  late final GeneratedColumn<String> paperLink = GeneratedColumn<String>(
      'paper_link', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _citationCountMeta =
      const VerificationMeta('citationCount');
  @override
  late final GeneratedColumn<int> citationCount = GeneratedColumn<int>(
      'citation_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
      'project_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES projects (id) ON DELETE SET NULL'));
  static const VerificationMeta _targetVenueMeta =
      const VerificationMeta('targetVenue');
  @override
  late final GeneratedColumn<String> targetVenue = GeneratedColumn<String>(
      'target_venue', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _submissionDeadlineMeta =
      const VerificationMeta('submissionDeadline');
  @override
  late final GeneratedColumn<DateTime> submissionDeadline =
      GeneratedColumn<DateTime>('submission_deadline', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _keywordsMeta =
      const VerificationMeta('keywords');
  @override
  late final GeneratedColumn<String> keywords = GeneratedColumn<String>(
      'keywords', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        abstractId,
        status,
        coAuthors,
        paperLink,
        citationCount,
        projectId,
        targetVenue,
        submissionDeadline,
        keywords,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'research_papers';
  @override
  VerificationContext validateIntegrity(Insertable<ResearchPaper> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('abstract_id')) {
      context.handle(
          _abstractIdMeta,
          abstractId.isAcceptableOrUnknown(
              data['abstract_id']!, _abstractIdMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('co_authors')) {
      context.handle(_coAuthorsMeta,
          coAuthors.isAcceptableOrUnknown(data['co_authors']!, _coAuthorsMeta));
    }
    if (data.containsKey('paper_link')) {
      context.handle(_paperLinkMeta,
          paperLink.isAcceptableOrUnknown(data['paper_link']!, _paperLinkMeta));
    }
    if (data.containsKey('citation_count')) {
      context.handle(
          _citationCountMeta,
          citationCount.isAcceptableOrUnknown(
              data['citation_count']!, _citationCountMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    }
    if (data.containsKey('target_venue')) {
      context.handle(
          _targetVenueMeta,
          targetVenue.isAcceptableOrUnknown(
              data['target_venue']!, _targetVenueMeta));
    }
    if (data.containsKey('submission_deadline')) {
      context.handle(
          _submissionDeadlineMeta,
          submissionDeadline.isAcceptableOrUnknown(
              data['submission_deadline']!, _submissionDeadlineMeta));
    }
    if (data.containsKey('keywords')) {
      context.handle(_keywordsMeta,
          keywords.isAcceptableOrUnknown(data['keywords']!, _keywordsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResearchPaper map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResearchPaper(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      abstractId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}abstract_id']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      coAuthors: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}co_authors']),
      paperLink: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}paper_link']),
      citationCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}citation_count'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}project_id']),
      targetVenue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_venue']),
      submissionDeadline: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}submission_deadline']),
      keywords: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}keywords']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ResearchPapersTable createAlias(String alias) {
    return $ResearchPapersTable(attachedDatabase, alias);
  }
}

class ResearchPaper extends DataClass implements Insertable<ResearchPaper> {
  final int id;
  final String title;
  final String? abstractId;
  final String status;
  final String? coAuthors;
  final String? paperLink;
  final int citationCount;
  final int? projectId;
  final String? targetVenue;
  final DateTime? submissionDeadline;
  final String? keywords;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ResearchPaper(
      {required this.id,
      required this.title,
      this.abstractId,
      required this.status,
      this.coAuthors,
      this.paperLink,
      required this.citationCount,
      this.projectId,
      this.targetVenue,
      this.submissionDeadline,
      this.keywords,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || abstractId != null) {
      map['abstract_id'] = Variable<String>(abstractId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || coAuthors != null) {
      map['co_authors'] = Variable<String>(coAuthors);
    }
    if (!nullToAbsent || paperLink != null) {
      map['paper_link'] = Variable<String>(paperLink);
    }
    map['citation_count'] = Variable<int>(citationCount);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<int>(projectId);
    }
    if (!nullToAbsent || targetVenue != null) {
      map['target_venue'] = Variable<String>(targetVenue);
    }
    if (!nullToAbsent || submissionDeadline != null) {
      map['submission_deadline'] = Variable<DateTime>(submissionDeadline);
    }
    if (!nullToAbsent || keywords != null) {
      map['keywords'] = Variable<String>(keywords);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ResearchPapersCompanion toCompanion(bool nullToAbsent) {
    return ResearchPapersCompanion(
      id: Value(id),
      title: Value(title),
      abstractId: abstractId == null && nullToAbsent
          ? const Value.absent()
          : Value(abstractId),
      status: Value(status),
      coAuthors: coAuthors == null && nullToAbsent
          ? const Value.absent()
          : Value(coAuthors),
      paperLink: paperLink == null && nullToAbsent
          ? const Value.absent()
          : Value(paperLink),
      citationCount: Value(citationCount),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      targetVenue: targetVenue == null && nullToAbsent
          ? const Value.absent()
          : Value(targetVenue),
      submissionDeadline: submissionDeadline == null && nullToAbsent
          ? const Value.absent()
          : Value(submissionDeadline),
      keywords: keywords == null && nullToAbsent
          ? const Value.absent()
          : Value(keywords),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ResearchPaper.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResearchPaper(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      abstractId: serializer.fromJson<String?>(json['abstractId']),
      status: serializer.fromJson<String>(json['status']),
      coAuthors: serializer.fromJson<String?>(json['coAuthors']),
      paperLink: serializer.fromJson<String?>(json['paperLink']),
      citationCount: serializer.fromJson<int>(json['citationCount']),
      projectId: serializer.fromJson<int?>(json['projectId']),
      targetVenue: serializer.fromJson<String?>(json['targetVenue']),
      submissionDeadline:
          serializer.fromJson<DateTime?>(json['submissionDeadline']),
      keywords: serializer.fromJson<String?>(json['keywords']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'abstractId': serializer.toJson<String?>(abstractId),
      'status': serializer.toJson<String>(status),
      'coAuthors': serializer.toJson<String?>(coAuthors),
      'paperLink': serializer.toJson<String?>(paperLink),
      'citationCount': serializer.toJson<int>(citationCount),
      'projectId': serializer.toJson<int?>(projectId),
      'targetVenue': serializer.toJson<String?>(targetVenue),
      'submissionDeadline': serializer.toJson<DateTime?>(submissionDeadline),
      'keywords': serializer.toJson<String?>(keywords),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ResearchPaper copyWith(
          {int? id,
          String? title,
          Value<String?> abstractId = const Value.absent(),
          String? status,
          Value<String?> coAuthors = const Value.absent(),
          Value<String?> paperLink = const Value.absent(),
          int? citationCount,
          Value<int?> projectId = const Value.absent(),
          Value<String?> targetVenue = const Value.absent(),
          Value<DateTime?> submissionDeadline = const Value.absent(),
          Value<String?> keywords = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ResearchPaper(
        id: id ?? this.id,
        title: title ?? this.title,
        abstractId: abstractId.present ? abstractId.value : this.abstractId,
        status: status ?? this.status,
        coAuthors: coAuthors.present ? coAuthors.value : this.coAuthors,
        paperLink: paperLink.present ? paperLink.value : this.paperLink,
        citationCount: citationCount ?? this.citationCount,
        projectId: projectId.present ? projectId.value : this.projectId,
        targetVenue: targetVenue.present ? targetVenue.value : this.targetVenue,
        submissionDeadline: submissionDeadline.present
            ? submissionDeadline.value
            : this.submissionDeadline,
        keywords: keywords.present ? keywords.value : this.keywords,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ResearchPaper copyWithCompanion(ResearchPapersCompanion data) {
    return ResearchPaper(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      abstractId:
          data.abstractId.present ? data.abstractId.value : this.abstractId,
      status: data.status.present ? data.status.value : this.status,
      coAuthors: data.coAuthors.present ? data.coAuthors.value : this.coAuthors,
      paperLink: data.paperLink.present ? data.paperLink.value : this.paperLink,
      citationCount: data.citationCount.present
          ? data.citationCount.value
          : this.citationCount,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      targetVenue:
          data.targetVenue.present ? data.targetVenue.value : this.targetVenue,
      submissionDeadline: data.submissionDeadline.present
          ? data.submissionDeadline.value
          : this.submissionDeadline,
      keywords: data.keywords.present ? data.keywords.value : this.keywords,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResearchPaper(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('abstractId: $abstractId, ')
          ..write('status: $status, ')
          ..write('coAuthors: $coAuthors, ')
          ..write('paperLink: $paperLink, ')
          ..write('citationCount: $citationCount, ')
          ..write('projectId: $projectId, ')
          ..write('targetVenue: $targetVenue, ')
          ..write('submissionDeadline: $submissionDeadline, ')
          ..write('keywords: $keywords, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      abstractId,
      status,
      coAuthors,
      paperLink,
      citationCount,
      projectId,
      targetVenue,
      submissionDeadline,
      keywords,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResearchPaper &&
          other.id == this.id &&
          other.title == this.title &&
          other.abstractId == this.abstractId &&
          other.status == this.status &&
          other.coAuthors == this.coAuthors &&
          other.paperLink == this.paperLink &&
          other.citationCount == this.citationCount &&
          other.projectId == this.projectId &&
          other.targetVenue == this.targetVenue &&
          other.submissionDeadline == this.submissionDeadline &&
          other.keywords == this.keywords &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ResearchPapersCompanion extends UpdateCompanion<ResearchPaper> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> abstractId;
  final Value<String> status;
  final Value<String?> coAuthors;
  final Value<String?> paperLink;
  final Value<int> citationCount;
  final Value<int?> projectId;
  final Value<String?> targetVenue;
  final Value<DateTime?> submissionDeadline;
  final Value<String?> keywords;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ResearchPapersCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.abstractId = const Value.absent(),
    this.status = const Value.absent(),
    this.coAuthors = const Value.absent(),
    this.paperLink = const Value.absent(),
    this.citationCount = const Value.absent(),
    this.projectId = const Value.absent(),
    this.targetVenue = const Value.absent(),
    this.submissionDeadline = const Value.absent(),
    this.keywords = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ResearchPapersCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.abstractId = const Value.absent(),
    required String status,
    this.coAuthors = const Value.absent(),
    this.paperLink = const Value.absent(),
    this.citationCount = const Value.absent(),
    this.projectId = const Value.absent(),
    this.targetVenue = const Value.absent(),
    this.submissionDeadline = const Value.absent(),
    this.keywords = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : title = Value(title),
        status = Value(status);
  static Insertable<ResearchPaper> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? abstractId,
    Expression<String>? status,
    Expression<String>? coAuthors,
    Expression<String>? paperLink,
    Expression<int>? citationCount,
    Expression<int>? projectId,
    Expression<String>? targetVenue,
    Expression<DateTime>? submissionDeadline,
    Expression<String>? keywords,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (abstractId != null) 'abstract_id': abstractId,
      if (status != null) 'status': status,
      if (coAuthors != null) 'co_authors': coAuthors,
      if (paperLink != null) 'paper_link': paperLink,
      if (citationCount != null) 'citation_count': citationCount,
      if (projectId != null) 'project_id': projectId,
      if (targetVenue != null) 'target_venue': targetVenue,
      if (submissionDeadline != null) 'submission_deadline': submissionDeadline,
      if (keywords != null) 'keywords': keywords,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ResearchPapersCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? abstractId,
      Value<String>? status,
      Value<String?>? coAuthors,
      Value<String?>? paperLink,
      Value<int>? citationCount,
      Value<int?>? projectId,
      Value<String?>? targetVenue,
      Value<DateTime?>? submissionDeadline,
      Value<String?>? keywords,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return ResearchPapersCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      abstractId: abstractId ?? this.abstractId,
      status: status ?? this.status,
      coAuthors: coAuthors ?? this.coAuthors,
      paperLink: paperLink ?? this.paperLink,
      citationCount: citationCount ?? this.citationCount,
      projectId: projectId ?? this.projectId,
      targetVenue: targetVenue ?? this.targetVenue,
      submissionDeadline: submissionDeadline ?? this.submissionDeadline,
      keywords: keywords ?? this.keywords,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (abstractId.present) {
      map['abstract_id'] = Variable<String>(abstractId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (coAuthors.present) {
      map['co_authors'] = Variable<String>(coAuthors.value);
    }
    if (paperLink.present) {
      map['paper_link'] = Variable<String>(paperLink.value);
    }
    if (citationCount.present) {
      map['citation_count'] = Variable<int>(citationCount.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (targetVenue.present) {
      map['target_venue'] = Variable<String>(targetVenue.value);
    }
    if (submissionDeadline.present) {
      map['submission_deadline'] = Variable<DateTime>(submissionDeadline.value);
    }
    if (keywords.present) {
      map['keywords'] = Variable<String>(keywords.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResearchPapersCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('abstractId: $abstractId, ')
          ..write('status: $status, ')
          ..write('coAuthors: $coAuthors, ')
          ..write('paperLink: $paperLink, ')
          ..write('citationCount: $citationCount, ')
          ..write('projectId: $projectId, ')
          ..write('targetVenue: $targetVenue, ')
          ..write('submissionDeadline: $submissionDeadline, ')
          ..write('keywords: $keywords, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ResearchRevisionsTable extends ResearchRevisions
    with TableInfo<$ResearchRevisionsTable, ResearchRevision> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResearchRevisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _paperIdMeta =
      const VerificationMeta('paperId');
  @override
  late final GeneratedColumn<int> paperId = GeneratedColumn<int>(
      'paper_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES research_papers (id) ON DELETE CASCADE'));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, paperId, note, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'research_revisions';
  @override
  VerificationContext validateIntegrity(Insertable<ResearchRevision> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('paper_id')) {
      context.handle(_paperIdMeta,
          paperId.isAcceptableOrUnknown(data['paper_id']!, _paperIdMeta));
    } else if (isInserting) {
      context.missing(_paperIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResearchRevision map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResearchRevision(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      paperId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}paper_id'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ResearchRevisionsTable createAlias(String alias) {
    return $ResearchRevisionsTable(attachedDatabase, alias);
  }
}

class ResearchRevision extends DataClass
    implements Insertable<ResearchRevision> {
  final int id;
  final int paperId;
  final String note;
  final DateTime createdAt;
  const ResearchRevision(
      {required this.id,
      required this.paperId,
      required this.note,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['paper_id'] = Variable<int>(paperId);
    map['note'] = Variable<String>(note);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ResearchRevisionsCompanion toCompanion(bool nullToAbsent) {
    return ResearchRevisionsCompanion(
      id: Value(id),
      paperId: Value(paperId),
      note: Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory ResearchRevision.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResearchRevision(
      id: serializer.fromJson<int>(json['id']),
      paperId: serializer.fromJson<int>(json['paperId']),
      note: serializer.fromJson<String>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'paperId': serializer.toJson<int>(paperId),
      'note': serializer.toJson<String>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ResearchRevision copyWith(
          {int? id, int? paperId, String? note, DateTime? createdAt}) =>
      ResearchRevision(
        id: id ?? this.id,
        paperId: paperId ?? this.paperId,
        note: note ?? this.note,
        createdAt: createdAt ?? this.createdAt,
      );
  ResearchRevision copyWithCompanion(ResearchRevisionsCompanion data) {
    return ResearchRevision(
      id: data.id.present ? data.id.value : this.id,
      paperId: data.paperId.present ? data.paperId.value : this.paperId,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResearchRevision(')
          ..write('id: $id, ')
          ..write('paperId: $paperId, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, paperId, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResearchRevision &&
          other.id == this.id &&
          other.paperId == this.paperId &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class ResearchRevisionsCompanion extends UpdateCompanion<ResearchRevision> {
  final Value<int> id;
  final Value<int> paperId;
  final Value<String> note;
  final Value<DateTime> createdAt;
  const ResearchRevisionsCompanion({
    this.id = const Value.absent(),
    this.paperId = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ResearchRevisionsCompanion.insert({
    this.id = const Value.absent(),
    required int paperId,
    required String note,
    this.createdAt = const Value.absent(),
  })  : paperId = Value(paperId),
        note = Value(note);
  static Insertable<ResearchRevision> custom({
    Expression<int>? id,
    Expression<int>? paperId,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (paperId != null) 'paper_id': paperId,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ResearchRevisionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? paperId,
      Value<String>? note,
      Value<DateTime>? createdAt}) {
    return ResearchRevisionsCompanion(
      id: id ?? this.id,
      paperId: paperId ?? this.paperId,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (paperId.present) {
      map['paper_id'] = Variable<int>(paperId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResearchRevisionsCompanion(')
          ..write('id: $id, ')
          ..write('paperId: $paperId, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $JobApplicationsTable extends JobApplications
    with TableInfo<$JobApplicationsTable, JobApplication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobApplicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _companyMeta =
      const VerificationMeta('company');
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
      'company', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _jdSnapshotMeta =
      const VerificationMeta('jdSnapshot');
  @override
  late final GeneratedColumn<String> jdSnapshot = GeneratedColumn<String>(
      'jd_snapshot', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resumeVersionMeta =
      const VerificationMeta('resumeVersion');
  @override
  late final GeneratedColumn<String> resumeVersion = GeneratedColumn<String>(
      'resume_version', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _coverLetterMeta =
      const VerificationMeta('coverLetter');
  @override
  late final GeneratedColumn<String> coverLetter = GeneratedColumn<String>(
      'cover_letter', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _outreachChannelMeta =
      const VerificationMeta('outreachChannel');
  @override
  late final GeneratedColumn<String> outreachChannel = GeneratedColumn<String>(
      'outreach_channel', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _followUpDateMeta =
      const VerificationMeta('followUpDate');
  @override
  late final GeneratedColumn<DateTime> followUpDate = GeneratedColumn<DateTime>(
      'follow_up_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
      'project_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES projects (id) ON DELETE SET NULL'));
  static const VerificationMeta _salaryTargetMeta =
      const VerificationMeta('salaryTarget');
  @override
  late final GeneratedColumn<String> salaryTarget = GeneratedColumn<String>(
      'salary_target', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _jobUrlMeta = const VerificationMeta('jobUrl');
  @override
  late final GeneratedColumn<String> jobUrl = GeneratedColumn<String>(
      'job_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contactPersonMeta =
      const VerificationMeta('contactPerson');
  @override
  late final GeneratedColumn<String> contactPerson = GeneratedColumn<String>(
      'contact_person', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        company,
        role,
        status,
        jdSnapshot,
        resumeVersion,
        coverLetter,
        outreachChannel,
        followUpDate,
        projectId,
        salaryTarget,
        jobUrl,
        contactPerson,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'job_applications';
  @override
  VerificationContext validateIntegrity(Insertable<JobApplication> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company')) {
      context.handle(_companyMeta,
          company.isAcceptableOrUnknown(data['company']!, _companyMeta));
    } else if (isInserting) {
      context.missing(_companyMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('jd_snapshot')) {
      context.handle(
          _jdSnapshotMeta,
          jdSnapshot.isAcceptableOrUnknown(
              data['jd_snapshot']!, _jdSnapshotMeta));
    }
    if (data.containsKey('resume_version')) {
      context.handle(
          _resumeVersionMeta,
          resumeVersion.isAcceptableOrUnknown(
              data['resume_version']!, _resumeVersionMeta));
    }
    if (data.containsKey('cover_letter')) {
      context.handle(
          _coverLetterMeta,
          coverLetter.isAcceptableOrUnknown(
              data['cover_letter']!, _coverLetterMeta));
    }
    if (data.containsKey('outreach_channel')) {
      context.handle(
          _outreachChannelMeta,
          outreachChannel.isAcceptableOrUnknown(
              data['outreach_channel']!, _outreachChannelMeta));
    }
    if (data.containsKey('follow_up_date')) {
      context.handle(
          _followUpDateMeta,
          followUpDate.isAcceptableOrUnknown(
              data['follow_up_date']!, _followUpDateMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    }
    if (data.containsKey('salary_target')) {
      context.handle(
          _salaryTargetMeta,
          salaryTarget.isAcceptableOrUnknown(
              data['salary_target']!, _salaryTargetMeta));
    }
    if (data.containsKey('job_url')) {
      context.handle(_jobUrlMeta,
          jobUrl.isAcceptableOrUnknown(data['job_url']!, _jobUrlMeta));
    }
    if (data.containsKey('contact_person')) {
      context.handle(
          _contactPersonMeta,
          contactPerson.isAcceptableOrUnknown(
              data['contact_person']!, _contactPersonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JobApplication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JobApplication(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      company: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}company'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      jdSnapshot: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}jd_snapshot']),
      resumeVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}resume_version']),
      coverLetter: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_letter']),
      outreachChannel: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}outreach_channel']),
      followUpDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}follow_up_date']),
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}project_id']),
      salaryTarget: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}salary_target']),
      jobUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}job_url']),
      contactPerson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_person']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $JobApplicationsTable createAlias(String alias) {
    return $JobApplicationsTable(attachedDatabase, alias);
  }
}

class JobApplication extends DataClass implements Insertable<JobApplication> {
  final int id;
  final String company;
  final String role;
  final String status;
  final String? jdSnapshot;
  final String? resumeVersion;
  final String? coverLetter;
  final String? outreachChannel;
  final DateTime? followUpDate;
  final int? projectId;
  final String? salaryTarget;
  final String? jobUrl;
  final String? contactPerson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const JobApplication(
      {required this.id,
      required this.company,
      required this.role,
      required this.status,
      this.jdSnapshot,
      this.resumeVersion,
      this.coverLetter,
      this.outreachChannel,
      this.followUpDate,
      this.projectId,
      this.salaryTarget,
      this.jobUrl,
      this.contactPerson,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company'] = Variable<String>(company);
    map['role'] = Variable<String>(role);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || jdSnapshot != null) {
      map['jd_snapshot'] = Variable<String>(jdSnapshot);
    }
    if (!nullToAbsent || resumeVersion != null) {
      map['resume_version'] = Variable<String>(resumeVersion);
    }
    if (!nullToAbsent || coverLetter != null) {
      map['cover_letter'] = Variable<String>(coverLetter);
    }
    if (!nullToAbsent || outreachChannel != null) {
      map['outreach_channel'] = Variable<String>(outreachChannel);
    }
    if (!nullToAbsent || followUpDate != null) {
      map['follow_up_date'] = Variable<DateTime>(followUpDate);
    }
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<int>(projectId);
    }
    if (!nullToAbsent || salaryTarget != null) {
      map['salary_target'] = Variable<String>(salaryTarget);
    }
    if (!nullToAbsent || jobUrl != null) {
      map['job_url'] = Variable<String>(jobUrl);
    }
    if (!nullToAbsent || contactPerson != null) {
      map['contact_person'] = Variable<String>(contactPerson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  JobApplicationsCompanion toCompanion(bool nullToAbsent) {
    return JobApplicationsCompanion(
      id: Value(id),
      company: Value(company),
      role: Value(role),
      status: Value(status),
      jdSnapshot: jdSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(jdSnapshot),
      resumeVersion: resumeVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(resumeVersion),
      coverLetter: coverLetter == null && nullToAbsent
          ? const Value.absent()
          : Value(coverLetter),
      outreachChannel: outreachChannel == null && nullToAbsent
          ? const Value.absent()
          : Value(outreachChannel),
      followUpDate: followUpDate == null && nullToAbsent
          ? const Value.absent()
          : Value(followUpDate),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      salaryTarget: salaryTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(salaryTarget),
      jobUrl:
          jobUrl == null && nullToAbsent ? const Value.absent() : Value(jobUrl),
      contactPerson: contactPerson == null && nullToAbsent
          ? const Value.absent()
          : Value(contactPerson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory JobApplication.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JobApplication(
      id: serializer.fromJson<int>(json['id']),
      company: serializer.fromJson<String>(json['company']),
      role: serializer.fromJson<String>(json['role']),
      status: serializer.fromJson<String>(json['status']),
      jdSnapshot: serializer.fromJson<String?>(json['jdSnapshot']),
      resumeVersion: serializer.fromJson<String?>(json['resumeVersion']),
      coverLetter: serializer.fromJson<String?>(json['coverLetter']),
      outreachChannel: serializer.fromJson<String?>(json['outreachChannel']),
      followUpDate: serializer.fromJson<DateTime?>(json['followUpDate']),
      projectId: serializer.fromJson<int?>(json['projectId']),
      salaryTarget: serializer.fromJson<String?>(json['salaryTarget']),
      jobUrl: serializer.fromJson<String?>(json['jobUrl']),
      contactPerson: serializer.fromJson<String?>(json['contactPerson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'company': serializer.toJson<String>(company),
      'role': serializer.toJson<String>(role),
      'status': serializer.toJson<String>(status),
      'jdSnapshot': serializer.toJson<String?>(jdSnapshot),
      'resumeVersion': serializer.toJson<String?>(resumeVersion),
      'coverLetter': serializer.toJson<String?>(coverLetter),
      'outreachChannel': serializer.toJson<String?>(outreachChannel),
      'followUpDate': serializer.toJson<DateTime?>(followUpDate),
      'projectId': serializer.toJson<int?>(projectId),
      'salaryTarget': serializer.toJson<String?>(salaryTarget),
      'jobUrl': serializer.toJson<String?>(jobUrl),
      'contactPerson': serializer.toJson<String?>(contactPerson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  JobApplication copyWith(
          {int? id,
          String? company,
          String? role,
          String? status,
          Value<String?> jdSnapshot = const Value.absent(),
          Value<String?> resumeVersion = const Value.absent(),
          Value<String?> coverLetter = const Value.absent(),
          Value<String?> outreachChannel = const Value.absent(),
          Value<DateTime?> followUpDate = const Value.absent(),
          Value<int?> projectId = const Value.absent(),
          Value<String?> salaryTarget = const Value.absent(),
          Value<String?> jobUrl = const Value.absent(),
          Value<String?> contactPerson = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      JobApplication(
        id: id ?? this.id,
        company: company ?? this.company,
        role: role ?? this.role,
        status: status ?? this.status,
        jdSnapshot: jdSnapshot.present ? jdSnapshot.value : this.jdSnapshot,
        resumeVersion:
            resumeVersion.present ? resumeVersion.value : this.resumeVersion,
        coverLetter: coverLetter.present ? coverLetter.value : this.coverLetter,
        outreachChannel: outreachChannel.present
            ? outreachChannel.value
            : this.outreachChannel,
        followUpDate:
            followUpDate.present ? followUpDate.value : this.followUpDate,
        projectId: projectId.present ? projectId.value : this.projectId,
        salaryTarget:
            salaryTarget.present ? salaryTarget.value : this.salaryTarget,
        jobUrl: jobUrl.present ? jobUrl.value : this.jobUrl,
        contactPerson:
            contactPerson.present ? contactPerson.value : this.contactPerson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  JobApplication copyWithCompanion(JobApplicationsCompanion data) {
    return JobApplication(
      id: data.id.present ? data.id.value : this.id,
      company: data.company.present ? data.company.value : this.company,
      role: data.role.present ? data.role.value : this.role,
      status: data.status.present ? data.status.value : this.status,
      jdSnapshot:
          data.jdSnapshot.present ? data.jdSnapshot.value : this.jdSnapshot,
      resumeVersion: data.resumeVersion.present
          ? data.resumeVersion.value
          : this.resumeVersion,
      coverLetter:
          data.coverLetter.present ? data.coverLetter.value : this.coverLetter,
      outreachChannel: data.outreachChannel.present
          ? data.outreachChannel.value
          : this.outreachChannel,
      followUpDate: data.followUpDate.present
          ? data.followUpDate.value
          : this.followUpDate,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      salaryTarget: data.salaryTarget.present
          ? data.salaryTarget.value
          : this.salaryTarget,
      jobUrl: data.jobUrl.present ? data.jobUrl.value : this.jobUrl,
      contactPerson: data.contactPerson.present
          ? data.contactPerson.value
          : this.contactPerson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JobApplication(')
          ..write('id: $id, ')
          ..write('company: $company, ')
          ..write('role: $role, ')
          ..write('status: $status, ')
          ..write('jdSnapshot: $jdSnapshot, ')
          ..write('resumeVersion: $resumeVersion, ')
          ..write('coverLetter: $coverLetter, ')
          ..write('outreachChannel: $outreachChannel, ')
          ..write('followUpDate: $followUpDate, ')
          ..write('projectId: $projectId, ')
          ..write('salaryTarget: $salaryTarget, ')
          ..write('jobUrl: $jobUrl, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      company,
      role,
      status,
      jdSnapshot,
      resumeVersion,
      coverLetter,
      outreachChannel,
      followUpDate,
      projectId,
      salaryTarget,
      jobUrl,
      contactPerson,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JobApplication &&
          other.id == this.id &&
          other.company == this.company &&
          other.role == this.role &&
          other.status == this.status &&
          other.jdSnapshot == this.jdSnapshot &&
          other.resumeVersion == this.resumeVersion &&
          other.coverLetter == this.coverLetter &&
          other.outreachChannel == this.outreachChannel &&
          other.followUpDate == this.followUpDate &&
          other.projectId == this.projectId &&
          other.salaryTarget == this.salaryTarget &&
          other.jobUrl == this.jobUrl &&
          other.contactPerson == this.contactPerson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class JobApplicationsCompanion extends UpdateCompanion<JobApplication> {
  final Value<int> id;
  final Value<String> company;
  final Value<String> role;
  final Value<String> status;
  final Value<String?> jdSnapshot;
  final Value<String?> resumeVersion;
  final Value<String?> coverLetter;
  final Value<String?> outreachChannel;
  final Value<DateTime?> followUpDate;
  final Value<int?> projectId;
  final Value<String?> salaryTarget;
  final Value<String?> jobUrl;
  final Value<String?> contactPerson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const JobApplicationsCompanion({
    this.id = const Value.absent(),
    this.company = const Value.absent(),
    this.role = const Value.absent(),
    this.status = const Value.absent(),
    this.jdSnapshot = const Value.absent(),
    this.resumeVersion = const Value.absent(),
    this.coverLetter = const Value.absent(),
    this.outreachChannel = const Value.absent(),
    this.followUpDate = const Value.absent(),
    this.projectId = const Value.absent(),
    this.salaryTarget = const Value.absent(),
    this.jobUrl = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  JobApplicationsCompanion.insert({
    this.id = const Value.absent(),
    required String company,
    required String role,
    required String status,
    this.jdSnapshot = const Value.absent(),
    this.resumeVersion = const Value.absent(),
    this.coverLetter = const Value.absent(),
    this.outreachChannel = const Value.absent(),
    this.followUpDate = const Value.absent(),
    this.projectId = const Value.absent(),
    this.salaryTarget = const Value.absent(),
    this.jobUrl = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : company = Value(company),
        role = Value(role),
        status = Value(status);
  static Insertable<JobApplication> custom({
    Expression<int>? id,
    Expression<String>? company,
    Expression<String>? role,
    Expression<String>? status,
    Expression<String>? jdSnapshot,
    Expression<String>? resumeVersion,
    Expression<String>? coverLetter,
    Expression<String>? outreachChannel,
    Expression<DateTime>? followUpDate,
    Expression<int>? projectId,
    Expression<String>? salaryTarget,
    Expression<String>? jobUrl,
    Expression<String>? contactPerson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (company != null) 'company': company,
      if (role != null) 'role': role,
      if (status != null) 'status': status,
      if (jdSnapshot != null) 'jd_snapshot': jdSnapshot,
      if (resumeVersion != null) 'resume_version': resumeVersion,
      if (coverLetter != null) 'cover_letter': coverLetter,
      if (outreachChannel != null) 'outreach_channel': outreachChannel,
      if (followUpDate != null) 'follow_up_date': followUpDate,
      if (projectId != null) 'project_id': projectId,
      if (salaryTarget != null) 'salary_target': salaryTarget,
      if (jobUrl != null) 'job_url': jobUrl,
      if (contactPerson != null) 'contact_person': contactPerson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  JobApplicationsCompanion copyWith(
      {Value<int>? id,
      Value<String>? company,
      Value<String>? role,
      Value<String>? status,
      Value<String?>? jdSnapshot,
      Value<String?>? resumeVersion,
      Value<String?>? coverLetter,
      Value<String?>? outreachChannel,
      Value<DateTime?>? followUpDate,
      Value<int?>? projectId,
      Value<String?>? salaryTarget,
      Value<String?>? jobUrl,
      Value<String?>? contactPerson,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return JobApplicationsCompanion(
      id: id ?? this.id,
      company: company ?? this.company,
      role: role ?? this.role,
      status: status ?? this.status,
      jdSnapshot: jdSnapshot ?? this.jdSnapshot,
      resumeVersion: resumeVersion ?? this.resumeVersion,
      coverLetter: coverLetter ?? this.coverLetter,
      outreachChannel: outreachChannel ?? this.outreachChannel,
      followUpDate: followUpDate ?? this.followUpDate,
      projectId: projectId ?? this.projectId,
      salaryTarget: salaryTarget ?? this.salaryTarget,
      jobUrl: jobUrl ?? this.jobUrl,
      contactPerson: contactPerson ?? this.contactPerson,
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
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (jdSnapshot.present) {
      map['jd_snapshot'] = Variable<String>(jdSnapshot.value);
    }
    if (resumeVersion.present) {
      map['resume_version'] = Variable<String>(resumeVersion.value);
    }
    if (coverLetter.present) {
      map['cover_letter'] = Variable<String>(coverLetter.value);
    }
    if (outreachChannel.present) {
      map['outreach_channel'] = Variable<String>(outreachChannel.value);
    }
    if (followUpDate.present) {
      map['follow_up_date'] = Variable<DateTime>(followUpDate.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (salaryTarget.present) {
      map['salary_target'] = Variable<String>(salaryTarget.value);
    }
    if (jobUrl.present) {
      map['job_url'] = Variable<String>(jobUrl.value);
    }
    if (contactPerson.present) {
      map['contact_person'] = Variable<String>(contactPerson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobApplicationsCompanion(')
          ..write('id: $id, ')
          ..write('company: $company, ')
          ..write('role: $role, ')
          ..write('status: $status, ')
          ..write('jdSnapshot: $jdSnapshot, ')
          ..write('resumeVersion: $resumeVersion, ')
          ..write('coverLetter: $coverLetter, ')
          ..write('outreachChannel: $outreachChannel, ')
          ..write('followUpDate: $followUpDate, ')
          ..write('projectId: $projectId, ')
          ..write('salaryTarget: $salaryTarget, ')
          ..write('jobUrl: $jobUrl, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$VelvetDatabase extends GeneratedDatabase {
  _$VelvetDatabase(QueryExecutor e) : super(e);
  $VelvetDatabaseManager get managers => $VelvetDatabaseManager(this);
  late final $IdeasTable ideas = $IdeasTable(this);
  late final $ActivityLogsTable activityLogs = $ActivityLogsTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $ProjectTasksTable projectTasks = $ProjectTasksTable(this);
  late final $ResearchPapersTable researchPapers = $ResearchPapersTable(this);
  late final $ResearchRevisionsTable researchRevisions =
      $ResearchRevisionsTable(this);
  late final $JobApplicationsTable jobApplications =
      $JobApplicationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        ideas,
        activityLogs,
        projects,
        projectTasks,
        researchPapers,
        researchRevisions,
        jobApplications
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('ideas',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('projects', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('projects',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('project_tasks', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('projects',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('research_papers', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('research_papers',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('research_revisions', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('projects',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('job_applications', kind: UpdateKind.update),
            ],
          ),
        ],
      );
}

typedef $$IdeasTableCreateCompanionBuilder = IdeasCompanion Function({
  Value<int> id,
  required String content,
  required String category,
  Value<DateTime> createdAt,
  Value<bool> isPromoted,
});
typedef $$IdeasTableUpdateCompanionBuilder = IdeasCompanion Function({
  Value<int> id,
  Value<String> content,
  Value<String> category,
  Value<DateTime> createdAt,
  Value<bool> isPromoted,
});

final class $$IdeasTableReferences
    extends BaseReferences<_$VelvetDatabase, $IdeasTable, Idea> {
  $$IdeasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProjectsTable, List<Project>> _projectsRefsTable(
          _$VelvetDatabase db) =>
      MultiTypedResultKey.fromTable(db.projects,
          aliasName:
              $_aliasNameGenerator(db.ideas.id, db.projects.originIdeaId));

  $$ProjectsTableProcessedTableManager get projectsRefs {
    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.originIdeaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_projectsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$IdeasTableFilterComposer
    extends Composer<_$VelvetDatabase, $IdeasTable> {
  $$IdeasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPromoted => $composableBuilder(
      column: $table.isPromoted, builder: (column) => ColumnFilters(column));

  Expression<bool> projectsRefs(
      Expression<bool> Function($$ProjectsTableFilterComposer f) f) {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.originIdeaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableFilterComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$IdeasTableOrderingComposer
    extends Composer<_$VelvetDatabase, $IdeasTable> {
  $$IdeasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPromoted => $composableBuilder(
      column: $table.isPromoted, builder: (column) => ColumnOrderings(column));
}

class $$IdeasTableAnnotationComposer
    extends Composer<_$VelvetDatabase, $IdeasTable> {
  $$IdeasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isPromoted => $composableBuilder(
      column: $table.isPromoted, builder: (column) => column);

  Expression<T> projectsRefs<T extends Object>(
      Expression<T> Function($$ProjectsTableAnnotationComposer a) f) {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.originIdeaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$IdeasTableTableManager extends RootTableManager<
    _$VelvetDatabase,
    $IdeasTable,
    Idea,
    $$IdeasTableFilterComposer,
    $$IdeasTableOrderingComposer,
    $$IdeasTableAnnotationComposer,
    $$IdeasTableCreateCompanionBuilder,
    $$IdeasTableUpdateCompanionBuilder,
    (Idea, $$IdeasTableReferences),
    Idea,
    PrefetchHooks Function({bool projectsRefs})> {
  $$IdeasTableTableManager(_$VelvetDatabase db, $IdeasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IdeasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IdeasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IdeasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isPromoted = const Value.absent(),
          }) =>
              IdeasCompanion(
            id: id,
            content: content,
            category: category,
            createdAt: createdAt,
            isPromoted: isPromoted,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String content,
            required String category,
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isPromoted = const Value.absent(),
          }) =>
              IdeasCompanion.insert(
            id: id,
            content: content,
            category: category,
            createdAt: createdAt,
            isPromoted: isPromoted,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$IdeasTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({projectsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (projectsRefs) db.projects],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (projectsRefs)
                    await $_getPrefetchedData<Idea, $IdeasTable, Project>(
                        currentTable: table,
                        referencedTable:
                            $$IdeasTableReferences._projectsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$IdeasTableReferences(db, table, p0).projectsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.originIdeaId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$IdeasTableProcessedTableManager = ProcessedTableManager<
    _$VelvetDatabase,
    $IdeasTable,
    Idea,
    $$IdeasTableFilterComposer,
    $$IdeasTableOrderingComposer,
    $$IdeasTableAnnotationComposer,
    $$IdeasTableCreateCompanionBuilder,
    $$IdeasTableUpdateCompanionBuilder,
    (Idea, $$IdeasTableReferences),
    Idea,
    PrefetchHooks Function({bool projectsRefs})>;
typedef $$ActivityLogsTableCreateCompanionBuilder = ActivityLogsCompanion
    Function({
  Value<int> id,
  required String category,
  required String description,
  Value<DateTime> timestamp,
});
typedef $$ActivityLogsTableUpdateCompanionBuilder = ActivityLogsCompanion
    Function({
  Value<int> id,
  Value<String> category,
  Value<String> description,
  Value<DateTime> timestamp,
});

class $$ActivityLogsTableFilterComposer
    extends Composer<_$VelvetDatabase, $ActivityLogsTable> {
  $$ActivityLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));
}

class $$ActivityLogsTableOrderingComposer
    extends Composer<_$VelvetDatabase, $ActivityLogsTable> {
  $$ActivityLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));
}

class $$ActivityLogsTableAnnotationComposer
    extends Composer<_$VelvetDatabase, $ActivityLogsTable> {
  $$ActivityLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$ActivityLogsTableTableManager extends RootTableManager<
    _$VelvetDatabase,
    $ActivityLogsTable,
    ActivityLog,
    $$ActivityLogsTableFilterComposer,
    $$ActivityLogsTableOrderingComposer,
    $$ActivityLogsTableAnnotationComposer,
    $$ActivityLogsTableCreateCompanionBuilder,
    $$ActivityLogsTableUpdateCompanionBuilder,
    (
      ActivityLog,
      BaseReferences<_$VelvetDatabase, $ActivityLogsTable, ActivityLog>
    ),
    ActivityLog,
    PrefetchHooks Function()> {
  $$ActivityLogsTableTableManager(_$VelvetDatabase db, $ActivityLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
          }) =>
              ActivityLogsCompanion(
            id: id,
            category: category,
            description: description,
            timestamp: timestamp,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String category,
            required String description,
            Value<DateTime> timestamp = const Value.absent(),
          }) =>
              ActivityLogsCompanion.insert(
            id: id,
            category: category,
            description: description,
            timestamp: timestamp,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ActivityLogsTableProcessedTableManager = ProcessedTableManager<
    _$VelvetDatabase,
    $ActivityLogsTable,
    ActivityLog,
    $$ActivityLogsTableFilterComposer,
    $$ActivityLogsTableOrderingComposer,
    $$ActivityLogsTableAnnotationComposer,
    $$ActivityLogsTableCreateCompanionBuilder,
    $$ActivityLogsTableUpdateCompanionBuilder,
    (
      ActivityLog,
      BaseReferences<_$VelvetDatabase, $ActivityLogsTable, ActivityLog>
    ),
    ActivityLog,
    PrefetchHooks Function()>;
typedef $$ProjectsTableCreateCompanionBuilder = ProjectsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> description,
  Value<String?> techStack,
  required String status,
  required String priority,
  Value<String?> tags,
  Value<int?> originIdeaId,
  Value<String?> storageOs,
  Value<String?> storageDrive,
  Value<String?> storagePath,
  Value<String?> storageSubfoldersJson,
  Value<String?> backupPath,
  Value<String?> storageChecksum,
  Value<DateTime?> deadline,
  Value<String?> repoUrl,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime?> lastSyncedAt,
});
typedef $$ProjectsTableUpdateCompanionBuilder = ProjectsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> description,
  Value<String?> techStack,
  Value<String> status,
  Value<String> priority,
  Value<String?> tags,
  Value<int?> originIdeaId,
  Value<String?> storageOs,
  Value<String?> storageDrive,
  Value<String?> storagePath,
  Value<String?> storageSubfoldersJson,
  Value<String?> backupPath,
  Value<String?> storageChecksum,
  Value<DateTime?> deadline,
  Value<String?> repoUrl,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime?> lastSyncedAt,
});

final class $$ProjectsTableReferences
    extends BaseReferences<_$VelvetDatabase, $ProjectsTable, Project> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $IdeasTable _originIdeaIdTable(_$VelvetDatabase db) => db.ideas
      .createAlias($_aliasNameGenerator(db.projects.originIdeaId, db.ideas.id));

  $$IdeasTableProcessedTableManager? get originIdeaId {
    final $_column = $_itemColumn<int>('origin_idea_id');
    if ($_column == null) return null;
    final manager = $$IdeasTableTableManager($_db, $_db.ideas)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_originIdeaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ProjectTasksTable, List<ProjectTask>>
      _projectTasksRefsTable(_$VelvetDatabase db) =>
          MultiTypedResultKey.fromTable(db.projectTasks,
              aliasName: $_aliasNameGenerator(
                  db.projects.id, db.projectTasks.projectId));

  $$ProjectTasksTableProcessedTableManager get projectTasksRefs {
    final manager = $$ProjectTasksTableTableManager($_db, $_db.projectTasks)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_projectTasksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ResearchPapersTable, List<ResearchPaper>>
      _researchPapersRefsTable(_$VelvetDatabase db) =>
          MultiTypedResultKey.fromTable(db.researchPapers,
              aliasName: $_aliasNameGenerator(
                  db.projects.id, db.researchPapers.projectId));

  $$ResearchPapersTableProcessedTableManager get researchPapersRefs {
    final manager = $$ResearchPapersTableTableManager($_db, $_db.researchPapers)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_researchPapersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$JobApplicationsTable, List<JobApplication>>
      _jobApplicationsRefsTable(_$VelvetDatabase db) =>
          MultiTypedResultKey.fromTable(db.jobApplications,
              aliasName: $_aliasNameGenerator(
                  db.projects.id, db.jobApplications.projectId));

  $$JobApplicationsTableProcessedTableManager get jobApplicationsRefs {
    final manager =
        $$JobApplicationsTableTableManager($_db, $_db.jobApplications)
            .filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_jobApplicationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$VelvetDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get techStack => $composableBuilder(
      column: $table.techStack, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storageOs => $composableBuilder(
      column: $table.storageOs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storageDrive => $composableBuilder(
      column: $table.storageDrive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storagePath => $composableBuilder(
      column: $table.storagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storageSubfoldersJson => $composableBuilder(
      column: $table.storageSubfoldersJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get backupPath => $composableBuilder(
      column: $table.backupPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storageChecksum => $composableBuilder(
      column: $table.storageChecksum,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get repoUrl => $composableBuilder(
      column: $table.repoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  $$IdeasTableFilterComposer get originIdeaId {
    final $$IdeasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.originIdeaId,
        referencedTable: $db.ideas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IdeasTableFilterComposer(
              $db: $db,
              $table: $db.ideas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> projectTasksRefs(
      Expression<bool> Function($$ProjectTasksTableFilterComposer f) f) {
    final $$ProjectTasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.projectTasks,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectTasksTableFilterComposer(
              $db: $db,
              $table: $db.projectTasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> researchPapersRefs(
      Expression<bool> Function($$ResearchPapersTableFilterComposer f) f) {
    final $$ResearchPapersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.researchPapers,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ResearchPapersTableFilterComposer(
              $db: $db,
              $table: $db.researchPapers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> jobApplicationsRefs(
      Expression<bool> Function($$JobApplicationsTableFilterComposer f) f) {
    final $$JobApplicationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.jobApplications,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$JobApplicationsTableFilterComposer(
              $db: $db,
              $table: $db.jobApplications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$VelvetDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get techStack => $composableBuilder(
      column: $table.techStack, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storageOs => $composableBuilder(
      column: $table.storageOs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storageDrive => $composableBuilder(
      column: $table.storageDrive,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storagePath => $composableBuilder(
      column: $table.storagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storageSubfoldersJson => $composableBuilder(
      column: $table.storageSubfoldersJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get backupPath => $composableBuilder(
      column: $table.backupPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storageChecksum => $composableBuilder(
      column: $table.storageChecksum,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get repoUrl => $composableBuilder(
      column: $table.repoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  $$IdeasTableOrderingComposer get originIdeaId {
    final $$IdeasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.originIdeaId,
        referencedTable: $db.ideas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IdeasTableOrderingComposer(
              $db: $db,
              $table: $db.ideas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$VelvetDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get techStack =>
      $composableBuilder(column: $table.techStack, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get storageOs =>
      $composableBuilder(column: $table.storageOs, builder: (column) => column);

  GeneratedColumn<String> get storageDrive => $composableBuilder(
      column: $table.storageDrive, builder: (column) => column);

  GeneratedColumn<String> get storagePath => $composableBuilder(
      column: $table.storagePath, builder: (column) => column);

  GeneratedColumn<String> get storageSubfoldersJson => $composableBuilder(
      column: $table.storageSubfoldersJson, builder: (column) => column);

  GeneratedColumn<String> get backupPath => $composableBuilder(
      column: $table.backupPath, builder: (column) => column);

  GeneratedColumn<String> get storageChecksum => $composableBuilder(
      column: $table.storageChecksum, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<String> get repoUrl =>
      $composableBuilder(column: $table.repoUrl, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  $$IdeasTableAnnotationComposer get originIdeaId {
    final $$IdeasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.originIdeaId,
        referencedTable: $db.ideas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IdeasTableAnnotationComposer(
              $db: $db,
              $table: $db.ideas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> projectTasksRefs<T extends Object>(
      Expression<T> Function($$ProjectTasksTableAnnotationComposer a) f) {
    final $$ProjectTasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.projectTasks,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectTasksTableAnnotationComposer(
              $db: $db,
              $table: $db.projectTasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> researchPapersRefs<T extends Object>(
      Expression<T> Function($$ResearchPapersTableAnnotationComposer a) f) {
    final $$ResearchPapersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.researchPapers,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ResearchPapersTableAnnotationComposer(
              $db: $db,
              $table: $db.researchPapers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> jobApplicationsRefs<T extends Object>(
      Expression<T> Function($$JobApplicationsTableAnnotationComposer a) f) {
    final $$JobApplicationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.jobApplications,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$JobApplicationsTableAnnotationComposer(
              $db: $db,
              $table: $db.jobApplications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProjectsTableTableManager extends RootTableManager<
    _$VelvetDatabase,
    $ProjectsTable,
    Project,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableAnnotationComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder,
    (Project, $$ProjectsTableReferences),
    Project,
    PrefetchHooks Function(
        {bool originIdeaId,
        bool projectTasksRefs,
        bool researchPapersRefs,
        bool jobApplicationsRefs})> {
  $$ProjectsTableTableManager(_$VelvetDatabase db, $ProjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> techStack = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String?> tags = const Value.absent(),
            Value<int?> originIdeaId = const Value.absent(),
            Value<String?> storageOs = const Value.absent(),
            Value<String?> storageDrive = const Value.absent(),
            Value<String?> storagePath = const Value.absent(),
            Value<String?> storageSubfoldersJson = const Value.absent(),
            Value<String?> backupPath = const Value.absent(),
            Value<String?> storageChecksum = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<String?> repoUrl = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
          }) =>
              ProjectsCompanion(
            id: id,
            name: name,
            description: description,
            techStack: techStack,
            status: status,
            priority: priority,
            tags: tags,
            originIdeaId: originIdeaId,
            storageOs: storageOs,
            storageDrive: storageDrive,
            storagePath: storagePath,
            storageSubfoldersJson: storageSubfoldersJson,
            backupPath: backupPath,
            storageChecksum: storageChecksum,
            deadline: deadline,
            repoUrl: repoUrl,
            notes: notes,
            createdAt: createdAt,
            lastSyncedAt: lastSyncedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> description = const Value.absent(),
            Value<String?> techStack = const Value.absent(),
            required String status,
            required String priority,
            Value<String?> tags = const Value.absent(),
            Value<int?> originIdeaId = const Value.absent(),
            Value<String?> storageOs = const Value.absent(),
            Value<String?> storageDrive = const Value.absent(),
            Value<String?> storagePath = const Value.absent(),
            Value<String?> storageSubfoldersJson = const Value.absent(),
            Value<String?> backupPath = const Value.absent(),
            Value<String?> storageChecksum = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<String?> repoUrl = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
          }) =>
              ProjectsCompanion.insert(
            id: id,
            name: name,
            description: description,
            techStack: techStack,
            status: status,
            priority: priority,
            tags: tags,
            originIdeaId: originIdeaId,
            storageOs: storageOs,
            storageDrive: storageDrive,
            storagePath: storagePath,
            storageSubfoldersJson: storageSubfoldersJson,
            backupPath: backupPath,
            storageChecksum: storageChecksum,
            deadline: deadline,
            repoUrl: repoUrl,
            notes: notes,
            createdAt: createdAt,
            lastSyncedAt: lastSyncedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProjectsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {originIdeaId = false,
              projectTasksRefs = false,
              researchPapersRefs = false,
              jobApplicationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (projectTasksRefs) db.projectTasks,
                if (researchPapersRefs) db.researchPapers,
                if (jobApplicationsRefs) db.jobApplications
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
                      dynamic>>(state) {
                if (originIdeaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.originIdeaId,
                    referencedTable:
                        $$ProjectsTableReferences._originIdeaIdTable(db),
                    referencedColumn:
                        $$ProjectsTableReferences._originIdeaIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (projectTasksRefs)
                    await $_getPrefetchedData<Project, $ProjectsTable,
                            ProjectTask>(
                        currentTable: table,
                        referencedTable: $$ProjectsTableReferences
                            ._projectTasksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0)
                                .projectTasksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items),
                  if (researchPapersRefs)
                    await $_getPrefetchedData<Project, $ProjectsTable,
                            ResearchPaper>(
                        currentTable: table,
                        referencedTable: $$ProjectsTableReferences
                            ._researchPapersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0)
                                .researchPapersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items),
                  if (jobApplicationsRefs)
                    await $_getPrefetchedData<Project, $ProjectsTable,
                            JobApplication>(
                        currentTable: table,
                        referencedTable: $$ProjectsTableReferences
                            ._jobApplicationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0)
                                .jobApplicationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProjectsTableProcessedTableManager = ProcessedTableManager<
    _$VelvetDatabase,
    $ProjectsTable,
    Project,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableAnnotationComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder,
    (Project, $$ProjectsTableReferences),
    Project,
    PrefetchHooks Function(
        {bool originIdeaId,
        bool projectTasksRefs,
        bool researchPapersRefs,
        bool jobApplicationsRefs})>;
typedef $$ProjectTasksTableCreateCompanionBuilder = ProjectTasksCompanion
    Function({
  Value<int> id,
  required int projectId,
  required String title,
  Value<bool> isCompleted,
  Value<DateTime> createdAt,
});
typedef $$ProjectTasksTableUpdateCompanionBuilder = ProjectTasksCompanion
    Function({
  Value<int> id,
  Value<int> projectId,
  Value<String> title,
  Value<bool> isCompleted,
  Value<DateTime> createdAt,
});

final class $$ProjectTasksTableReferences
    extends BaseReferences<_$VelvetDatabase, $ProjectTasksTable, ProjectTask> {
  $$ProjectTasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$VelvetDatabase db) =>
      db.projects.createAlias(
          $_aliasNameGenerator(db.projectTasks.projectId, db.projects.id));

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ProjectTasksTableFilterComposer
    extends Composer<_$VelvetDatabase, $ProjectTasksTable> {
  $$ProjectTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableFilterComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProjectTasksTableOrderingComposer
    extends Composer<_$VelvetDatabase, $ProjectTasksTable> {
  $$ProjectTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableOrderingComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProjectTasksTableAnnotationComposer
    extends Composer<_$VelvetDatabase, $ProjectTasksTable> {
  $$ProjectTasksTableAnnotationComposer({
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

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProjectTasksTableTableManager extends RootTableManager<
    _$VelvetDatabase,
    $ProjectTasksTable,
    ProjectTask,
    $$ProjectTasksTableFilterComposer,
    $$ProjectTasksTableOrderingComposer,
    $$ProjectTasksTableAnnotationComposer,
    $$ProjectTasksTableCreateCompanionBuilder,
    $$ProjectTasksTableUpdateCompanionBuilder,
    (ProjectTask, $$ProjectTasksTableReferences),
    ProjectTask,
    PrefetchHooks Function({bool projectId})> {
  $$ProjectTasksTableTableManager(_$VelvetDatabase db, $ProjectTasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> projectId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ProjectTasksCompanion(
            id: id,
            projectId: projectId,
            title: title,
            isCompleted: isCompleted,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int projectId,
            required String title,
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ProjectTasksCompanion.insert(
            id: id,
            projectId: projectId,
            title: title,
            isCompleted: isCompleted,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProjectTasksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
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
                      dynamic>>(state) {
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$ProjectTasksTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$ProjectTasksTableReferences._projectIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ProjectTasksTableProcessedTableManager = ProcessedTableManager<
    _$VelvetDatabase,
    $ProjectTasksTable,
    ProjectTask,
    $$ProjectTasksTableFilterComposer,
    $$ProjectTasksTableOrderingComposer,
    $$ProjectTasksTableAnnotationComposer,
    $$ProjectTasksTableCreateCompanionBuilder,
    $$ProjectTasksTableUpdateCompanionBuilder,
    (ProjectTask, $$ProjectTasksTableReferences),
    ProjectTask,
    PrefetchHooks Function({bool projectId})>;
typedef $$ResearchPapersTableCreateCompanionBuilder = ResearchPapersCompanion
    Function({
  Value<int> id,
  required String title,
  Value<String?> abstractId,
  required String status,
  Value<String?> coAuthors,
  Value<String?> paperLink,
  Value<int> citationCount,
  Value<int?> projectId,
  Value<String?> targetVenue,
  Value<DateTime?> submissionDeadline,
  Value<String?> keywords,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$ResearchPapersTableUpdateCompanionBuilder = ResearchPapersCompanion
    Function({
  Value<int> id,
  Value<String> title,
  Value<String?> abstractId,
  Value<String> status,
  Value<String?> coAuthors,
  Value<String?> paperLink,
  Value<int> citationCount,
  Value<int?> projectId,
  Value<String?> targetVenue,
  Value<DateTime?> submissionDeadline,
  Value<String?> keywords,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$ResearchPapersTableReferences extends BaseReferences<
    _$VelvetDatabase, $ResearchPapersTable, ResearchPaper> {
  $$ResearchPapersTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$VelvetDatabase db) =>
      db.projects.createAlias(
          $_aliasNameGenerator(db.researchPapers.projectId, db.projects.id));

  $$ProjectsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<int>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ResearchRevisionsTable, List<ResearchRevision>>
      _researchRevisionsRefsTable(_$VelvetDatabase db) =>
          MultiTypedResultKey.fromTable(db.researchRevisions,
              aliasName: $_aliasNameGenerator(
                  db.researchPapers.id, db.researchRevisions.paperId));

  $$ResearchRevisionsTableProcessedTableManager get researchRevisionsRefs {
    final manager =
        $$ResearchRevisionsTableTableManager($_db, $_db.researchRevisions)
            .filter((f) => f.paperId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_researchRevisionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ResearchPapersTableFilterComposer
    extends Composer<_$VelvetDatabase, $ResearchPapersTable> {
  $$ResearchPapersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get abstractId => $composableBuilder(
      column: $table.abstractId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coAuthors => $composableBuilder(
      column: $table.coAuthors, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paperLink => $composableBuilder(
      column: $table.paperLink, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get citationCount => $composableBuilder(
      column: $table.citationCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetVenue => $composableBuilder(
      column: $table.targetVenue, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get submissionDeadline => $composableBuilder(
      column: $table.submissionDeadline,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get keywords => $composableBuilder(
      column: $table.keywords, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableFilterComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> researchRevisionsRefs(
      Expression<bool> Function($$ResearchRevisionsTableFilterComposer f) f) {
    final $$ResearchRevisionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.researchRevisions,
        getReferencedColumn: (t) => t.paperId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ResearchRevisionsTableFilterComposer(
              $db: $db,
              $table: $db.researchRevisions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ResearchPapersTableOrderingComposer
    extends Composer<_$VelvetDatabase, $ResearchPapersTable> {
  $$ResearchPapersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get abstractId => $composableBuilder(
      column: $table.abstractId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coAuthors => $composableBuilder(
      column: $table.coAuthors, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paperLink => $composableBuilder(
      column: $table.paperLink, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get citationCount => $composableBuilder(
      column: $table.citationCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetVenue => $composableBuilder(
      column: $table.targetVenue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get submissionDeadline => $composableBuilder(
      column: $table.submissionDeadline,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get keywords => $composableBuilder(
      column: $table.keywords, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableOrderingComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ResearchPapersTableAnnotationComposer
    extends Composer<_$VelvetDatabase, $ResearchPapersTable> {
  $$ResearchPapersTableAnnotationComposer({
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

  GeneratedColumn<String> get abstractId => $composableBuilder(
      column: $table.abstractId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get coAuthors =>
      $composableBuilder(column: $table.coAuthors, builder: (column) => column);

  GeneratedColumn<String> get paperLink =>
      $composableBuilder(column: $table.paperLink, builder: (column) => column);

  GeneratedColumn<int> get citationCount => $composableBuilder(
      column: $table.citationCount, builder: (column) => column);

  GeneratedColumn<String> get targetVenue => $composableBuilder(
      column: $table.targetVenue, builder: (column) => column);

  GeneratedColumn<DateTime> get submissionDeadline => $composableBuilder(
      column: $table.submissionDeadline, builder: (column) => column);

  GeneratedColumn<String> get keywords =>
      $composableBuilder(column: $table.keywords, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> researchRevisionsRefs<T extends Object>(
      Expression<T> Function($$ResearchRevisionsTableAnnotationComposer a) f) {
    final $$ResearchRevisionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.researchRevisions,
            getReferencedColumn: (t) => t.paperId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ResearchRevisionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.researchRevisions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ResearchPapersTableTableManager extends RootTableManager<
    _$VelvetDatabase,
    $ResearchPapersTable,
    ResearchPaper,
    $$ResearchPapersTableFilterComposer,
    $$ResearchPapersTableOrderingComposer,
    $$ResearchPapersTableAnnotationComposer,
    $$ResearchPapersTableCreateCompanionBuilder,
    $$ResearchPapersTableUpdateCompanionBuilder,
    (ResearchPaper, $$ResearchPapersTableReferences),
    ResearchPaper,
    PrefetchHooks Function({bool projectId, bool researchRevisionsRefs})> {
  $$ResearchPapersTableTableManager(
      _$VelvetDatabase db, $ResearchPapersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResearchPapersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResearchPapersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResearchPapersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> abstractId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> coAuthors = const Value.absent(),
            Value<String?> paperLink = const Value.absent(),
            Value<int> citationCount = const Value.absent(),
            Value<int?> projectId = const Value.absent(),
            Value<String?> targetVenue = const Value.absent(),
            Value<DateTime?> submissionDeadline = const Value.absent(),
            Value<String?> keywords = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ResearchPapersCompanion(
            id: id,
            title: title,
            abstractId: abstractId,
            status: status,
            coAuthors: coAuthors,
            paperLink: paperLink,
            citationCount: citationCount,
            projectId: projectId,
            targetVenue: targetVenue,
            submissionDeadline: submissionDeadline,
            keywords: keywords,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<String?> abstractId = const Value.absent(),
            required String status,
            Value<String?> coAuthors = const Value.absent(),
            Value<String?> paperLink = const Value.absent(),
            Value<int> citationCount = const Value.absent(),
            Value<int?> projectId = const Value.absent(),
            Value<String?> targetVenue = const Value.absent(),
            Value<DateTime?> submissionDeadline = const Value.absent(),
            Value<String?> keywords = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ResearchPapersCompanion.insert(
            id: id,
            title: title,
            abstractId: abstractId,
            status: status,
            coAuthors: coAuthors,
            paperLink: paperLink,
            citationCount: citationCount,
            projectId: projectId,
            targetVenue: targetVenue,
            submissionDeadline: submissionDeadline,
            keywords: keywords,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ResearchPapersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {projectId = false, researchRevisionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (researchRevisionsRefs) db.researchRevisions
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
                      dynamic>>(state) {
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$ResearchPapersTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$ResearchPapersTableReferences._projectIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (researchRevisionsRefs)
                    await $_getPrefetchedData<ResearchPaper,
                            $ResearchPapersTable, ResearchRevision>(
                        currentTable: table,
                        referencedTable: $$ResearchPapersTableReferences
                            ._researchRevisionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ResearchPapersTableReferences(db, table, p0)
                                .researchRevisionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.paperId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ResearchPapersTableProcessedTableManager = ProcessedTableManager<
    _$VelvetDatabase,
    $ResearchPapersTable,
    ResearchPaper,
    $$ResearchPapersTableFilterComposer,
    $$ResearchPapersTableOrderingComposer,
    $$ResearchPapersTableAnnotationComposer,
    $$ResearchPapersTableCreateCompanionBuilder,
    $$ResearchPapersTableUpdateCompanionBuilder,
    (ResearchPaper, $$ResearchPapersTableReferences),
    ResearchPaper,
    PrefetchHooks Function({bool projectId, bool researchRevisionsRefs})>;
typedef $$ResearchRevisionsTableCreateCompanionBuilder
    = ResearchRevisionsCompanion Function({
  Value<int> id,
  required int paperId,
  required String note,
  Value<DateTime> createdAt,
});
typedef $$ResearchRevisionsTableUpdateCompanionBuilder
    = ResearchRevisionsCompanion Function({
  Value<int> id,
  Value<int> paperId,
  Value<String> note,
  Value<DateTime> createdAt,
});

final class $$ResearchRevisionsTableReferences extends BaseReferences<
    _$VelvetDatabase, $ResearchRevisionsTable, ResearchRevision> {
  $$ResearchRevisionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ResearchPapersTable _paperIdTable(_$VelvetDatabase db) =>
      db.researchPapers.createAlias($_aliasNameGenerator(
          db.researchRevisions.paperId, db.researchPapers.id));

  $$ResearchPapersTableProcessedTableManager get paperId {
    final $_column = $_itemColumn<int>('paper_id')!;

    final manager = $$ResearchPapersTableTableManager($_db, $_db.researchPapers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paperIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ResearchRevisionsTableFilterComposer
    extends Composer<_$VelvetDatabase, $ResearchRevisionsTable> {
  $$ResearchRevisionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ResearchPapersTableFilterComposer get paperId {
    final $$ResearchPapersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paperId,
        referencedTable: $db.researchPapers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ResearchPapersTableFilterComposer(
              $db: $db,
              $table: $db.researchPapers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ResearchRevisionsTableOrderingComposer
    extends Composer<_$VelvetDatabase, $ResearchRevisionsTable> {
  $$ResearchRevisionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ResearchPapersTableOrderingComposer get paperId {
    final $$ResearchPapersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paperId,
        referencedTable: $db.researchPapers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ResearchPapersTableOrderingComposer(
              $db: $db,
              $table: $db.researchPapers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ResearchRevisionsTableAnnotationComposer
    extends Composer<_$VelvetDatabase, $ResearchRevisionsTable> {
  $$ResearchRevisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ResearchPapersTableAnnotationComposer get paperId {
    final $$ResearchPapersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paperId,
        referencedTable: $db.researchPapers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ResearchPapersTableAnnotationComposer(
              $db: $db,
              $table: $db.researchPapers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ResearchRevisionsTableTableManager extends RootTableManager<
    _$VelvetDatabase,
    $ResearchRevisionsTable,
    ResearchRevision,
    $$ResearchRevisionsTableFilterComposer,
    $$ResearchRevisionsTableOrderingComposer,
    $$ResearchRevisionsTableAnnotationComposer,
    $$ResearchRevisionsTableCreateCompanionBuilder,
    $$ResearchRevisionsTableUpdateCompanionBuilder,
    (ResearchRevision, $$ResearchRevisionsTableReferences),
    ResearchRevision,
    PrefetchHooks Function({bool paperId})> {
  $$ResearchRevisionsTableTableManager(
      _$VelvetDatabase db, $ResearchRevisionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResearchRevisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResearchRevisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResearchRevisionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> paperId = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ResearchRevisionsCompanion(
            id: id,
            paperId: paperId,
            note: note,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int paperId,
            required String note,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ResearchRevisionsCompanion.insert(
            id: id,
            paperId: paperId,
            note: note,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ResearchRevisionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({paperId = false}) {
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
                      dynamic>>(state) {
                if (paperId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.paperId,
                    referencedTable:
                        $$ResearchRevisionsTableReferences._paperIdTable(db),
                    referencedColumn:
                        $$ResearchRevisionsTableReferences._paperIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ResearchRevisionsTableProcessedTableManager = ProcessedTableManager<
    _$VelvetDatabase,
    $ResearchRevisionsTable,
    ResearchRevision,
    $$ResearchRevisionsTableFilterComposer,
    $$ResearchRevisionsTableOrderingComposer,
    $$ResearchRevisionsTableAnnotationComposer,
    $$ResearchRevisionsTableCreateCompanionBuilder,
    $$ResearchRevisionsTableUpdateCompanionBuilder,
    (ResearchRevision, $$ResearchRevisionsTableReferences),
    ResearchRevision,
    PrefetchHooks Function({bool paperId})>;
typedef $$JobApplicationsTableCreateCompanionBuilder = JobApplicationsCompanion
    Function({
  Value<int> id,
  required String company,
  required String role,
  required String status,
  Value<String?> jdSnapshot,
  Value<String?> resumeVersion,
  Value<String?> coverLetter,
  Value<String?> outreachChannel,
  Value<DateTime?> followUpDate,
  Value<int?> projectId,
  Value<String?> salaryTarget,
  Value<String?> jobUrl,
  Value<String?> contactPerson,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$JobApplicationsTableUpdateCompanionBuilder = JobApplicationsCompanion
    Function({
  Value<int> id,
  Value<String> company,
  Value<String> role,
  Value<String> status,
  Value<String?> jdSnapshot,
  Value<String?> resumeVersion,
  Value<String?> coverLetter,
  Value<String?> outreachChannel,
  Value<DateTime?> followUpDate,
  Value<int?> projectId,
  Value<String?> salaryTarget,
  Value<String?> jobUrl,
  Value<String?> contactPerson,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$JobApplicationsTableReferences extends BaseReferences<
    _$VelvetDatabase, $JobApplicationsTable, JobApplication> {
  $$JobApplicationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$VelvetDatabase db) =>
      db.projects.createAlias(
          $_aliasNameGenerator(db.jobApplications.projectId, db.projects.id));

  $$ProjectsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<int>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$JobApplicationsTableFilterComposer
    extends Composer<_$VelvetDatabase, $JobApplicationsTable> {
  $$JobApplicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get company => $composableBuilder(
      column: $table.company, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jdSnapshot => $composableBuilder(
      column: $table.jdSnapshot, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resumeVersion => $composableBuilder(
      column: $table.resumeVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverLetter => $composableBuilder(
      column: $table.coverLetter, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get outreachChannel => $composableBuilder(
      column: $table.outreachChannel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get followUpDate => $composableBuilder(
      column: $table.followUpDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get salaryTarget => $composableBuilder(
      column: $table.salaryTarget, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jobUrl => $composableBuilder(
      column: $table.jobUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contactPerson => $composableBuilder(
      column: $table.contactPerson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableFilterComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$JobApplicationsTableOrderingComposer
    extends Composer<_$VelvetDatabase, $JobApplicationsTable> {
  $$JobApplicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get company => $composableBuilder(
      column: $table.company, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jdSnapshot => $composableBuilder(
      column: $table.jdSnapshot, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resumeVersion => $composableBuilder(
      column: $table.resumeVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverLetter => $composableBuilder(
      column: $table.coverLetter, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get outreachChannel => $composableBuilder(
      column: $table.outreachChannel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get followUpDate => $composableBuilder(
      column: $table.followUpDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get salaryTarget => $composableBuilder(
      column: $table.salaryTarget,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jobUrl => $composableBuilder(
      column: $table.jobUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contactPerson => $composableBuilder(
      column: $table.contactPerson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableOrderingComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$JobApplicationsTableAnnotationComposer
    extends Composer<_$VelvetDatabase, $JobApplicationsTable> {
  $$JobApplicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get jdSnapshot => $composableBuilder(
      column: $table.jdSnapshot, builder: (column) => column);

  GeneratedColumn<String> get resumeVersion => $composableBuilder(
      column: $table.resumeVersion, builder: (column) => column);

  GeneratedColumn<String> get coverLetter => $composableBuilder(
      column: $table.coverLetter, builder: (column) => column);

  GeneratedColumn<String> get outreachChannel => $composableBuilder(
      column: $table.outreachChannel, builder: (column) => column);

  GeneratedColumn<DateTime> get followUpDate => $composableBuilder(
      column: $table.followUpDate, builder: (column) => column);

  GeneratedColumn<String> get salaryTarget => $composableBuilder(
      column: $table.salaryTarget, builder: (column) => column);

  GeneratedColumn<String> get jobUrl =>
      $composableBuilder(column: $table.jobUrl, builder: (column) => column);

  GeneratedColumn<String> get contactPerson => $composableBuilder(
      column: $table.contactPerson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$JobApplicationsTableTableManager extends RootTableManager<
    _$VelvetDatabase,
    $JobApplicationsTable,
    JobApplication,
    $$JobApplicationsTableFilterComposer,
    $$JobApplicationsTableOrderingComposer,
    $$JobApplicationsTableAnnotationComposer,
    $$JobApplicationsTableCreateCompanionBuilder,
    $$JobApplicationsTableUpdateCompanionBuilder,
    (JobApplication, $$JobApplicationsTableReferences),
    JobApplication,
    PrefetchHooks Function({bool projectId})> {
  $$JobApplicationsTableTableManager(
      _$VelvetDatabase db, $JobApplicationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobApplicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobApplicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobApplicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> company = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> jdSnapshot = const Value.absent(),
            Value<String?> resumeVersion = const Value.absent(),
            Value<String?> coverLetter = const Value.absent(),
            Value<String?> outreachChannel = const Value.absent(),
            Value<DateTime?> followUpDate = const Value.absent(),
            Value<int?> projectId = const Value.absent(),
            Value<String?> salaryTarget = const Value.absent(),
            Value<String?> jobUrl = const Value.absent(),
            Value<String?> contactPerson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              JobApplicationsCompanion(
            id: id,
            company: company,
            role: role,
            status: status,
            jdSnapshot: jdSnapshot,
            resumeVersion: resumeVersion,
            coverLetter: coverLetter,
            outreachChannel: outreachChannel,
            followUpDate: followUpDate,
            projectId: projectId,
            salaryTarget: salaryTarget,
            jobUrl: jobUrl,
            contactPerson: contactPerson,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String company,
            required String role,
            required String status,
            Value<String?> jdSnapshot = const Value.absent(),
            Value<String?> resumeVersion = const Value.absent(),
            Value<String?> coverLetter = const Value.absent(),
            Value<String?> outreachChannel = const Value.absent(),
            Value<DateTime?> followUpDate = const Value.absent(),
            Value<int?> projectId = const Value.absent(),
            Value<String?> salaryTarget = const Value.absent(),
            Value<String?> jobUrl = const Value.absent(),
            Value<String?> contactPerson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              JobApplicationsCompanion.insert(
            id: id,
            company: company,
            role: role,
            status: status,
            jdSnapshot: jdSnapshot,
            resumeVersion: resumeVersion,
            coverLetter: coverLetter,
            outreachChannel: outreachChannel,
            followUpDate: followUpDate,
            projectId: projectId,
            salaryTarget: salaryTarget,
            jobUrl: jobUrl,
            contactPerson: contactPerson,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$JobApplicationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
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
                      dynamic>>(state) {
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$JobApplicationsTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$JobApplicationsTableReferences._projectIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$JobApplicationsTableProcessedTableManager = ProcessedTableManager<
    _$VelvetDatabase,
    $JobApplicationsTable,
    JobApplication,
    $$JobApplicationsTableFilterComposer,
    $$JobApplicationsTableOrderingComposer,
    $$JobApplicationsTableAnnotationComposer,
    $$JobApplicationsTableCreateCompanionBuilder,
    $$JobApplicationsTableUpdateCompanionBuilder,
    (JobApplication, $$JobApplicationsTableReferences),
    JobApplication,
    PrefetchHooks Function({bool projectId})>;

class $VelvetDatabaseManager {
  final _$VelvetDatabase _db;
  $VelvetDatabaseManager(this._db);
  $$IdeasTableTableManager get ideas =>
      $$IdeasTableTableManager(_db, _db.ideas);
  $$ActivityLogsTableTableManager get activityLogs =>
      $$ActivityLogsTableTableManager(_db, _db.activityLogs);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$ProjectTasksTableTableManager get projectTasks =>
      $$ProjectTasksTableTableManager(_db, _db.projectTasks);
  $$ResearchPapersTableTableManager get researchPapers =>
      $$ResearchPapersTableTableManager(_db, _db.researchPapers);
  $$ResearchRevisionsTableTableManager get researchRevisions =>
      $$ResearchRevisionsTableTableManager(_db, _db.researchRevisions);
  $$JobApplicationsTableTableManager get jobApplications =>
      $$JobApplicationsTableTableManager(_db, _db.jobApplications);
}
