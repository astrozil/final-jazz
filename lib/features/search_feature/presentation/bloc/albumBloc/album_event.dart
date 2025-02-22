part of 'album_bloc.dart';

@immutable
sealed class AlbumEvent {}

final class SearchAlbum extends AlbumEvent{
  final String albumId;

  SearchAlbum({required this.albumId});
}