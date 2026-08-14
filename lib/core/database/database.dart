import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../security/auth_service.dart';

part 'database.g.dart';

class Ideas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text()();
  TextColumn get category => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isPromoted => boolean().withDefault(const Constant(false))();
}

class ActivityLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text()();
  TextColumn get description => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}

class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get techStack => text().nullable()();
  TextColumn get status => text()();
  TextColumn get priority => text()();
  TextColumn get tags => text().nullable()();
  IntColumn get originIdeaId => integer().nullable().references(Ideas, #id, onDelete: KeyAction.setNull)();

  TextColumn get storageOs => text().nullable()();
  TextColumn get storageDrive => text().nullable()();
  TextColumn get storagePath => text().nullable()();
  TextColumn get storageSubfoldersJson => text().nullable()();
  TextColumn get backupPath => text().nullable()();
  TextColumn get storageChecksum => text().nullable()();

  DateTimeColumn get deadline => dateTime().nullable()();
  TextColumn get repoUrl => text().nullable()();
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
}

class ProjectTasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer().references(Projects, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  List<Set<Column>> get indexes => [{projectId}];
}

class ResearchPapers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get abstractId => text().nullable()();
  TextColumn get status => text()();
  TextColumn get coAuthors => text().nullable()();
  TextColumn get paperLink => text().nullable()();
  IntColumn get citationCount => integer().withDefault(const Constant(0))();
  IntColumn get projectId => integer().nullable().references(Projects, #id, onDelete: KeyAction.setNull)();

  TextColumn get targetVenue => text().nullable()();
  DateTimeColumn get submissionDeadline => dateTime().nullable()();
  TextColumn get keywords => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  List<Set<Column>> get indexes => [{projectId}, {status}];
}

class ResearchRevisions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get paperId => integer().references(ResearchPapers, #id, onDelete: KeyAction.cascade)();
  TextColumn get note => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  List<Set<Column>> get indexes => [{paperId}];
}

class JobApplications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get company => text()();
  TextColumn get role => text()();
  TextColumn get status => text()();
  TextColumn get jdSnapshot => text().nullable()();
  TextColumn get resumeVersion => text().nullable()();
  TextColumn get coverLetter => text().nullable()();
  TextColumn get outreachChannel => text().nullable()();
  DateTimeColumn get followUpDate => dateTime().nullable()();
  IntColumn get projectId => integer().nullable().references(Projects, #id, onDelete: KeyAction.setNull)();

  TextColumn get salaryTarget => text().nullable()();
  TextColumn get jobUrl => text().nullable()();
  TextColumn get contactPerson => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  List<Set<Column>> get indexes => [{projectId}, {status}];
}

@DriftDatabase(tables: [Ideas, ActivityLogs, Projects, ProjectTasks, ResearchPapers, ResearchRevisions, JobApplications])
class VelvetDatabase extends _$VelvetDatabase {
  VelvetDatabase(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(projects, projects.description);
            await m.addColumn(projects, projects.techStack);
          }
          if (from < 3) {
            await m.addColumn(researchPapers, researchPapers.paperLink);
          }
          if (from < 4) {
            await m.database.customStatement('CREATE INDEX IF NOT EXISTS idx_projects_origin_idea ON projects (origin_idea_id);');
            await m.database.customStatement('CREATE INDEX IF NOT EXISTS idx_research_papers_project ON research_papers (project_id);');
            await m.database.customStatement('CREATE INDEX IF NOT EXISTS idx_job_applications_project ON job_applications (project_id);');
          }
          if (from < 5) {
            await m.addColumn(projects, projects.deadline);
            await m.addColumn(projects, projects.repoUrl);
            await m.addColumn(projects, projects.notes);

            await m.addColumn(researchPapers, researchPapers.targetVenue);
            await m.addColumn(researchPapers, researchPapers.submissionDeadline);
            await m.addColumn(researchPapers, researchPapers.keywords);

            await m.addColumn(jobApplications, jobApplications.salaryTarget);
            await m.addColumn(jobApplications, jobApplications.jobUrl);
            await m.addColumn(jobApplications, jobApplications.contactPerson);
          }
        },
      );
}

QueryExecutor openConnection(String hexKey) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File('${dbFolder.path}${Platform.pathSeparator}velvet.db');
    
    void applyKeyAndValidate(dynamic rawDb) {
      rawDb.execute("PRAGMA key = \"x'$hexKey'\";");
      try {
        rawDb.select('PRAGMA user_version;');
      } catch (_) {
        rethrow;
      }
    }

    try {
      if (file.existsSync()) {
        // Probe test key validity
        final testDb = NativeDatabase(file, setup: applyKeyAndValidate);
        final dummy = VelvetDatabase(testDb);
        await testDb.ensureOpen(dummy);
        await dummy.close();
      }
      return NativeDatabase(file, setup: applyKeyAndValidate);
    } catch (e) {
      if (file.existsSync()) {
        try {
          file.deleteSync();
        } catch (_) {}
      }
      return NativeDatabase(file, setup: applyKeyAndValidate);
    }
  });
}

final databaseProvider = Provider<VelvetDatabase>((ref) {
  final hexKey = ref.watch(decryptedDbKeyProvider);
  if (hexKey == null) {
    throw StateError('Database is locked. Secure key not decrypted.');
  }
  
  final conn = openConnection(hexKey);
  final db = VelvetDatabase(conn);
  
  ref.onDispose(() async {
    await db.close();
  });
  
  return db;
});
