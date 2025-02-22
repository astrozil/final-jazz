import 'package:dartz/dartz.dart';
import 'package:jazz/core/failure/failure.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';

import 'package:jazz/features/stream_feature/domain/repositories/streamRepository.dart';

class GetRelatedSongUseCase {
  final StreamRepository repository;

  GetRelatedSongUseCase(this.repository);

  Future<Either<Failure,List<RelatedSong>?>> call(String videoId,List<RelatedSong> relatedSongsList) async {
    try{

      final result = await repository.getRelatedSong(videoId,relatedSongsList);
      return Right(result);
    }catch(e){
      return Left(ServerFailure("Sever Failure: $e"));
    }
  }
}