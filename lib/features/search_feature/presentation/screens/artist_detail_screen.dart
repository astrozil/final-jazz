import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/features/search_feature/domain/entities/artist.dart';
import 'package:jazz/features/search_feature/presentation/bloc/albumBloc/album_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/artist_bloc/artist_bloc.dart';
import 'package:jazz/features/search_feature/presentation/screens/album_Screen.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';

class ArtistDetailScreen extends StatelessWidget {
  const ArtistDetailScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artist Details'),
      ),
      body: BlocBuilder<ArtistBloc, ArtistState>(
        builder: (context, state) {
          if (state is ArtistInitial) {
            // Show a loading indicator while fetching data
            return const Center(child: CircularProgressIndicator());
          } else if (state is ArtistFetchError) {
            // Display error message if fetch fails
            return Center(child: Text('Error: ${state.errorMessage}'));
          } else if (state is ArtistFetchSuccess) {
            final Artist artist = state.artist;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display the first thumbnail if available.
                  if (artist.thumbnails.isNotEmpty)
                    Center(
                      child: Image.network(
                        artist.thumbnails.first.url, // adjust according to your YtThumbnail model
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    artist.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    artist.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  // Albums section.
                  if (artist.albums.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Albums', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: artist.albums.length,
                            itemBuilder: (context, index) {
                              final album = artist.albums[index];
                              return InkWell(
                                onTap: (){
                                  context.read<AlbumBloc>().add(SearchAlbum(albumId: album.browseId));
                                  Navigator.push(context, MaterialPageRoute(builder: (context){
                                    return AlbumScreen();
                                  }));
                                },
                                child: Card(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: Column(
                                    children: [
                                      // Adjust the property name to match your Album object.
                                      Image.network(
                                        album.ytThumbnail.url,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        album.title,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  // Singles section.
                  if (artist.singles.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Singles', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: artist.singles.length,
                          itemBuilder: (context, index) {
                            final single = artist.singles[index];
                            return ListTile(
                              leading: Image.network(
                                single.thumbnail.url,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              title: Text(single.title),
                              subtitle: Text(single.year),
                            );
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  // Songs section.
                  if (artist.songs.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Songs', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: artist.songs.length,
                          itemBuilder: (context, index) {
                            final song = artist.songs[index];
                            return ListTile(
                              leading: Image.network(

                               song.thumbnails.defaultThumbnail.url
                                    ,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              title: Text(song.title),
                              subtitle: Text( song.artists
                                  .map((artist) => artist['name'] as String)
                                  .join(', '),),
                              onTap: (){
                                final isFromAlbum = context.read<PlayerBloc>().state.isFromAlbum;
                                if(isFromAlbum){
                                  context.read<PlayerBloc>().add(UpdateStateEvent(state: context.read<PlayerBloc>().state.copyWith(isFromAlbum: false)));
                                }
                                context.read<PlayerBloc>().add(PlaySongEvent(song: left(song)));
                              },
                            );
                          },
                        ),
                      ],
                    ),
                ],
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
