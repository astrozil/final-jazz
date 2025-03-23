import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/features/playlist_feature/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';


class SuggestedSongsOfFavouriteArtistsPlaylistScreen extends StatelessWidget {
  const SuggestedSongsOfFavouriteArtistsPlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Suggested Songs"),
      ),
      body: BlocBuilder<PlaylistBloc, PlaylistState>(
        builder: (context, state) {
          if (state is PlaylistInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PlaylistLoaded) {
            return _buildSongList(state.suggestedSongsOfFavouriteArtists);
          } else if (state is PlaylistError) {
            return Center(child: Text("Error: ${state.errorMessage}"));
          } else {
            return const Center(child: Text("Unexpected state"));
          }
        },
      ),
    );
  }

  Widget _buildSongList(List<RelatedSong> songs) {
    if (songs.isEmpty) {
      return const Center(child: Text("No suggested songs available"));
    }

    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          leading: song.song.thumbnails.defaultThumbnail.url.isNotEmpty
              ? Image.network(song.song.thumbnails.defaultThumbnail.url, width: 50, height: 50, fit: BoxFit.cover)
              : const Icon(Icons.music_note, size: 50),
          title: Text(song.song.title),
          subtitle: Text( song.song.artists
              .map((artist) => artist['name'] as String)
              .join(', '),) ,
          onTap: (){
            context.read<PlayerBloc>().add(PlaySongEvent(song: left(song.song),albumTracks: songs));
          },

        );
      },
    );
  }
}
