part of 'track_thumbnail_bloc.dart';

@immutable
sealed class TrackThumbnailEvent {}

final class TrackThumbnailUpdateEvent extends TrackThumbnailEvent{
 final List<RelatedSong> tracks;

  TrackThumbnailUpdateEvent({required this.tracks});
}