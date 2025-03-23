part of 'playlist_bloc.dart';

@immutable
sealed class PlaylistState {}

final class PlaylistInitial extends PlaylistState {}

final class PlaylistLoaded extends PlaylistState {
  final List<RelatedSong> trendingSongsPlaylist;
  final List<BillboardSong> billboardSongsPlaylist;
  final List<RelatedSong> suggestedSongsOfFavouriteArtists;
  final List<RelatedSong> favouriteSongsPlaylist;
  final List<Map> userPlaylists;
  final bool hasReachedMax;

  PlaylistLoaded({
    required this.trendingSongsPlaylist,
    required this.billboardSongsPlaylist,
    required this.suggestedSongsOfFavouriteArtists,
    required this.favouriteSongsPlaylist,
    required this.userPlaylists,
    this.hasReachedMax = false,
  });

// PlaylistLoaded copyWith({
//   List<Song>? trendingSongsPlaylist,
//   bool? hasReachedMax,
// }) {
//   return PlaylistLoaded(
//     trendingSongsPlaylist: trendingSongsPlaylist ?? this.trendingSongsPlaylist,
//     hasReachedMax: hasReachedMax ?? this.hasReachedMax,
//   );
// }}
}
final class AddedFavouriteSong extends PlaylistState{

}
final class RemovedFavouriteSong extends PlaylistState{

}
final class PlaylistError extends PlaylistState{
  final String errorMessage;

  PlaylistError({required this.errorMessage});
}