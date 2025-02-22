part of 'lyrics_bloc.dart';

@immutable
sealed class LyricsState {}

final class LyricsInitial extends LyricsState {}
final class GotLyricsState extends LyricsState{
   final String lyrics;

  GotLyricsState({required this.lyrics});

}
final class NoLyricsState extends LyricsState{
  final String failure;

  NoLyricsState({required this.failure});
}