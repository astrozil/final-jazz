import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/features/playlist_feature/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';


class BillboardSongsPlaylistScreen extends StatelessWidget {
  const BillboardSongsPlaylistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billboard Songs'),
      ),
      body: BlocBuilder<PlaylistBloc, PlaylistState>(
        builder: (context, state) {
          if (state is PlaylistInitial) {
            // While fetching data, show a loading indicator.
            return const Center(child: CircularProgressIndicator());
          } else if (state is PlaylistLoaded) {
            final songs = state.billboardSongsPlaylist;
            if (songs.isEmpty) {
              return const Center(child: Text('No Billboard Songs available'));
            }
            // Build a list view of Billboard songs.
            return ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    leading: song.song.thumbnails.defaultThumbnail.url != null && song.song.thumbnails.defaultThumbnail.url.isNotEmpty
                        ? Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(song.song.thumbnails.defaultThumbnail.url),
                          radius: 24,
                        ),
                        // Overlay the current rank on the image.
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${song.rank}',
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        )
                      ],
                    )
                        : CircleAvatar(child: Text('${song.rank}')),
                    title: Text(song.song.title),
                    subtitle: Text('Peak Position: ${song.peakPos} | Weeks: ${song.weeks}'),
                    trailing: Text('Last Week: ${song.lastPos}'),
                    onTap: (){
                      context.read<PlayerBloc>().add(PlaySongEvent(song: left(song.song),albumTracks: songs));
                    },
                  ),
                );
              },
            );
          } else if (state is PlaylistError) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
