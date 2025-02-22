import 'package:dartz/dartz.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import '../../../../core/failure/failure.dart';

import '../repositories/song_repository.dart';

class Search {
  final SongRepository repository;

  Search(this.repository);

  Future<Either<Failure, List<Song>?>> call(String query) async {

    try {
      final songs = await repository.search(query);
      return Right(songs);
    } catch (e) {
      return Left(ServerFailure("Failed to fetch songs, ${e.toString()}"));
    }
  }
}
