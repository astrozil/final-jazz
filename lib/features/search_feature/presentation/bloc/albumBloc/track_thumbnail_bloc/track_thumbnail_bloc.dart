import 'package:bloc/bloc.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/search_feature/domain/entities/thumbnails.dart';
import 'package:jazz/features/search_feature/domain/usecases/fetch_track_thumbnail.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';
import 'package:meta/meta.dart';

part 'track_thumbnail_event.dart';
part 'track_thumbnail_state.dart';

class TrackThumbnailBloc extends Bloc<TrackThumbnailEvent, TrackThumbnailState> {
  final FetchTrackThumbnailUseCase fetchTrackThumbnailUseCase;

  TrackThumbnailBloc({required this.fetchTrackThumbnailUseCase})
      : super(TrackThumbnailInitial()) {
    on<TrackThumbnailUpdateEvent>((event, emit) async {
      // Filter out tracks that already have thumbnails
      List<RelatedSong> tracksWithoutThumbnails = event.tracks.where(
            (track) => track.song.thumbnails.defaultThumbnail.url.isEmpty,
      ).toList();

      if (tracksWithoutThumbnails.isEmpty) {
        emit(TrackThumbnailUpdatedState(tracks: event.tracks));
        return;
      }

      // Fetch thumbnails in parallel
      List<Future<RelatedSong>> thumbnailFutures = tracksWithoutThumbnails.map((track) async {
        final result = await fetchTrackThumbnailUseCase(track.song.id);

        return result.fold(
              (failure) {
            // Log the error or handle it as needed
            print('Failed to fetch thumbnail for track: ${track.song.title}');
            return track; // Return the original track if thumbnail fetch fails
          },
              (thumbnail) {
            // Return track with updated thumbnails
            return RelatedSong(
              url: "",
              song: track.song.copyWith(
                thumbnails: YtThumbnails(
                  defaultThumbnail: YtThumbnail(
                    url: thumbnail.url,
                    width: thumbnail.width,
                    height: thumbnail.height,
                  ),
                  mediumThumbnail: YtThumbnail(
                    url: thumbnail.url,
                    width: thumbnail.width,
                    height: thumbnail.height,
                  ),
                  highThumbnail: YtThumbnail(
                    url: thumbnail.url,
                    width: thumbnail.width,
                    height: thumbnail.height,
                  ),
                ),
              ),
            );
          },
        );
      }).toList();

      // Wait for all thumbnail updates to complete
      List<RelatedSong> updatedTracks = await Future.wait(thumbnailFutures);

      // Merge updated tracks with original tracks
      List<RelatedSong> finalTracks = event.tracks.map((track) {
        return updatedTracks.firstWhere(
              (updatedTrack) => updatedTrack.song.id == track.song.id,
          orElse: () => track,
        );
      }).toList();

      // Emit updated state
      emit(TrackThumbnailUpdatedState(tracks: finalTracks));
    });
  }
}
