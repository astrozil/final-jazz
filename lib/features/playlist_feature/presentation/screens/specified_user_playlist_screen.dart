import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/features/playlist_feature/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';

class SpecifiedUserPlaylistScreen extends StatefulWidget {
  final Map specifiedUserPlaylist;
  const SpecifiedUserPlaylistScreen({super.key, required this.specifiedUserPlaylist});

  @override
  State<SpecifiedUserPlaylistScreen> createState() => _SpecifiedUserPlaylistScreenState();
}

class _SpecifiedUserPlaylistScreenState extends State<SpecifiedUserPlaylistScreen> {
  @override
  void initState() {
    if (widget.specifiedUserPlaylist['tracks'].isNotEmpty) {
      context.read<PlaylistBloc>().add(FetchSongsFromSongIdList(songIdList: widget.specifiedUserPlaylist['tracks']));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.specifiedUserPlaylist["title"],
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 2)]
                  )),
              background: BlocBuilder<PlaylistBloc, PlaylistState>(
                builder: (context, state) {
                  if (state is PlaylistLoaded && !state.isLoading && state.songsFromSongIdList.isNotEmpty) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          state.songsFromSongIdList.first.song.thumbnails.highThumbnail.url,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.purple.shade300, Colors.blue.shade500],
                        ),
                      ),
                      child: Center(child: Icon(Icons.music_note, size: 80, color: Colors.white70)),
                    );
                  }
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Icon(Icons.queue_music, color: Colors.grey.shade700),
                  SizedBox(width: 8),
                  Text(
                    "Tracks",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          BlocBuilder<PlaylistBloc, PlaylistState>(
            builder: (context, state) {
              if (state is PlaylistLoaded && !state.isLoading) {
                final songs = state.songsFromSongIdList;
                if (songs.isNotEmpty) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final song = songs[index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          elevation: 0,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Hero(
                              tag: 'song_image_${song.song.id}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  song.song.thumbnails.defaultThumbnail.url,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(
                              song.song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              song.song.artists.map((artist) => artist['name'] as String).join(', '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            trailing: Icon(Icons.play_arrow),
                            onTap: () {
                              context.read<PlayerBloc>().add(PlaySongEvent(
                                  song: dartz.left(song.song), albumTracks: songs));
                            },
                          ),
                        );
                      },
                      childCount: songs.length,
                    ),
                  );
                } else {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.playlist_remove, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text("No tracks in this playlist",
                              style: TextStyle(fontSize: 18, color: Colors.grey.shade700)),
                        ],
                      ),
                    ),
                  );
                }
              } else {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Loading tracks...", style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
