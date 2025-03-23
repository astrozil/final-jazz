import 'package:jazz/features/playlist_feature/domain/repositories/playlist_repo.dart';


class RemoveSongFromPlaylistUseCase {
  final PlaylistRepo _playlistRepo;

  RemoveSongFromPlaylistUseCase({
    required PlaylistRepo playlistRepo
  }): _playlistRepo = playlistRepo;

  Future<void> call(String songId,String playlistId)async{
   await  _playlistRepo.removeSongFromPlaylist(songId,playlistId);
  }
}