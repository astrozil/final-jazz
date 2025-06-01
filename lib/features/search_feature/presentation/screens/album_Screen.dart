import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/features/search_feature/domain/entities/album.dart';
import 'package:jazz/features/search_feature/domain/entities/thumbnails.dart';
import 'package:jazz/features/search_feature/presentation/bloc/albumBloc/album_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/albumBloc/track_thumbnail_bloc/track_thumbnail_bloc.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';
import 'package:jazz/features/stream_feature/domain/entities/songHistory.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';

import '../../../../core/routes.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import '../../../download_feature/domain/entities/download_request.dart';
import '../../../download_feature/presentation/bloc/DownloadedOrNotBloc/downloaded_or_not_bloc.dart';
import '../../../download_feature/presentation/bloc/download/download_bloc.dart';
import '../../../playlist_feature/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import '../bloc/artist_bloc/artist_bloc.dart';
import '../widgets/share_user_selection.dart';
import '../widgets/user_selection_bottom_sheet.dart';

class AlbumScreen extends StatelessWidget {
  const AlbumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined,
              color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<AlbumBloc, AlbumState>(
        builder: (context, state) {
          if (state is AlbumInitial) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
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
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      context
                          .read<AlbumBloc>()
                          .add(SearchAlbum(albumId: 'album-id-placeholder'));
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
            return const Center(
              child: Text(
                "Unexpected error",
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildAlbumDetails(BuildContext context, Album album) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album header section
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Album artwork
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      album.ytThumbnail.url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.album,
                            size: 80,
                            color: Colors.white54,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Album title
                Text(
                  album.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Artist name with arrow
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      album.artist,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Year and additional info
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      album.year,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (album.description.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                     Navigator.pushNamed(context, Routes.albumDescriptionScreen,arguments: {'albumTitle': album.title,'artist':album.artist,'description':album.description});
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            album.description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),

                // Play and Shuffle buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (album.tracks.isNotEmpty) {
                            context.read<PlayerBloc>().add(
                                  PlaySongEvent(
                                    song: left(album.tracks.first.song),
                                    albumTracks: album.tracks,
                                  ),
                                );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow, size: 24),
                        label: const Text(
                          'Play',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (album.tracks.isNotEmpty) {
                            final List<RelatedSong> tempTracks =
                                List.from(album.tracks);
                            tempTracks.shuffle();
                            context.read<PlayerBloc>().add(
                                  PlaySongEvent(
                                    song: left(tempTracks.first.song),
                                    albumTracks: tempTracks,
                                  ),
                                );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        icon: const Icon(Icons.shuffle, size: 24),
                        label: const Text(
                          'Shuffle',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 16.h,
          ),
          // Track list section
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
            child: BlocBuilder<TrackThumbnailBloc, TrackThumbnailState>(
              builder: (context, state) {
                return buildTrackList(context, state, album);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTrackList(
      BuildContext context, TrackThumbnailState state, Album album) {
    Album updatedAlbum = album;
    if (state is TrackThumbnailUpdatedState) {
      updatedAlbum = album.copyWith(
        tracks: album.tracks.map((track) {
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

        return InkWell(
          onTap: () {
            context.read<PlayerBloc>().add(
                  PlaySongEvent(
                    song: left(track.song),
                    albumTracks: updatedAlbum.tracks,
                  ),
                );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: [
                // Track number
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Track info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        track.song.artists
                            .map((artist) => artist['name'] as String)
                            .join(', '),
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // More options button
                GestureDetector(
                  onTap: () {
                    context.read<DownloadedOrNotBloc>().add(
                        CheckIfDownloadedEvent(track.song.id, track.song.title,
                            track.song.artists.first['name']));
                    showModalBottomSheet(
                        context: context,
                        enableDrag: true,
                        backgroundColor: const Color.fromRGBO(37, 39, 40, 1),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20))),
                        builder: (context) {
                          return Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 80.w,
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 8),
                                        height: 4,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                              color: Colors.white
                                                  .withOpacity(0.8)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 30.h,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      context
                                          .read<PlaylistBloc>()
                                          .add(FetchPlaylists());
                                      showModalBottomSheet(
                                        context: context,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20)),
                                        ),
                                        isScrollControlled: true,
                                        backgroundColor:
                                            Color.fromRGBO(37, 39, 40, 1),
                                        builder: (_) => Padding(
                                          padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom,
                                          ),
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 16.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        width: 80.w,
                                                      ),
                                                      Text(
                                                        "Playlists",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.8)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                BlocBuilder<PlaylistBloc,
                                                    PlaylistState>(
                                                  builder:
                                                      (context, playlistState) {
                                                    if (playlistState
                                                            is PlaylistLoaded &&
                                                        !playlistState
                                                            .isLoading) {
                                                      final playlists =
                                                          playlistState
                                                              .userPlaylists;
                                                      if (playlists
                                                          .isNotEmpty) {
                                                        return Container(
                                                          constraints:
                                                              const BoxConstraints(
                                                                  maxHeight:
                                                                      300),
                                                          child:
                                                              ListView.builder(
                                                            shrinkWrap: true,
                                                            itemCount: playlists
                                                                .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              final playlist =
                                                                  playlists[
                                                                      index];
                                                              return ListTile(
                                                                leading:
                                                                    Container(
                                                                  width: 40,
                                                                  height: 40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .transparent,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  child: Icon(
                                                                    Icons
                                                                        .my_library_music,
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.5),
                                                                    size: 40.sp,
                                                                  ),
                                                                ),
                                                                title: Text(
                                                                  playlist[
                                                                      'title'],
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                subtitle: Text(
                                                                  "${playlist['tracks'].length} songs",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                              .grey[
                                                                          400]),
                                                                ),
                                                                onTap: () {
                                                                  context
                                                                      .read<
                                                                          PlaylistBloc>()
                                                                      .add(
                                                                          AddSongToPlaylist(
                                                                        songId: track
                                                                            .song
                                                                            .id,
                                                                        playlistId:
                                                                            playlist['playlistId'],
                                                                      ));
                                                                  Navigator.pop(
                                                                      context);
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .hideCurrentSnackBar();
                                                                  ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar.show(
                                                                      message:
                                                                          "Added to your playlist",
                                                                      backgroundColor:
                                                                          AppColors
                                                                              .snackBarBackgroundColor));
                                                                },
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      }
                                                    }
                                                    return SizedBox(
                                                      height: 100,
                                                      child: Center(
                                                        child: Text(
                                                          "No playlists found. Create one.",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[400]),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                const SizedBox(height: 16),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pushNamed(
                                                        context,
                                                        Routes
                                                            .newPlaylistScreen);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white,
                                                    foregroundColor:
                                                        Colors.black,
                                                    minimumSize: const Size(
                                                        double.infinity, 50),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                  ),
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(Icons.add, size: 20),
                                                      SizedBox(width: 8),
                                                      Text(
                                                          "Create New Playlist"),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.playlist_add,
                                          color: Colors.grey.withOpacity(0.6),
                                          size: 25,
                                        ),
                                        SizedBox(
                                          width: 20.w,
                                        ),
                                        Text(
                                          "Add to playlist",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.sp),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                BlocBuilder<DownloadedOrNotBloc,
                                    DownloadedOrNotState>(
                                  builder: (context, state) {
                                    if (state is DownloadedSongState) {
                                      return Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: InkWell(
                                          splashFactory: NoSplash.splashFactory,
                                          highlightColor: Colors.transparent,
                                          onTap: () {
                                            Navigator.pop(context);
                                            context
                                                .read<DownloadedOrNotBloc>()
                                                .add(DeleteDownloadedSongEvent(
                                                    track.song.id,
                                                    track.song.title,
                                                    track.song.artists
                                                        .first['name']));
                                            ScaffoldMessenger.of(context)
                                                .hideCurrentSnackBar();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(CustomSnackBar.show(
                                                    message:
                                                        "Removed from downloaded content",
                                                    backgroundColor: AppColors
                                                        .snackBarBackgroundColor));
                                          },
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                  "assets/icons/downloaded.png"),
                                              SizedBox(
                                                width: 20.w,
                                              ),
                                              Text(
                                                "Remove from downloaded content",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18.sp),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: InkWell(
                                          splashFactory: NoSplash.splashFactory,
                                          highlightColor: Colors.transparent,
                                          onTap: () {
                                            Navigator.pop(context);
                                            context.read<DownloadBloc>().add(
                                                DownloadSongEvent(DownloadRequest(
                                                    videoID: track.song.id,
                                                    title: track.song.title,
                                                    artist: track.song.artists
                                                        .first['name'],
                                                    thumbnail: track
                                                        .song
                                                        .thumbnails
                                                        .highThumbnail
                                                        .url,
                                                    videoUrl:
                                                        "https://www.youtube.com/watch?v=${track.song.id}")));
                                            ScaffoldMessenger.of(context)
                                                .hideCurrentSnackBar();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(CustomSnackBar.show(
                                                    message:
                                                        "Added to download queue",
                                                    backgroundColor: AppColors
                                                        .snackBarBackgroundColor));
                                          },
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                  "assets/icons/download.png"),
                                              SizedBox(
                                                width: 20.w,
                                              ),
                                              Text(
                                                "Download",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18.sp),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: InkWell(
                                    splashFactory: NoSplash.splashFactory,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      Navigator.pop(context);
                                      if (track.song.artists.length == 1) {
                                        context.read<ArtistBloc>().add(
                                            FetchArtistEvent(
                                                artistId: track
                                                    .song.artists.first['id']));
                                        Navigator.pushNamed(
                                            context, Routes.artistDetailScreen,
                                            arguments: {
                                              "artistId":
                                                  track.song.artists.first['id']
                                            });
                                      } else if (track.song.artists.length >
                                          1) {
                                        showModalBottomSheet(
                                            context: context,
                                            enableDrag: true,
                                            backgroundColor:
                                                const Color.fromRGBO(
                                                    37, 39, 40, 1),
                                            shape: const RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            20))),
                                            builder: (context) {
                                              return Container(
                                                  child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        SizedBox(
                                                          width: 80.w,
                                                        ),
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(top: 8),
                                                          height: 4,
                                                          width: 40,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .grey[300],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        2),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.8)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 30.h,
                                                  ),
                                                  SizedBox(
                                                    height: 200.h,
                                                    child: ListView.builder(
                                                        itemCount: track.song
                                                            .artists.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(16.0),
                                                            child: InkWell(
                                                              splashFactory:
                                                                  NoSplash
                                                                      .splashFactory,
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              onTap: () {
                                                                context
                                                                    .read<
                                                                        ArtistBloc>()
                                                                    .add(FetchArtistEvent(
                                                                        artistId: track
                                                                            .song
                                                                            .artists[index]['id']));
                                                                Navigator.pushNamed(
                                                                    context,
                                                                    Routes
                                                                        .artistDetailScreen,
                                                                    arguments: {
                                                                      "artistId": track
                                                                          .song
                                                                          .artists[index]['id']
                                                                    });
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  Image.asset(
                                                                      "assets/icons/artist.png"),
                                                                  SizedBox(
                                                                    width: 20.w,
                                                                  ),
                                                                  Text(
                                                                    track.song.artists[
                                                                            index]
                                                                        [
                                                                        'name'],
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize: 18
                                                                            .sp,
                                                                        fontWeight:
                                                                            FontWeight.normal),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                  ),
                                                ],
                                              ));
                                            });
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Image.asset("assets/icons/artist.png"),
                                        SizedBox(
                                          width: 20.w,
                                        ),
                                        Text(
                                          "Go to artist",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.normal),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      showCustomBottomSheet(
                                          context: context,
                                          builder: (context) =>
                                              UserSelectionBottomSheet(
                                                  song: track.song),
                                          backgroundColor:
                                              AppColors.primaryBackgroundColor);
                                    },
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          "assets/icons/share.png",
                                          color: Colors.grey.withOpacity(0.6),
                                        ),
                                        SizedBox(
                                          width: 20.w,
                                        ),
                                        Text(
                                          "Share",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.sp),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50.h,
                                ),
                              ],
                            ),
                          );
                        });
                  },
                  child: const Icon(
                    Icons.more_horiz,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// New screen for full album description
class AlbumDescriptionScreen extends StatelessWidget {
  final String albumTitle;
  final String artist;
  final String description;

  const AlbumDescriptionScreen({
    super.key,
    required this.albumTitle,
    required this.artist,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.primaryBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined,
              color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'About',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album info header
            Text(
              albumTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'By $artist',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),

            // Full description
            Text(
              description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
