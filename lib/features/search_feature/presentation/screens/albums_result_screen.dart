import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/features/search_feature/domain/entities/album.dart';
import 'package:jazz/features/search_feature/presentation/bloc/albumBloc/album_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/search/search_bloc.dart';
import 'package:jazz/features/search_feature/presentation/screens/album_Screen.dart';

class AlbumsResultScreen extends StatelessWidget {
  const AlbumsResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.primaryBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Albums',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.white,));
          } else if (state is SearchLoaded) {
            final List<Album> albums = state.albums;
            if (albums.isEmpty) {
              return const Center(
                child: Text(
                  "No albums found.",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                physics: BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: albums.length,
                itemBuilder: (context, index) {
                  final album = albums[index];
                  return GestureDetector(
                    onTap: () {
                      print(album.browseId);
                      context.read<AlbumBloc>().add(
                          SearchAlbum(albumId: album.browseId)
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AlbumScreen()),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: album.ytThumbnail.url.isNotEmpty
                                  ? DecorationImage(
                                image: NetworkImage(album.ytThumbnail.url),
                                fit: BoxFit.cover,
                              )
                                  : null,
                            ),
                            child: album.ytThumbnail.url.isEmpty
                                ? const Center(
                              child: Icon(
                                Icons.album,
                                size: 50,
                                color: Colors.white54,
                              ),
                            )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          album.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          album.artist,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (album.year != null)
                          Text(
                            album.year.toString(),
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            );
          } else if (state is SearchError) {
            return Center(
              child: Text(
                "Error: ${state.message}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
