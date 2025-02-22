part of 'player_bloc.dart';

@immutable
sealed class PlayerEvent {}

final class PlaySongEvent extends PlayerEvent{
  final Either<Song,DownloadedSong> song;
  final List<RelatedSong>? albumTracks;

  PlaySongEvent({required this.song,this.albumTracks});
}

final class PausePlayerEvent extends PlayerEvent{

}
final class ResumePlayerEvent extends PlayerEvent{

}
final class UpdateStateEvent extends PlayerEvent {
  final Player state;

  UpdateStateEvent({required this.state});

}
final class PlayNextSongEvent extends PlayerEvent{

}
final class PlayPreviousEvent extends PlayerEvent{

}
final class PlayChosenSongEvent extends PlayerEvent{
  final int chosenIndex;

  PlayChosenSongEvent({required this.chosenIndex});
}

final class ToggleShuffleEvent extends PlayerEvent {
  final bool isShuffled;
  final int? index;
  ToggleShuffleEvent({required this.isShuffled,this.index});
}

final class ToggleRepeatModeEvent extends PlayerEvent {
  final RepeatMode mode;
  ToggleRepeatModeEvent({required this.mode});
}