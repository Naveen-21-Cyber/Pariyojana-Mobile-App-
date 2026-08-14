import '../../../../core/database/database.dart';
import '../../domain/repositories/job_repository.dart';

class JobRepositoryImpl implements JobRepository {
  final VelvetDatabase _db;

  JobRepositoryImpl(this._db);

  @override
  Stream<List<JobApplication>> watchApplications() {
    return _db.select(_db.jobApplications).watch();
  }

  @override
  Stream<List<JobApplication>> watchApplicationsForProject(int projectId) {
    return (_db.select(_db.jobApplications)
          ..where((tbl) => tbl.projectId.equals(projectId)))
        .watch();
  }

  @override
  Future<JobApplication?> getApplication(int id) {
    return (_db.select(_db.jobApplications)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  @override
  Future<int> insertApplication(JobApplicationsCompanion application) {
    return _db.into(_db.jobApplications).insert(application);
  }

  @override
  Future<bool> updateApplication(JobApplication application) {
    final withUpdatedTime = application.copyWith(updatedAt: DateTime.now());
    return _db.update(_db.jobApplications).replace(withUpdatedTime);
  }

  @override
  Future<bool> deleteApplication(int id) {
    return (_db.delete(_db.jobApplications)..where((tbl) => tbl.id.equals(id)))
        .go()
        .then((count) => count > 0);
  }
}
