import 'package:jazz/features/playlist_feature/domain/repositories/playlist_repo.dart';


class FetchPlaylistUseCase {
  final PlaylistRepo _playlistRepo;

  FetchPlaylistUseCase({
    required PlaylistRepo playlistRepo
  }): _playlistRepo = playlistRepo;

  Future<Map?> call(String playlistId)async{
    return  _playlistRepo.fetchPlaylist(playlistId);
  }
}