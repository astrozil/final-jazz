import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/features/search_feature/domain/entities/album.dart';
import 'package:jazz/features/search_feature/presentation/bloc/search/search_bloc.dart';
 // Adjust the import path

class AlbumsResultScreen extends StatelessWidget {
  const AlbumsResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Albums")),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SearchLoaded) {
            final List<Album> albums = state.albums;
            if (albums.isEmpty) {
              return const Center(child: Text("No albums found."));
            }
            return ListView.builder(
              itemCount: albums.length,
              itemBuilder: (context, index) {
                final album = albums[index];
                return ListTile(
                  leading: album.ytThumbnail.url.isNotEmpty
                      ? Image.network(
                    album.ytThumbnail.url,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.album),
                  title: Text(album.title),
                  subtitle: Text("${album.artist} • ${album.year}"),
                  onTap: () {
                    // Optionally handle tap, e.g. navigate to an album details page.
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
