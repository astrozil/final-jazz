part of 'lyrics_bloc.dart';

@immutable
sealed class LyricsEvent {}

class GetLyricsEvent extends LyricsEvent{
  final String artist;
  final String songName;
   GetLyricsEvent({required this.artist,required this.songName});
}
