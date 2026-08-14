import '../../../../core/database/database.dart';

abstract class JobRepository {
  Stream<List<JobApplication>> watchApplications();
  Stream<List<JobApplication>> watchApplicationsForProject(int projectId);
  Future<JobApplication?> getApplication(int id);
  Future<int> insertApplication(JobApplicationsCompanion application);
  Future<bool> updateApplication(JobApplication application);
  Future<bool> deleteApplication(int id);
}
