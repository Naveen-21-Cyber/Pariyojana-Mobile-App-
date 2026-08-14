import 'package:flutter_riverpod/flutter_riverpod.dart';
   import '../../../../core/database/database.dart';
   import '../../data/repositories/idea_repository_impl.dart';
   import '../../domain/repositories/idea_repository.dart';

   final ideaRepositoryProvider = Provider<IdeaRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return IdeaRepositoryImpl(db);
});

   final ideasStreamProvider = StreamProvider<List<Idea>>((ref) {
     final repo = ref.watch(ideaRepositoryProvider);
     return repo.watchIdeas();
   });
   
