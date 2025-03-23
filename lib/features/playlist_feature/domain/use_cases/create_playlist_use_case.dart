import 'package:jazz/features/playlist_feature/domain/repositories/playlist_repo.dart';


class CreatePlaylistUseCase {
  final PlaylistRepo _playlistRepo;

  CreatePlaylistUseCase({
    required PlaylistRepo playlistRepo
  }): _playlistRepo = playlistRepo;

  Future<void> call(String title)async{
    await  _playlistRepo.createPlaylist(title);
  }
}