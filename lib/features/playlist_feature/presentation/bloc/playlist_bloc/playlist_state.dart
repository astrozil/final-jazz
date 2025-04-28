part of 'playlist_bloc.dart';

@immutable
sealed class PlaylistState {}

final class PlaylistInitial extends PlaylistState {}

final class PlaylistLoaded extends PlaylistState {
  final bool isLoading;
  final List<RelatedSong> trendingSongsPlaylist;
  final List<BillboardSong> billboardSongsPlaylist;
  final List<RelatedSong> suggestedSongsOfFavouriteArtists;
  final List<RelatedSong> favouriteSongsPlaylist;
  final List<Map> userPlaylists;
  final List<RelatedSong> recommendedSongsPlaylist;
  final List<RelatedSong> songsFromSongIdList;
  final Map userPlaylist;
  final bool hasReachedMax;

  PlaylistLoaded({
    required this.isLoading,
    required this.trendingSongsPlaylist,
    required this.billboardSongsPlaylist,
    required this.suggestedSongsOfFavouriteArtists,
    required this.recommendedSongsPlaylist,
    required this.favouriteSongsPlaylist,
    required this.songsFromSongIdList,
    required this.userPlaylists,
    required this.userPlaylist,
    this.hasReachedMax = false,
  });
  PlaylistLoaded copyWith({
    bool? isLoading,
    List<RelatedSong>? trendingSongsPlaylist,
    List<BillboardSong>? billboardSongsPlaylist,
    List<RelatedSong>? suggestedSongsOfFavouriteArtists,
    List<RelatedSong>? favouriteSongsPlaylist,
    List<RelatedSong>? songsFromSongIdList,
    List<RelatedSong>? recommendedSongsPlaylist,
    List<Map>? userPlaylists,
    Map? userPlaylist,
    bool? hasReachedMax,
  }) {
    return PlaylistLoaded(
      isLoading: isLoading ?? this.isLoading,
      trendingSongsPlaylist: trendingSongsPlaylist ?? this.trendingSongsPlaylist,
      billboardSongsPlaylist: billboardSongsPlaylist ?? this.billboardSongsPlaylist,
      songsFromSongIdList: songsFromSongIdList ?? this.songsFromSongIdList,
      suggestedSongsOfFavouriteArtists:

      suggestedSongsOfFavouriteArtists ?? this.suggestedSongsOfFavouriteArtists,
      recommendedSongsPlaylist:recommendedSongsPlaylist??  this.recommendedSongsPlaylist ,
      favouriteSongsPlaylist: favouriteSongsPlaylist ?? this.favouriteSongsPlaylist,
      userPlaylists: userPlaylists ?? this.userPlaylists,
      userPlaylist: userPlaylist ?? this.userPlaylist,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

}
final class AddedFavouriteSong extends PlaylistState{

}
final class RemovedFavouriteSong extends PlaylistState{

}
final class PlaylistError extends PlaylistState{
  final String errorMessage;

  PlaylistError({required this.errorMessage});
}