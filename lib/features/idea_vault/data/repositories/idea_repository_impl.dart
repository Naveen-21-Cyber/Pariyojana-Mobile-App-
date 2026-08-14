import '../../../../core/database/database.dart';
import '../../domain/repositories/idea_repository.dart';

class IdeaRepositoryImpl implements IdeaRepository {
  final VelvetDatabase _db;

  IdeaRepositoryImpl(this._db);

  @override
  Stream<List<Idea>> watchIdeas() {
    return _db.select(_db.ideas).watch();
  }

  @override
  Future<int> insertIdea(IdeasCompanion idea) {
    return _db.into(_db.ideas).insert(idea);
  }

  @override
  Future<bool> updateIdea(Idea idea) {
    return _db.update(_db.ideas).replace(idea);
  }

  @override
  Future<bool> deleteIdea(int id) {
    return (_db.delete(_db.ideas)..where((tbl) => tbl.id.equals(id)))
        .go()
        .then((count) => count > 0);
  }
}
