part of 'artist_bloc.dart';

@immutable
sealed class ArtistState {}

final class ArtistInitial extends ArtistState {}

final class ArtistFetchSuccess extends ArtistState {
  final bool isLoading;
  final Artist? artist;
  final List? artists;

  ArtistFetchSuccess( {this.artist,this.artists,required this.isLoading});

  ArtistFetchSuccess copyWith({
    Artist? artist,
    List? artists,
    bool? isLoading
  }) {
    return ArtistFetchSuccess(
      artists:  artists ?? this.artists,
      artist: artist ?? this.artist,
      isLoading: isLoading?? this.isLoading
    );
  }
}


final class ArtistFetchError extends ArtistState{
  final String errorMessage;

  ArtistFetchError({required this.errorMessage});

}