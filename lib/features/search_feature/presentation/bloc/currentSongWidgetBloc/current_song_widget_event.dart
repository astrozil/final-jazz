part of 'current_song_widget_bloc.dart';

@immutable
sealed class CurrentSongWidgetEvent {}

final class CurrentSongWidgetCollapseEvent extends CurrentSongWidgetEvent  {

}

final class CurrentSongWidgetExpandEvent extends CurrentSongWidgetEvent{

}