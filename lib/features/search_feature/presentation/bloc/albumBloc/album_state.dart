part of 'album_bloc.dart';

@immutable
sealed class AlbumState {}

final class AlbumInitial extends AlbumState {}

final class AlbumFound extends AlbumState{
  final Album album;

  AlbumFound({required this.album});
}

final class AlbumError extends AlbumState{
  final Failure failure;

  AlbumError({required this.failure});
}