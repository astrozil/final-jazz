part of 'current_song_widget_bloc.dart';

@immutable
sealed class CurrentSongWidgetState {}

final class CurrentSongWidgetInitial extends CurrentSongWidgetState {}

final class CurrentSongWidgetCollapseState extends CurrentSongWidgetState{

}

final class CurrentSongWidgetExpandState extends CurrentSongWidgetState{

}