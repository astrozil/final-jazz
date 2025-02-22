import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/search_feature/presentation/bloc/search/search_bloc.dart';
 // Adjust the import path as needed

class SongsResultScreen extends StatelessWidget {
  const SongsResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Songs")),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SearchLoaded) {
            final List<Song> songs = state.songs;
            if (songs.isEmpty) {
              return const Center(child: Text("No songs found."));
            }
            return ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return ListTile(
                  leading: song.thumbnails.defaultThumbnail.url.isNotEmpty
                      ? Image.network(
                    song.thumbnails.defaultThumbnail.url,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.music_note),
                  title: Text(song.title),
                  subtitle: Text(song.artist),
                  onTap: () {
                    // Optionally handle tap, e.g., navigate to a song details page.
                  },
                );
              },
            );
          } else if (state is SearchError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return Container();
        },
      ),
    );
  }
}
