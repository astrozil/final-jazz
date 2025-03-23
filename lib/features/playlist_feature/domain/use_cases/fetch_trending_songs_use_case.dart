import 'package:jazz/features/playlist_feature/domain/repositories/playlist_repo.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';

class FetchTrendingSongsUseCase {
  final PlaylistRepo _playlistRepo;

  FetchTrendingSongsUseCase({
    required PlaylistRepo playlistRepo
}): _playlistRepo = playlistRepo;

  Future<List<RelatedSong>> call(){
    return _playlistRepo.fetchTrendingSongsPlaylist();
  }
}