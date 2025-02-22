part of 'song_bloc.dart';



abstract class SongState extends Equatable {
  @override
  List<Object> get props => [];
}

class SongInitial extends SongState {}

class SongLoading extends SongState {}

class SongLoaded extends SongState {
  final List<Song> songs;

  SongLoaded(this.songs);

  @override
  List<Object> get props => [songs];
}

class SongError extends SongState {
  final String message;

  SongError(this.message);

  @override
  List<Object> get props => [message];
}
