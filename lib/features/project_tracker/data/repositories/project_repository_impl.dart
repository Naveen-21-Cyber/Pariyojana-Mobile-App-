import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:pointycastle/digests/sha256.dart';
import '../../../../core/database/database.dart';
import '../../domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final VelvetDatabase _db;

  ProjectRepositoryImpl(this._db);

  @override
  Stream<List<Project>> watchProjects() {
    return _db.select(_db.projects).watch();
  }

  @override
  Future<Project?> getProject(int id) {
    return (_db.select(_db.projects)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  @override
  Future<int> insertProject(ProjectsCompanion project) {
    return _db.into(_db.projects).insert(project);
  }

  @override
  Future<bool> updateProject(Project project) {
    return _db.update(_db.projects).replace(project);
  }

  @override
  Future<bool> deleteProject(int id) {
    return (_db.delete(_db.projects)..where((tbl) => tbl.id.equals(id)))
        .go()
        .then((count) => count > 0);
  }

  @override
  Stream<List<ProjectTask>> watchProjectTasks(int projectId) {
    return (_db.select(_db.projectTasks)
          ..where((tbl) => tbl.projectId.equals(projectId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
        .watch();
  }

  @override
  Future<int> insertProjectTask(ProjectTasksCompanion task) {
    return _db.into(_db.projectTasks).insert(task);
  }

  @override
  Future<bool> updateProjectTask(ProjectTask task) {
    return _db.update(_db.projectTasks).replace(task);
  }

  @override
  Future<bool> deleteProjectTask(int id) {
    return (_db.delete(_db.projectTasks)..where((tbl) => tbl.id.equals(id)))
        .go()
        .then((count) => count > 0);
  }

  @override
  Future<bool> verifyProjectIntegrity(int projectId) async {
    final project = await getProject(projectId);
    if (project == null) return false;
    final path = project.storagePath;
    if (path == null || path.isEmpty) return true;

    final dir = Directory(path);
    if (!dir.existsSync()) return false;

    final calculated = _calculateDirectoryChecksum(dir);
    return calculated == project.storageChecksum;
  }

  @override
  Future<void> recalculateAndSaveChecksum(int projectId) async {
    final project = await getProject(projectId);
    if (project == null) return;
    final path = project.storagePath;
    if (path == null || path.isEmpty) return;

    final dir = Directory(path);
    if (!dir.existsSync()) return;

    final calculated = _calculateDirectoryChecksum(dir);
    
    // In Drift, copyWith accepts standard types or Value wrapping depending on configuration,
    // but the generated class copyWith handles it as nullable standard types.
    final updated = project.copyWith(
      storageChecksum: Value(calculated),
      lastSyncedAt: Value(DateTime.now()),
    );
    await updateProject(updated);
  }

  String _calculateDirectoryChecksum(Directory dir) {
    try {
      final entries = dir.listSync(recursive: true).whereType<File>().toList();
      entries.sort((a, b) => a.path.compareTo(b.path));

      final buffer = StringBuffer();
      for (final file in entries) {
        final stat = file.statSync();
        final relativePath = file.path.replaceFirst(dir.path, '');
        buffer.write('$relativePath:${stat.size}:${stat.modified.millisecondsSinceEpoch};');
      }

      final bytes = utf8.encode(buffer.toString());
      final digest = SHA256Digest().process(Uint8List.fromList(bytes));
      return base64.encode(digest);
    } catch (_) {
      return '';
    }
  }
}
