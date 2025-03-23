import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/features/search_feature/domain/entities/album.dart';
import 'package:jazz/features/search_feature/domain/entities/thumbnails.dart';
import 'package:jazz/features/search_feature/presentation/bloc/albumBloc/album_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/albumBloc/track_thumbnail_bloc/track_thumbnail_bloc.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';
import 'package:jazz/features/stream_feature/domain/entities/songHistory.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';

class AlbumScreen extends StatelessWidget {
  const AlbumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Album Screen"),
      ),
      body: BlocBuilder<AlbumBloc, AlbumState>(
        builder: (context, state) {
          if (state is AlbumInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AlbumError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 40),
                  const SizedBox(height: 10),
                  const Text(
                    'Failed to load album data. Please try again.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Trigger a retry - replace 'albumId' with actual data
                      context.read<AlbumBloc>().add(SearchAlbum(albumId: 'album-id-placeholder'));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is AlbumFound) {
            Album album = state.album;
            return buildAlbumDetails(context, album);
          } else {
            return const Center(child: Text("Unexpected error"));
          }
        },
      ),
    );
  }

  Widget buildAlbumDetails(BuildContext context, Album album) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              album.artist,
              style: TextStyle(fontSize: isSmallScreen ? 18 : 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Image.network(album.ytThumbnail.url, height: isSmallScreen ? 200 : 400),
            const SizedBox(height: 10),
            Text(album.title, style: TextStyle(fontSize: isSmallScreen ? 16 : 20)),
            const SizedBox(height: 5),
            Text('${album.type} · ${album.year}'),
            Text('${album.trackCount} Songs · ${album.duration}'),
            const SizedBox(height: 10),
            Text(
              album.description,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            BlocBuilder<TrackThumbnailBloc, TrackThumbnailState>(
              builder: (context, state) {
                return buildTrackList(context, state, album);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTrackList(BuildContext context, TrackThumbnailState state, Album album) {
    // Update the album's track list with new thumbnails if available.
    Album updatedAlbum = album;
    if (state is TrackThumbnailUpdatedState) {
      updatedAlbum = album.copyWith(
        tracks: album.tracks.map((track) {
          // Look for an updated track in the bloc state.
          final updatedTrack = state.tracks.firstWhere(
                (t) => t.song.id == track.song.id,
            orElse: () => track,
          );
          return updatedTrack;
        }).toList(),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: updatedAlbum.tracks.length,
      itemBuilder: (context, index) {
        RelatedSong track = updatedAlbum.tracks[index];
        YtThumbnail thumbnail = track.song.thumbnails.defaultThumbnail;

        return InkWell(
          onTap: () {

            context.read<PlayerBloc>().add(PlaySongEvent(song: left(track.song),albumTracks: updatedAlbum.tracks));

          },
          child: ListTile(
            leading: thumbnail.url.isNotEmpty
                ? Image.network(thumbnail.url, height: 50, width: 50, fit: BoxFit.cover)
                : const SizedBox(height: 50, width: 50, child: Icon(Icons.music_note)),
            title: Text(track.song.title),
            subtitle:Text( track.song.artists
                .map((artist) => artist['name'] as String)
                .join(', '),),
          ),
        );
      },
    );
  }
}
