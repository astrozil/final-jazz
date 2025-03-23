part of 'playlist_bloc.dart';

@immutable
sealed class PlaylistEvent {}

final class FetchTrendingSongsPlaylistEvent extends PlaylistEvent{

}
final class FetchBillboardSongsPlaylistEvent extends PlaylistEvent{

}

final class FetchSuggestedSongsOfFavouriteArtists extends PlaylistEvent{
  final String artistIds;

  FetchSuggestedSongsOfFavouriteArtists({required this.artistIds});
}

final class FetchFavouriteSongsPlaylistEvent extends PlaylistEvent{


}

final class PlaylistLoadMoreEvent extends PlaylistEvent{

}

final class AddFavouriteSong extends PlaylistEvent{
  final String songId;

  AddFavouriteSong({required this.songId});

}

final class RemoveFavouriteSong extends PlaylistEvent{
  final String songId;

  RemoveFavouriteSong({required this.songId});

}

class CreatePlaylist extends PlaylistEvent {
  final String title;
  CreatePlaylist(this.title);
}

class DeletePlaylist extends PlaylistEvent {
  final String playlistId;
  DeletePlaylist(this.playlistId);
}

class FetchPlaylists extends PlaylistEvent {}

class ChangePlaylistTitle extends PlaylistEvent {
  final String title;
  final String playlistId;
  ChangePlaylistTitle({required this.title, required this.playlistId});
}

class AddSongToPlaylist extends PlaylistEvent {
  final String songId;
  final String playlistId;
  AddSongToPlaylist({required this.songId, required this.playlistId});
}

class RemoveSongFromPlaylist extends PlaylistEvent {
  final String songId;
  final String playlistId;
  RemoveSongFromPlaylist({required this.songId, required this.playlistId});
}