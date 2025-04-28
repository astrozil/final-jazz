import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/features/auth_feature/domain/entities/user.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:jazz/features/lyrics_feature/presentation/bloc/lyrics_bloc/lyrics_bloc.dart';
import 'package:jazz/features/lyrics_feature/presentation/screens/lyrics_screen.dart';
import 'package:jazz/features/playlist_feature/domain/repositories/playlist_repo.dart';
import 'package:jazz/features/playlist_feature/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';
import 'package:jazz/features/stream_feature/domain/entities/repeat_mode.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';
import 'package:jazz/features/stream_feature/presentation/screens/relatedSongsScreen.dart';

class ExpandedCurrentSong extends StatelessWidget {
  ExpandedCurrentSong({super.key});
  final TextEditingController _controller = TextEditingController();

  void _showBottomSheet(BuildContext context, String songId) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          height: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is UserDataFetched) {
                    AppUser user = state.user;
                    if (user.favouriteSongs.contains(songId)) {
                      return ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<PlaylistBloc>().add(RemoveFavouriteSong(songId: songId));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite, size: 24),
                            SizedBox(width: 8),
                            Text("Remove From Favorite Songs", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    } else {
                      return ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<PlaylistBloc>().add(AddFavouriteSong(songId: songId));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_border, size: 24),
                            SizedBox(width: 8),
                            Text("Add to Favorite Songs", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }
                  }
                  return Center(child: CircularProgressIndicator());
                },
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, Player>(
      builder: (context, state) {
        if (state is PlayerState) {
          if (state.currentSong != null) {
            return Container(
              height: MediaQuery.of(context).size.height,

              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              decoration: BoxDecoration(

                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.deepPurple.shade900, Colors.black],
                ),
              ),
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  // App Bar / Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    const SizedBox(width: 50,),

                      Text(
                        "Now Playing",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  SizedBox(height: 30),

                  // Album Art and Song Info
                  state.currentSong!.fold(
                        (song) {
                      return Column(
                        children: [
                          Container(
                            height: 250,
                            width: 250,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 5,
                                  blurRadius: 15,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              song.thumbnails.highThumbnail.url ?? "",
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 25),
                          Text(
                            song.title ?? "",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Text(
                            song.artists.map((song)=> song['name'] ).join(",") ?? "Unknown Artist",
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      );
                    },
                        (downloadedSong) {
                      return Column(
                        children: [
                          Container(
                            height: 250,
                            width: 250,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 5,
                                  blurRadius: 15,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.memory(
                              downloadedSong.image!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 25),
                          Text(
                            downloadedSong.songName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Text(
                            downloadedSong.artist,
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 30),

                  // Playback Progress
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 5,
                            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
                            activeTrackColor: Colors.purple,
                            inactiveTrackColor: Colors.grey.withOpacity(0.3),
                            thumbColor: Colors.white,
                            overlayColor: Colors.purple.withOpacity(0.3),
                          ),
                          child: Slider(
                            min: 0,
                            max: state.totalDuration.inMilliseconds.toDouble(),
                            value: state.songPosition.inMilliseconds.toDouble(),
                            onChanged: (value) {
                              context.read<PlayerBloc>().seekTo(
                                  Duration(milliseconds: value.toInt()));
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(state.songPosition),
                                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                              ),
                              Text(
                                _formatDuration(state.totalDuration),
                                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 25),

                  // Playback Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Shuffle Button
                      BlocBuilder<PlayerBloc, Player>(
                        builder: (context, state) {
                          if (state is PlayerState) {
                            bool isShuffled = state.isShuffleEnabled;
                            return IconButton(
                              icon: Icon(
                                Icons.shuffle,
                                color: isShuffled ? Colors.purple : Colors.white,
                                size: 25,
                              ),
                              onPressed: () {
                                context.read<PlayerBloc>().add(
                                    ToggleShuffleEvent(
                                        isShuffled: !isShuffled,
                                        index: state.currentSongIndex));
                              },
                            );
                          }
                          return SizedBox();
                        },
                      ),

                      // Previous Button
                      IconButton(
                        icon: Icon(Icons.skip_previous, color: Colors.white, size: 35),
                        onPressed: () {
                          context.read<PlayerBloc>().add(PlayPreviousEvent());
                        },
                      ),

                      // Play/Pause Button
                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.purple, Colors.deepPurple],
                          ),
                        ),
                        child: BlocBuilder<PlayerBloc, Player>(
                          builder: (context, state) {
                            if (state is PlayerState) {
                              return IconButton(
                                icon: Icon(
                                  state.isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 35,
                                ),
                                onPressed: () {
                                  if (state.isPlaying) {
                                    context.read<PlayerBloc>().add(PausePlayerEvent());
                                  } else {
                                    context.read<PlayerBloc>().add(ResumePlayerEvent());
                                  }
                                },
                              );
                            }
                            return Icon(Icons.play_arrow, color: Colors.white, size: 35);
                          },
                        ),
                      ),

                      // Next Button
                      IconButton(
                        icon: Icon(Icons.skip_next, color: Colors.white, size: 35),
                        onPressed: () {
                          context.read<PlayerBloc>().add(PlayNextSongEvent());
                        },
                      ),

                      // Repeat Button
                      BlocBuilder<PlayerBloc, Player>(
                        builder: (context, state) {
                          if (state is PlayerState) {
                            IconData iconData;
                            Color iconColor;

                            if (state.isSongRepeatEnabled) {
                              iconData = Icons.repeat_one;
                              iconColor = Colors.purple;
                            } else if (state.isPlaylistRepeatEnabled) {
                              iconData = Icons.repeat;
                              iconColor = Colors.purple;
                            } else {
                              iconData = Icons.repeat;
                              iconColor = Colors.white;
                            }

                            return IconButton(
                              icon: Icon(
                                iconData,
                                color: iconColor,
                                size: 25,
                              ),
                              onPressed: () {
                                if (!state.isPlaylistRepeatEnabled && !state.isSongRepeatEnabled) {
                                  context.read<PlayerBloc>().add(
                                      ToggleRepeatModeEvent(mode: RepeatMode.playlist));
                                } else if (state.isPlaylistRepeatEnabled) {
                                  context.read<PlayerBloc>().add(
                                      ToggleRepeatModeEvent(mode: RepeatMode.song));
                                } else if (state.isSongRepeatEnabled) {
                                  context.read<PlayerBloc>().add(
                                      ToggleRepeatModeEvent(mode: RepeatMode.none));
                                }
                              },
                            );
                          }
                          return SizedBox();
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 25),

                  // Additional Functions Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Lyrics Button
                      _buildActionButton(
                        context: context,
                        icon: Icons.lyrics,
                        label: "Lyrics",
                        onTap: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) {
                                return const LyricsScreen();
                              })
                          );
                        },
                      ),

                      // Related Songs Button
                      _buildActionButton(
                        context: context,
                        icon: Icons.queue_music,
                        label: "Related",
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return RelatedSongScreen();
                              })
                          );
                        },
                      ),

                      // Playlists Button
                      state.currentSong!.fold(
                            (song) {
                          return _buildActionButton(
                            context: context,
                            icon: Icons.playlist_add,
                            label: "Add to Playlist",
                            onTap: () {
                              context.read<PlaylistBloc>().add(FetchPlaylists());
                              showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                isScrollControlled: true,
                                backgroundColor: Colors.grey[900],
                                builder: (_) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).viewInsets.bottom,
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 16.0),
                                          child: Text(
                                            "Add to Playlist",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        BlocBuilder<PlaylistBloc, PlaylistState>(
                                          builder: (context, playlistState) {
                                            if (playlistState is PlaylistLoaded && !playlistState.isLoading) {
                                              final playlists = playlistState.userPlaylists;
                                              if (playlists.isNotEmpty) {
                                                return Container(
                                                  constraints: BoxConstraints(maxHeight: 300),
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: playlists.length,
                                                    itemBuilder: (context, index) {
                                                      final playlist = playlists[index];
                                                      return ListTile(
                                                        leading: Container(
                                                          width: 40,
                                                          height: 40,
                                                          decoration: BoxDecoration(
                                                            color: Colors.purple.withOpacity(0.7),
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          child: Icon(Icons.my_library_music, color: Colors.white),
                                                        ),
                                                        title: Text(
                                                          playlist['title'],
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                        subtitle: Text(
                                                          "${playlist['tracks'].length} songs",
                                                          style: TextStyle(color: Colors.grey[400]),
                                                        ),
                                                        onTap: () {
                                                          state.currentSong!.fold(
                                                                (song) {
                                                              context.read<PlaylistBloc>().add(AddSongToPlaylist(
                                                                songId: song.id,
                                                                playlistId: playlist['playlistId'],
                                                              ));
                                                              Navigator.pop(context);
                                                            },
                                                                (downloadedSong) {},
                                                          );
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
                                                  "No playlists found. Create one below.",
                                                  style: TextStyle(color: Colors.grey[400]),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  backgroundColor: Colors.grey[900],
                                                  title: Text(
                                                    'Create Playlist',
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                  content: TextField(
                                                    controller: _controller,
                                                    style: TextStyle(color: Colors.white),
                                                    decoration: InputDecoration(
                                                      hintText: 'Playlist name',
                                                      hintStyle: TextStyle(color: Colors.grey[400]),
                                                      focusedBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide(color: Colors.purple),
                                                      ),
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(null),
                                                      child: Text(
                                                        'Cancel',
                                                        style: TextStyle(color: Colors.grey[400]),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                        context.read<PlaylistBloc>().add(CreatePlaylist(_controller.text));
                                                        _controller.clear();
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.purple,
                                                      ),
                                                      child: Text('Create'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.purple,
                                            minimumSize: Size(double.infinity, 50),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add, size: 20),
                                              SizedBox(width: 8),
                                              Text("Create New Playlist"),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                            (downloadedSong) => SizedBox(),
                      ),

                      // Favorites Button
                      state.currentSong!.fold(
                            (song) {
                          return _buildActionButton(
                            context: context,
                            icon: Icons.favorite_border,
                            label: "Favorite",
                            onTap: () {
                              _showBottomSheet(context, song.id);
                              context.read<AuthBloc>().add(FetchUserDataEvent());
                            },
                          );
                        },
                            (downloadedSong) => SizedBox(),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          return Center(
            child: Text(
              "No song is currently playing",
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    return "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
  }
}