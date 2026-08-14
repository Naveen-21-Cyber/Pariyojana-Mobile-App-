import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database.dart';
import '../../data/repositories/research_repository_impl.dart';
import '../../domain/repositories/research_repository.dart';

final researchRepositoryProvider = Provider<ResearchRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ResearchRepositoryImpl(db);
});

final researchPapersStreamProvider = StreamProvider<List<ResearchPaper>>((ref) {
  final repo = ref.watch(researchRepositoryProvider);
  return repo.watchPapers();
});

final researchRevisionsStreamProvider = StreamProvider.family<List<ResearchRevision>, int>((ref, paperId) {
  final repo = ref.watch(researchRepositoryProvider);
  return repo.watchRevisions(paperId);
});
