import 'package:jazz/features/playlist_feature/domain/repositories/playlist_repo.dart';


class RemoveFavouriteSongUseCase {
  final PlaylistRepo _playlistRepo;

  RemoveFavouriteSongUseCase({
    required PlaylistRepo playlistRepo
  }): _playlistRepo = playlistRepo;

  Future<void> call(String songId){
    return _playlistRepo.removeFavouriteSong(songId);
  }
}