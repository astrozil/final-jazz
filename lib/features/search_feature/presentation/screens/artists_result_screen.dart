import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/features/search_feature/domain/entities/artist.dart';
import 'package:jazz/features/search_feature/presentation/bloc/artist_bloc/artist_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/search/search_bloc.dart';
import 'package:jazz/features/search_feature/presentation/screens/artist_detail_screen.dart';
 // Adjust the import path

class ArtistsResultScreen extends StatelessWidget {
  const ArtistsResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Artists")),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SearchLoaded) {
            final List<Artist> artists = state.artists;
            if (artists.isEmpty) {
              return const Center(child: Text("No artists found."));
            }
            return ListView.builder(
              itemCount: artists.length,
              itemBuilder: (context, index) {
                final artist = artists[index];
                return ListTile(
                  leading: artist.thumbnails.isNotEmpty &&
                      artist.thumbnails[0].url.isNotEmpty
                      ? Image.network(
                    artist.thumbnails[0].url,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.person),
                  title: Text(artist.name),
                  subtitle: Text(artist.category),
                  onTap: () {
                    context.read<ArtistBloc>().add(FetchArtistEvent(artistId: artist.browseId));
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return ArtistDetailScreen(artistId: artist.browseId,);
                    }));
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
