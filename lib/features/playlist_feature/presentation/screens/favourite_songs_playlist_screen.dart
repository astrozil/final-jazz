import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:jazz/features/playlist_feature/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';

class FavouriteSongsPlaylistScreen extends StatelessWidget {
  const FavouriteSongsPlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Favourite Songs"),),
      body: BlocBuilder<PlaylistBloc, PlaylistState>(
        builder: (context, state) {
          print(state);
      if (state is PlaylistInitial) {
        // While data is loading, show a spinner.
        return const Center(child: CircularProgressIndicator());
      } else if (state is PlaylistLoaded) {
        // When loaded, display the list of trending songs.
        final songs = state.favouriteSongsPlaylist;
        return ListView.builder(
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            return ListTile(
              leading: Image.network(
                // Adjust this property based on your YtThumbnails implementation.
                song.song.thumbnails.defaultThumbnail.url,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(song.song.title),
              subtitle:  Text( song.song.artists
                  .map((artist) => artist['name'] as String)
                  .join(', '),) ,
              onTap: (){
                context.read<PlayerBloc>().add(PlaySongEvent(song: left(song.song),albumTracks: songs));
              },
            );
          },
        );
      } else if (state is PlaylistError) {
        // If an error occurs, display it.
        return Center(
          child: Text(
            'Error: ${state.errorMessage}',
            style: const TextStyle(color: Colors.red),
          ),
        );
      }
      return Container();
    },

      ),
    );
  }
}
