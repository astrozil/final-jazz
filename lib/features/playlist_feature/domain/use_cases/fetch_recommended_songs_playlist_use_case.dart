import 'package:jazz/features/playlist_feature/domain/repositories/playlist_repo.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';


class FetchRecommendedSongsPlaylistUseCase {
  final PlaylistRepo _playlistRepo;

  FetchRecommendedSongsPlaylistUseCase({
    required PlaylistRepo playlistRepo
  }): _playlistRepo = playlistRepo;

  Future<List<RelatedSong>> call(){
    return _playlistRepo.fetchRecommendedSongsPlaylist();
  }
}