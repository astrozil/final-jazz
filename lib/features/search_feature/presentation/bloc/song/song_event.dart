
part of 'song_bloc.dart';


abstract class SongEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SearchForSongs extends SongEvent {
  final String query;

  SearchForSongs(this.query);

  @override
  List<Object> get props => [query];
}
