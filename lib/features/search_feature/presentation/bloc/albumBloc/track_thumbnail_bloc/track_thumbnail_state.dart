part of 'track_thumbnail_bloc.dart';

@immutable
sealed class TrackThumbnailState {}

final class TrackThumbnailInitial extends TrackThumbnailState {}

final class TrackThumbnailUpdatedState extends TrackThumbnailState{
  final List<RelatedSong> tracks;

  TrackThumbnailUpdatedState({required this.tracks});
}