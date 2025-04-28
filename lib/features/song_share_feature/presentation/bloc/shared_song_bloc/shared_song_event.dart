part of 'shared_song_bloc.dart';

@immutable
sealed class SharedSongEvent {}
class ShareSongEvent extends SharedSongEvent {
  final SharedSong sharedSong;
  ShareSongEvent(this.sharedSong);
}

class GetReceivedSharedSongsEvent extends SharedSongEvent {}

class GetSentSharedSongsEvent extends SharedSongEvent {}

class MarkSharedSongAsViewedEvent extends SharedSongEvent {
  final String sharedSongId;
  MarkSharedSongAsViewedEvent(this.sharedSongId);
}

class SetCurrentUserIdSharedSongEvent extends SharedSongEvent {
  final String userId;
  SetCurrentUserIdSharedSongEvent(this.userId);
}

// Private events for internal use
class _ReceivedSharedSongsUpdated extends SharedSongEvent {
  final List<SharedSong> sharedSongs;
  _ReceivedSharedSongsUpdated(this.sharedSongs);
}

class _SentSharedSongsUpdated extends SharedSongEvent {
  final List<SharedSong> sharedSongs;
  _SentSharedSongsUpdated(this.sharedSongs);
}

class _SharedSongError extends SharedSongEvent {
  final String message;
  _SharedSongError(this.message);
}