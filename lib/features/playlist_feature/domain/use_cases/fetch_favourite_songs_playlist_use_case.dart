import 'package:jazz/features/playlist_feature/domain/repositories/playlist_repo.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';


class FetchFavouriteSongsPlaylistUseCase {
  final PlaylistRepo _playlistRepo;

  FetchFavouriteSongsPlaylistUseCase({
    required PlaylistRepo playlistRepo
  }): _playlistRepo = playlistRepo;

  Future<List<RelatedSong>> call(List<String> songIds){
    return _playlistRepo.fetchFavouriteSongsPlaylist(songIds);
  }
}