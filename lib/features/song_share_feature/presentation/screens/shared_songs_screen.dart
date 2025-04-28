// lib/presentation/pages/shared_songs_page.dart
import 'package:dartz/dartz.dart' as dartz;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/core/dependency_injection.dart';
import 'package:jazz/features/auth_feature/domain/entities/user.dart';
import 'package:jazz/features/auth_feature/domain/repo/auth_repository.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/search_feature/domain/entities/thumbnails.dart';
import 'package:jazz/features/song_share_feature/domain/entities/shared_song.dart';
import 'package:jazz/features/song_share_feature/presentation/bloc/shared_song_bloc/shared_song_bloc.dart';
import 'package:jazz/features/song_share_feature/presentation/screens/song_details_screen.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';


class SharedSongsScreen extends StatefulWidget {
  const SharedSongsScreen({super.key});

  @override
  _SharedSongsScreenState createState() => _SharedSongsScreenState();
}

class _SharedSongsScreenState extends State<SharedSongsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Shared Songs'),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Received'),
              Tab(text: 'Sent'),
            ],
            onTap: (index) {
              // Load appropriate data based on selected tab
              if (index == 0) {
                context.read<SharedSongBloc>().add(GetReceivedSharedSongsEvent());
              } else {
                context.read<SharedSongBloc>().add(GetSentSharedSongsEvent());
              }
            },
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            ReceivedSongsTab(),
            SentSongsTab(),
          ],
        ),
      );

  }
}

class ReceivedSongsTab extends StatefulWidget {
  @override
  _ReceivedSongsTabState createState() => _ReceivedSongsTabState();
}

class _ReceivedSongsTabState extends State<ReceivedSongsTab> {
  @override
  void initState() {
    super.initState();
    context.read<SharedSongBloc>().add(GetReceivedSharedSongsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SharedSongBloc, SharedSongState>(
      builder: (context, state) {
        if (state is SharedSongLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is ReceivedSharedSongsLoaded) {
          if (state.sharedSongs.isEmpty) {
            return Center(child: Text('No songs shared with you yet'));
          }

          return ListView.builder(
            itemCount: state.sharedSongs.length,
            itemBuilder: (context, index) {
              final sharedSong = state.sharedSongs[index];
              return SharedSongCard(
                sharedSong: state.sharedSongs[index],
                showSender: true,
                onTap: () {
                  // Mark as viewed when tapped
                  context.read<SharedSongBloc>().add(
                    MarkSharedSongAsViewedEvent(state.sharedSongs[index].id),
                  );
                  // Navigate to song details or play the song
                  final isFromAlbum = context
                      .read<PlayerBloc>()
                      .state
                      .isFromAlbum;
                  if (isFromAlbum) {
                    context.read<PlayerBloc>().add(
                        UpdateStateEvent(state: context
                            .read<PlayerBloc>()
                            .state
                            .copyWith(isFromAlbum: false)));
                  }
                  context.read<PlayerBloc>().add(
                      PlaySongEvent(song: dartz.left(Song(
                          url: "",
                          title: sharedSong.songName,
                          artists: sharedSong.artistName,
                          id: sharedSong.songId,
                          category: sharedSong.type,
                          browseId: "",
                          thumbnails: YtThumbnails(
                              defaultThumbnail: YtThumbnail(
                                  url: sharedSong.albumArt,
                                  width: 60,
                                  height: 60),
                              mediumThumbnail: YtThumbnail(
                                  url: sharedSong.albumArt,
                                  width: 120,
                                  height: 120),
                              highThumbnail: YtThumbnail(
                                  url: sharedSong.albumArt,
                                  width: 226,
                                  height: 26)),
                          resultType: sharedSong.type,
                          duration: "",
                          album: null))));
                },
              );
            },
          );
        } else if (state is SharedSongError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return Center(child: Text('Select a tab to view shared songs'));
      },
    );
  }

}

class SentSongsTab extends StatefulWidget {
  @override
  _SentSongsTabState createState() => _SentSongsTabState();
}

class _SentSongsTabState extends State<SentSongsTab> {
  @override
  void initState() {
    super.initState();
    context.read<SharedSongBloc>().add(GetSentSharedSongsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SharedSongBloc, SharedSongState>(
      builder: (context, state) {
        if (state is SharedSongLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is SentSharedSongsLoaded) {
          if (state.sharedSongs.isEmpty) {
            return Center(child: Text('You haven\'t shared any songs yet'));
          }

          return ListView.builder(
            itemCount: state.sharedSongs.length,
            itemBuilder: (context, index) {
              return SharedSongCard(
                sharedSong: state.sharedSongs[index],
                showReceiver: true,
                onTap: () {
                  // Navigate to song details or play the song

                },
              );
            },
          );
        } else if (state is SharedSongError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return Center(child: Text('Select a tab to view shared songs'));
      },
    );
  }
}

class SharedSongCard extends StatelessWidget {
  final SharedSong sharedSong;
  final bool showSender;
  final bool showReceiver;
  final VoidCallback onTap;

  const SharedSongCard({
    Key? key,
    required this.sharedSong,
    this.showSender = false,
    this.showReceiver = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            sharedSong.albumArt,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 50,
                height: 50,
                color: Colors.grey[300],
                child: Icon(Icons.music_note, color: Colors.grey[600]),
              );
            },
          ),
        ),
        title: Text(
          sharedSong.songName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sharedSong.artistName.map((artist)=> artist['name']).join(',')),
            if (showSender)
              FutureBuilder<AppUser>(
                future: di<AuthRepository>().getUserById(sharedSong.senderId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading sender...');
                  }
                  if (snapshot.hasData) {
                    return Text(
                      'From: ${snapshot.data!.name}',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            if (showReceiver)
              FutureBuilder<AppUser>(
                future: di<AuthRepository>().getUserById(sharedSong.receiverId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading receiver...');
                  }
                  if (snapshot.hasData) {
                    return Text(
                      'To: ${snapshot.data!.name}',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            if (sharedSong.message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '"${sharedSong.message}"',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!sharedSong.isViewed && showSender)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            Icon(Icons.play_arrow),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
