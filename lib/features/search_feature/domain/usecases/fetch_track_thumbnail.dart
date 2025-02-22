import 'package:dartz/dartz.dart';
import 'package:jazz/core/failure/failure.dart';
import 'package:jazz/features/search_feature/domain/entities/thumbnails.dart';
import 'package:jazz/features/search_feature/domain/repositories/song_repository.dart';

class FetchTrackThumbnailUseCase{
  final SongRepository songRepository;

  FetchTrackThumbnailUseCase({required this.songRepository});

  Future<Either<Failure,YtThumbnail>> call(String songId){
    return songRepository.fetchTrackThumbnail(songId);
  }

}