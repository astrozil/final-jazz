import 'package:jazz/features/playlist_feature/domain/repositories/playlist_repo.dart';


class DeletePlaylistUseCase {
  final PlaylistRepo _playlistRepo;

  DeletePlaylistUseCase({
    required PlaylistRepo playlistRepo
  }): _playlistRepo = playlistRepo;

  Future<void> call(String playlistId)async{
    await  _playlistRepo.deletePlaylist(playlistId);
  }
}