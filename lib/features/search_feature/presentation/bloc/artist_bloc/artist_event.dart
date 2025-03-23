part of 'artist_bloc.dart';

@immutable
sealed class ArtistEvent {}

final class FetchArtistEvent extends ArtistEvent{
  final String artistId;

  FetchArtistEvent({required this.artistId});

}
