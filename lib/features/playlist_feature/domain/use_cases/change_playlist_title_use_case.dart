import 'package:jazz/features/playlist_feature/domain/repositories/playlist_repo.dart';


class ChangePlaylistTitleUseCase {
  final PlaylistRepo _playlistRepo;

  ChangePlaylistTitleUseCase({
    required PlaylistRepo playlistRepo
  }): _playlistRepo = playlistRepo;

  Future<void> call(String title,String playlistId)async{
    await  _playlistRepo.changePlaylistTitle(title,playlistId);
  }
}