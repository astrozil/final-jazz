import 'package:jazz/features/playlist_feature/domain/entities/billboard_song.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';

abstract class PlaylistRepo {
  Future<List<RelatedSong>> fetchTrendingSongsPlaylist();
  Future<List<BillboardSong>> fetchBillboardSongsPlaylist();
  Future<List<RelatedSong>>  fetchSuggestedSongsOfFavouriteArtists(String artistIds);
  Future<List<RelatedSong>> fetchFavouriteSongsPlaylist(List<String> songIds);
  Future<void> createPlaylist(String title);
  Future<void> deletePlaylist(String playlistId);
  Future<List<Map>?> fetchPlaylists();
  Future<void> changePlaylistTitle(String title, String playlistId);
  Future<void> addSongToPlaylist(String songId, String playlistId);
  Future<void> removeSongFromPlaylist(String songId, String playlistId);
  Future<void> addFavouriteSong(String songId);
  Future<void> removeFavouriteSong(String songId);

 }