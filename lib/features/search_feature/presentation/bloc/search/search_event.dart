part of 'search_bloc.dart';

@immutable
abstract class SearchEvent {}

class SearchSongsRequested extends SearchEvent {
  final String query;
  SearchSongsRequested({ required this.query });
}

class SearchAlbumsRequested extends SearchEvent {
  final String query;
  SearchAlbumsRequested({ required this.query });
}

class SearchArtistsRequested extends SearchEvent {
  final String query;
  SearchArtistsRequested({ required this.query });
}
