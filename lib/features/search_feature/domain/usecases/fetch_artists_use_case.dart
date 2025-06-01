import 'package:jazz/features/search_feature/domain/repositories/song_repository.dart';

class FetchArtistsUseCase{
  final SongRepository songRepository;

  FetchArtistsUseCase({required this.songRepository});

  Future<List> call(List<String> artistIdList)async{
    return songRepository.fetchArtists(artistIdList);
  }
}