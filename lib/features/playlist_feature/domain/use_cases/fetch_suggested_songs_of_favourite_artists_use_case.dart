import 'package:jazz/features/playlist_feature/domain/entities/billboard_song.dart';
import 'package:jazz/features/playlist_feature/domain/repositories/playlist_repo.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';


class FetchSuggestedSongsOfFavouriteArtistsUseCase {
  final PlaylistRepo _playlistRepo;

  FetchSuggestedSongsOfFavouriteArtistsUseCase({
    required PlaylistRepo playlistRepo
  }): _playlistRepo = playlistRepo;

  Future<List<RelatedSong>> call(String artistIds){
    return _playlistRepo.fetchSuggestedSongsOfFavouriteArtists(artistIds);
  }
}