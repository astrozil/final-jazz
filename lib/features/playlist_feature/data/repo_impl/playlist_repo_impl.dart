import 'package:jazz/features/playlist_feature/data/data_source/billboard_data_source.dart';
import 'package:jazz/features/playlist_feature/data/data_source/favourite_playlist_data_source.dart';
import 'package:jazz/features/playlist_feature/data/data_source/recommendation_songs_playlist_data_source.dart';
import 'package:jazz/features/playlist_feature/data/data_source/suggested_songs_of_favourite_artists.dart';
import 'package:jazz/features/playlist_feature/data/data_source/trending_data_source.dart';
import 'package:jazz/features/playlist_feature/data/data_source/user_playlist_data_source.dart';
import 'package:jazz/features/playlist_feature/domain/entities/billboard_song.dart';
import 'package:jazz/features/playlist_feature/domain/repositories/playlist_repo.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';

class PlaylistRepoImpl extends PlaylistRepo{
  final TrendingDataSource _trendingDataSource;
  final BillboardDataSource _billboardDataSource;
  final SuggestedSongsOfFavouriteArtistsDataSource _suggestedSongsOfFavouriteArtistsDataSource;
  final FavouritePlaylistDataSource _favouritePlaylistDataSource;
  final UserPlaylistDataSource _userPlaylistDataSource;
  final RecommendationSongsPlaylistDataSource _recommendationSongsPlaylistDataSource;

  PlaylistRepoImpl({
   required TrendingDataSource trendingDataSource,
    required BillboardDataSource billboardDataSource,
    required SuggestedSongsOfFavouriteArtistsDataSource suggestedSongsOfFavouriteArtistsDataSource,
    required FavouritePlaylistDataSource favouritePlaylistDataSource,
    required UserPlaylistDataSource userPlaylistDataSource,
    required RecommendationSongsPlaylistDataSource recommendationSongsPlaylistDataSource
}): _trendingDataSource = trendingDataSource,
  _billboardDataSource = billboardDataSource,
  _suggestedSongsOfFavouriteArtistsDataSource = suggestedSongsOfFavouriteArtistsDataSource,
  _favouritePlaylistDataSource = favouritePlaylistDataSource,
  _userPlaylistDataSource = userPlaylistDataSource,
  _recommendationSongsPlaylistDataSource = recommendationSongsPlaylistDataSource;
  @override
  Future<List<RelatedSong>> fetchTrendingSongsPlaylist() {
    return _trendingDataSource.fetchTrendingSongs();
  }

  @override
  Future<List<BillboardSong>> fetchBillboardSongsPlaylist() {
return _billboardDataSource.fetchBillboardSongs();
  }

  @override
  Future<List<RelatedSong>> fetchSuggestedSongsOfFavouriteArtists(String artistIds) {
    return _suggestedSongsOfFavouriteArtistsDataSource.fetchMixSongs(artistIds: artistIds);
  }

  @override
  Future<void> addFavouriteSong(String songId) {
    return _favouritePlaylistDataSource.addFavouriteSong(songId);
  }

  @override
  Future<void> removeFavouriteSong(String songId) {
    return _favouritePlaylistDataSource.removeFavouriteSong(songId);
  }

  @override
  Future<List<RelatedSong>> fetchFavouriteSongsPlaylist(List songIds)async {
  return _favouritePlaylistDataSource.fetchFavouriteSongs(songIds);
  }

  @override
  Future<void> addSongToPlaylist(String songId, String playlistId)async {
    await _userPlaylistDataSource.addSongToPlaylist(songId, playlistId);
  }

  @override
  Future<void> changePlaylistTitle(String title, String playlistId)async {
   await _userPlaylistDataSource.changePlaylistTitle(title, playlistId);
  }

  @override
  Future<void> createPlaylist(String title)async{
    await _userPlaylistDataSource.createPlaylist(title);
  }

  @override
  Future<void> deletePlaylist(String playlistId) async{
    await _userPlaylistDataSource.deletePlaylist(playlistId);
  }

  @override
  Future<List<Map>?> fetchPlaylists()async {
    return  _userPlaylistDataSource.fetchPlaylists();
  }

  @override
  Future<void> removeSongFromPlaylist(String songId, String playlistId) async{
    await _userPlaylistDataSource.removeSongFromPlaylist(songId, playlistId);
  }

  @override
  Future<Map?> fetchPlaylist(String playlistId) {
   return _userPlaylistDataSource.fetchPlaylist(playlistId);
  }

  @override
  Future<List<RelatedSong>> fetchRecommendedSongsPlaylist() {
    return _recommendationSongsPlaylistDataSource.fetchRecommendedSongs();
  }

}