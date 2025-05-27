import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/core/widgets/song_widget.dart';
import 'package:jazz/features/playlist_feature/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';

import '../../../../core/routes.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import '../../../download_feature/domain/entities/download_request.dart';
import '../../../download_feature/presentation/bloc/DownloadedOrNotBloc/downloaded_or_not_bloc.dart';
import '../../../download_feature/presentation/bloc/download/download_bloc.dart';
import '../../../search_feature/presentation/bloc/artist_bloc/artist_bloc.dart';
import '../../../search_feature/presentation/widgets/share_user_selection.dart';
import '../../../search_feature/presentation/widgets/user_selection_bottom_sheet.dart';

class TrendingSongsPlaylistScreen extends StatelessWidget {
  const TrendingSongsPlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<PlaylistBloc, PlaylistState>(
        builder: (context, state) {
          if (state is PlaylistLoaded && state.isLoading && state.trendingSongsPlaylist.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          } else if (state is PlaylistLoaded && state.trendingSongsPlaylist.isNotEmpty) {
            final songs = state.trendingSongsPlaylist;
            if (songs.isEmpty) {
              return const Center(
                child: Text(
                    "No trending songs available",
                    style: TextStyle(color: Colors.white)
                ),
              );
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Album Cover
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildAlbumCover(songs, context),
                  ),
                ),

                // Playlist Info
                SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      children: [
                        const Text(
                          "Trending Songs",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${songs.length} TRACKS",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Play and Shuffle Buttons
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (songs.isNotEmpty) {
                                context.read<PlayerBloc>().add(
                                    PlaySongEvent(song: left(songs.first.song), albumTracks: songs)
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.play_arrow),
                                SizedBox(width: 8),
                                Text(
                                  "Play",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final List<RelatedSong> shuffleSongs = List.from(songs);
                              shuffleSongs.shuffle();
                              context.read<PlayerBloc>().add(
                                  PlaySongEvent(song: left(shuffleSongs.first.song), albumTracks: shuffleSongs)
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shuffle),
                                SizedBox(width: 8),
                                Text(
                                  "Shuffle",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Song List
                SliverPadding(
                  padding: const EdgeInsets.only(top: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final song = songs[index];
                        return songWidget(context: context, song: song.song,songs: songs);
                      },
                      childCount: songs.length,
                    ),
                  ),
                ),
              ],
            );
          } else if (state is PlaylistError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Oops! Something went wrong',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      state.errorMessage,
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
        },
      ),
    );
  }

  Widget _buildAlbumCover(List<RelatedSong> songs, BuildContext context) {
    if (songs.isEmpty) {
      // Fallback for empty songs list
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.music_note, size: 80, color: Colors.white70),
          ),
        ),
      );
    }

    // For a single track, show a large image
    if (songs.length == 1) {
      return AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            songs[0].song.thumbnails.highThumbnail.url,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // For multiple tracks, show a grid
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: AspectRatio(
          aspectRatio: 1,
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _buildAlbumGridItems(songs),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAlbumGridItems(List<RelatedSong> songs) {
    final List<Widget> gridItems = [];

    // Logic based on track count
    if (songs.length == 2) {
      // For 2 tracks: pattern [1,2,1,2]
      gridItems.add(_buildGridItem(songs[0]));
      gridItems.add(_buildGridItem(songs[1]));
      gridItems.add(_buildGridItem(songs[0]));
      gridItems.add(_buildGridItem(songs[1]));
    } else if (songs.length == 3) {
      // For 3 tracks: pattern [1,2,3,1]
      gridItems.add(_buildGridItem(songs[0]));
      gridItems.add(_buildGridItem(songs[1]));
      gridItems.add(_buildGridItem(songs[2]));
      gridItems.add(_buildGridItem(songs[0]));
    } else {
      // For 4 or more tracks: show first 4 tracks
      for (int i = 0; i < 4 && i < songs.length; i++) {
        gridItems.add(_buildGridItem(songs[i]));
      }
    }

    return gridItems;
  }

  Widget _buildGridItem(RelatedSong song) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        song.song.thumbnails.highThumbnail.url,
        fit: BoxFit.cover,
      ),
    );
  }
}
