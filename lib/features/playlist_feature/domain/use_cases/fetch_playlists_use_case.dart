import 'package:jazz/features/playlist_feature/domain/repositories/playlist_repo.dart';


class FetchPlaylistsUseCase {
  final PlaylistRepo _playlistRepo;

  FetchPlaylistsUseCase({
    required PlaylistRepo playlistRepo
  }): _playlistRepo = playlistRepo;

  Future<List<Map>?> call()async{
    return  _playlistRepo.fetchPlaylists();
  }
}