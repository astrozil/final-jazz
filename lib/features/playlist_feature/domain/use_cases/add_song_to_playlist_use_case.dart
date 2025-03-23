import 'package:jazz/features/playlist_feature/domain/repositories/playlist_repo.dart';


class AddSongToPlaylistUseCase {
  final PlaylistRepo _playlistRepo;

  AddSongToPlaylistUseCase({
    required PlaylistRepo playlistRepo
  }): _playlistRepo = playlistRepo;

  Future<void> call(String songId,String playlistId)async{
    await  _playlistRepo.addSongToPlaylist(songId,playlistId);
  }
}