import '../../../../core/database/database.dart';

abstract class ResearchRepository {
  Stream<List<ResearchPaper>> watchPapers();
  Stream<List<ResearchPaper>> watchPapersForProject(int projectId);
  Future<ResearchPaper?> getPaper(int id);
  Future<int> insertPaper(ResearchPapersCompanion paper);
  Future<bool> updatePaper(ResearchPaper paper);
  Future<bool> deletePaper(int id);

  Stream<List<ResearchRevision>> watchRevisions(int paperId);
  Future<int> insertRevision(ResearchRevisionsCompanion revision);
}
