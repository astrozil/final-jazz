part of 'artist_bloc.dart';

@immutable
sealed class ArtistEvent {}

final class FetchArtistEvent extends ArtistEvent{
  final String artistId;

  FetchArtistEvent({required this.artistId});

}
final class FetchArtistsEvent extends ArtistEvent {
  final List<String> artistIdList;

  FetchArtistsEvent({required this.artistIdList});

}