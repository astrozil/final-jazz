part of 'shared_song_bloc.dart';

@immutable
sealed class SharedSongState {}

final class SharedSongInitial extends SharedSongState {}
class SharedSongLoading extends SharedSongState {}
class SharedSongSuccess extends SharedSongState {}
class SharedSongError extends SharedSongState {
  final String message;
  SharedSongError(this.message);
}

class ReceivedSharedSongsLoaded extends SharedSongState {
  final List<SharedSong> sharedSongs;
  ReceivedSharedSongsLoaded(this.sharedSongs);
}

class SentSharedSongsLoaded extends SharedSongState {
  final List<SharedSong> sharedSongs;
  SentSharedSongsLoaded(this.sharedSongs);
}
