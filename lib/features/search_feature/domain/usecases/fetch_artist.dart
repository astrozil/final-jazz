

import 'package:jazz/features/search_feature/domain/entities/artist.dart';
import 'package:jazz/features/search_feature/domain/repositories/song_repository.dart';

class FetchArtistUseCase{
  final SongRepository songRepository;
  FetchArtistUseCase({required this.songRepository});

  Future<Artist> call(String artistId){
    return  songRepository.fetchArtist(artistId);
  }
}