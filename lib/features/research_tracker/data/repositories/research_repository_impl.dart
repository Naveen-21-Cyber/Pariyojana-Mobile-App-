import 'package:drift/drift.dart';
import '../../../../core/database/database.dart';
import '../../domain/repositories/research_repository.dart';

class ResearchRepositoryImpl implements ResearchRepository {
  final VelvetDatabase _db;

  ResearchRepositoryImpl(this._db);

  @override
  Stream<List<ResearchPaper>> watchPapers() {
    return _db.select(_db.researchPapers).watch();
  }

  @override
  Stream<List<ResearchPaper>> watchPapersForProject(int projectId) {
    return (_db.select(_db.researchPapers)
          ..where((tbl) => tbl.projectId.equals(projectId)))
        .watch();
  }

  @override
  Future<ResearchPaper?> getPaper(int id) {
    return (_db.select(_db.researchPapers)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  @override
  Future<int> insertPaper(ResearchPapersCompanion paper) {
    return _db.into(_db.researchPapers).insert(paper);
  }

  @override
  Future<bool> updatePaper(ResearchPaper paper) {
    final withUpdatedTime = paper.copyWith(updatedAt: DateTime.now());
    return _db.update(_db.researchPapers).replace(withUpdatedTime);
  }

  @override
  Future<bool> deletePaper(int id) {
    return (_db.delete(_db.researchPapers)..where((tbl) => tbl.id.equals(id)))
        .go()
        .then((count) => count > 0);
  }

  @override
  Stream<List<ResearchRevision>> watchRevisions(int paperId) {
    return (_db.select(_db.researchRevisions)
          ..where((tbl) => tbl.paperId.equals(paperId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch();
  }

  @override
  Future<int> insertRevision(ResearchRevisionsCompanion revision) {
    return _db.into(_db.researchRevisions).insert(revision);
  }
}
