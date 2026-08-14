import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database.dart';
import '../../data/repositories/job_repository_impl.dart';
import '../../domain/repositories/job_repository.dart';

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return JobRepositoryImpl(db);
});

final jobApplicationsStreamProvider = StreamProvider<List<JobApplication>>((ref) {
  final repo = ref.watch(jobRepositoryProvider);
  return repo.watchApplications();
});
