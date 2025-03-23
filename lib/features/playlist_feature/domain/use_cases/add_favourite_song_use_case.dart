import 'package:jazz/features/playlist_feature/domain/repositories/playlist_repo.dart';


class AddFavouriteSongUseCase {
  final PlaylistRepo _playlistRepo;

  AddFavouriteSongUseCase({
    required PlaylistRepo playlistRepo
  }): _playlistRepo = playlistRepo;

  Future<void> call(String songId){
    return _playlistRepo.addFavouriteSong(songId);
  }
}