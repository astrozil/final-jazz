import 'package:dartz/dartz.dart';
import 'package:jazz/core/failure/failure.dart';
import 'package:jazz/features/search_feature/domain/entities/album.dart';
import 'package:jazz/features/search_feature/domain/repositories/song_repository.dart';

class SearchAlbumUseCase{
  final SongRepository songRepository;
  SearchAlbumUseCase({required this.songRepository});

  Future<Either<Failure,Album>> call(String albumId){
   return  songRepository.searchAlbum(albumId);
  }
}