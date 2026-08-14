import '../../../../core/database/database.dart';

abstract class ProjectRepository {
  Stream<List<Project>> watchProjects();
  Future<Project?> getProject(int id);
  Future<int> insertProject(ProjectsCompanion project);
  Future<bool> updateProject(Project project);
  Future<bool> deleteProject(int id);

  Stream<List<ProjectTask>> watchProjectTasks(int projectId);
  Future<int> insertProjectTask(ProjectTasksCompanion task);
  Future<bool> updateProjectTask(ProjectTask task);
  Future<bool> deleteProjectTask(int id);

  Future<bool> verifyProjectIntegrity(int projectId);
  Future<void> recalculateAndSaveChecksum(int projectId);
}
