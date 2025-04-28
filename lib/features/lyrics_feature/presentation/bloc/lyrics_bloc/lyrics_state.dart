part of 'lyrics_bloc.dart';

@immutable
sealed class LyricsState {}

final class LyricsInitial extends LyricsState {}
final class GotLyricsState extends LyricsState{
   final List<Map<String, dynamic>>? syncedLyrics;

  GotLyricsState({required this.syncedLyrics});

}
final class NoLyricsState extends LyricsState{
  final String failure;

  NoLyricsState({required this.failure});
}