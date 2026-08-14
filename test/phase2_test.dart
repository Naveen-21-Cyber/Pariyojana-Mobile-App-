import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:velvet/core/database/database.dart';
import 'package:velvet/features/idea_vault/data/repositories/idea_repository_impl.dart';
import 'package:velvet/features/idea_vault/domain/repositories/idea_repository.dart';
import 'package:velvet/features/project_tracker/data/repositories/project_repository_impl.dart';
import 'package:velvet/features/project_tracker/domain/repositories/project_repository.dart';

void main() {
  late VelvetDatabase db;
  late IdeaRepository ideaRepo;
  late ProjectRepository projectRepo;

  setUp(() {
    // Open in-memory NativeDatabase for testing database queries
    db = VelvetDatabase(NativeDatabase.memory());
    ideaRepo = IdeaRepositoryImpl(db);
    projectRepo = ProjectRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('IdeaRepository CRUD Tests', () {
    test('Can insert, watch, update, and delete ideas', () async {
      // 1. Initial empty state
      var ideas = await ideaRepo.watchIdeas().first;
      expect(ideas.isEmpty, true);

      // 2. Insert idea
      final id = await ideaRepo.insertIdea(
        IdeasCompanion.insert(
          content: 'Test Capture',
          category: 'Project',
        ),
      );
      expect(id > 0, true);

      ideas = await ideaRepo.watchIdeas().first;
      expect(ideas.length, 1);
      expect(ideas.first.content, 'Test Capture');
      expect(ideas.first.category, 'Project');
      expect(ideas.first.isPromoted, false);

      // 3. Update idea (mark as promoted)
      final idea = ideas.first;
      final updated = idea.copyWith(isPromoted: true);
      final updatedSuccess = await ideaRepo.updateIdea(updated);
      expect(updatedSuccess, true);

      ideas = await ideaRepo.watchIdeas().first;
      expect(ideas.first.isPromoted, true);

      // 4. Delete idea
      final deleteSuccess = await ideaRepo.deleteIdea(idea.id);
      expect(deleteSuccess, true);

      ideas = await ideaRepo.watchIdeas().first;
      expect(ideas.isEmpty, true);
    });
  });

  group('ProjectRepository & Subtask Checklist Tests', () {
    test('Can insert, update projects, and manage checklists', () async {
      // 1. Insert Project
      final projectId = await projectRepo.insertProject(
        ProjectsCompanion.insert(
          name: 'Command Center App',
          status: 'Active',
          priority: 'High',
        ),
      );
      expect(projectId > 0, true);

      var project = await projectRepo.getProject(projectId);
      expect(project != null, true);
      expect(project!.name, 'Command Center App');
      expect(project.status, 'Active');

      // 2. Manage checklist tasks
      var tasks = await projectRepo.watchProjectTasks(projectId).first;
      expect(tasks.isEmpty, true);

      final taskId = await projectRepo.insertProjectTask(
        ProjectTasksCompanion.insert(
          projectId: projectId,
          title: 'Implement Local Encryption',
        ),
      );
      expect(taskId > 0, true);

      tasks = await projectRepo.watchProjectTasks(projectId).first;
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Implement Local Encryption');
      expect(tasks.first.isCompleted, false);

      // Complete task
      final task = tasks.first;
      final completedTask = task.copyWith(isCompleted: true);
      final updateSuccess = await projectRepo.updateProjectTask(completedTask);
      expect(updateSuccess, true);

      tasks = await projectRepo.watchProjectTasks(projectId).first;
      expect(tasks.first.isCompleted, true);

      // Delete task
      final deleteSuccess = await projectRepo.deleteProjectTask(task.id);
      expect(deleteSuccess, true);

      tasks = await projectRepo.watchProjectTasks(projectId).first;
      expect(tasks.isEmpty, true);
    });
  });

  group('Project Folder Integrity Checksum Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('velvet_checksum_test');
    });

    tearDown(() async {
      try {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      } catch (_) {}
    });

    test('Can calculate, verify, and detect filesystem changes', () async {
      // 1. Create file assets in temp directory
      final fileA = File('${tempDir.path}/a.txt');
      await fileA.writeAsString('Hello A');

      final fileB = File('${tempDir.path}/b.txt');
      await fileB.writeAsString('Hello B');

      // 2. Create Project linked to this path
      final projectId = await projectRepo.insertProject(
        ProjectsCompanion.insert(
          name: 'Tracked Folder',
          status: 'Active',
          priority: 'Medium',
          storagePath: drift.Value(tempDir.path),
        ),
      );

      // Checksum is initially empty/null
      var project = await projectRepo.getProject(projectId);
      expect(project!.storageChecksum, null);

      // 3. Compute and sync initial checksum
      await projectRepo.recalculateAndSaveChecksum(projectId);

      project = await projectRepo.getProject(projectId);
      final initialHash = project!.storageChecksum;
      expect(initialHash != null, true);
      expect(initialHash!.isNotEmpty, true);
      expect(project.lastSyncedAt != null, true);

      // Verify integrity matches
      var matches = await projectRepo.verifyProjectIntegrity(projectId);
      expect(matches, true);

      // 4. Modify a file (change its contents and size)
      await fileA.writeAsString('Hello A Changed');

      // Verify integrity should now mismatch/fail
      matches = await projectRepo.verifyProjectIntegrity(projectId);
      expect(matches, false);

      // 5. Sync again to accept changes
      await projectRepo.recalculateAndSaveChecksum(projectId);
      project = await projectRepo.getProject(projectId);
      expect(project!.storageChecksum != initialHash, true);

      // Verify integrity matches new hash
      matches = await projectRepo.verifyProjectIntegrity(projectId);
      expect(matches, true);

      // 6. Delete a file
      await fileB.delete();

      // Verify integrity mismatch
      matches = await projectRepo.verifyProjectIntegrity(projectId);
      expect(matches, false);
    });
  });
}
