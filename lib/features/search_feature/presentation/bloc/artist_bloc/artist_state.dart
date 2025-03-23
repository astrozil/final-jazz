part of 'artist_bloc.dart';

@immutable
sealed class ArtistState {}

final class ArtistInitial extends ArtistState {}

final class ArtistFetchSuccess extends ArtistState{
  final Artist artist;

  ArtistFetchSuccess({required this.artist});
}

final class ArtistFetchError extends ArtistState{
  final String errorMessage;

  ArtistFetchError({required this.errorMessage});

}