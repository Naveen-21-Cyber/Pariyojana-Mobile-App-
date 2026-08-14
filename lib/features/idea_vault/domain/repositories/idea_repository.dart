import '../../../../core/database/database.dart';

abstract class IdeaRepository {
  Stream<List<Idea>> watchIdeas();
  Future<int> insertIdea(IdeasCompanion idea);
  Future<bool> updateIdea(Idea idea);
  Future<bool> deleteIdea(int id);
}
