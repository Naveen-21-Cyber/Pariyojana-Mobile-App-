import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../domain/repositories/project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ProjectRepositoryImpl(db);
});

final projectsStreamProvider = StreamProvider<List<Project>>((ref) {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.watchProjects();
});

final projectTasksStreamProvider = StreamProvider.family<List<ProjectTask>, int>((ref, projectId) {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.watchProjectTasks(projectId);
});
