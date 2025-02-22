part of 'search_bloc.dart';

@immutable
abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Song> songs;
  final List<Album> albums;
  final List<Artist> artists;

  SearchLoaded({
    required this.songs,
    required this.albums,
    required this.artists,
  });
}

class SearchError extends SearchState {
  final String message;
  SearchError({ required this.message });
}
