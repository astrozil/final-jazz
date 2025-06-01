import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/features/search_feature/domain/entities/artist.dart';
import 'package:jazz/features/search_feature/presentation/bloc/artist_bloc/artist_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/search/search_bloc.dart';
import 'package:jazz/features/search_feature/presentation/screens/artist_detail_screen.dart';

class ArtistsResultScreen extends StatelessWidget {
  const ArtistsResultScreen({super.key});

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
          'Artists',
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
            final List<Artist> artists = state.artists;
            if (artists.isEmpty) {
              return const Center(
                child: Text(
                  "No artists found.",
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
                itemCount: artists.length,
                itemBuilder: (context, index) {
                  final artist = artists[index];
                  return GestureDetector(
                    onTap: () {

                      context.read<ArtistBloc>().add(
                          FetchArtistEvent(artistId: artist.browseId)
                      );
                     Navigator.pushNamed(context, Routes.artistDetailScreen,arguments: {"artistId": artist.browseId});
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: artist.thumbnails.isNotEmpty &&
                                  artist.thumbnails[0].url.isNotEmpty
                                  ? DecorationImage(
                                image: NetworkImage(artist.thumbnails[0].url),
                                fit: BoxFit.cover,
                              )
                                  : null,
                            ),
                            child: artist.thumbnails.isEmpty ||
                                artist.thumbnails[0].url.isEmpty
                                ? const Center(
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white54,
                              ),
                            )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          artist.name,
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
                          artist.category,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
