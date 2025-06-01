import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/widgets/confirm_widget.dart';
import 'package:jazz/core/widgets/song_widget.dart';
import 'package:jazz/features/auth_feature/domain/entities/user.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:jazz/features/search_feature/domain/entities/artist.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/search_feature/domain/entities/thumbnails.dart';
import 'package:jazz/features/search_feature/presentation/bloc/albumBloc/album_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/artist_bloc/artist_bloc.dart';
import 'package:jazz/features/search_feature/presentation/screens/album_Screen.dart';
import 'package:jazz/features/search_feature/presentation/screens/all_albums_screen.dart';
import 'package:jazz/features/search_feature/presentation/screens/all_singles_screen.dart';
import 'package:jazz/features/search_feature/presentation/screens/artist_bio_screen.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';
import 'package:dartz/dartz.dart' as dartz;

import '../../../../core/app_color.dart';
import '../../../../core/routes.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import '../../../download_feature/domain/entities/download_request.dart';
import '../../../download_feature/presentation/bloc/DownloadedOrNotBloc/downloaded_or_not_bloc.dart';
import '../../../download_feature/presentation/bloc/download/download_bloc.dart';
import '../../../playlist_feature/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import '../widgets/share_user_selection.dart';
import '../widgets/user_selection_bottom_sheet.dart';

class ArtistDetailScreen extends StatefulWidget {
  final String artistId;
  const ArtistDetailScreen({super.key,required this.artistId});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  @override
  void initState() {
    context.read<UserBloc>().add(FetchFavouriteArtists());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: AppColors.primaryBackgroundColor,
      body: BlocBuilder<ArtistBloc, ArtistFetchSuccess>(
        builder: (context, state) {
          if (state.isLoading) {
            return CustomScrollView(
              slivers: [
                // Keep the SliverAppBar visible during loading
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.height,
                  pinned: true,
                  backgroundColor: AppColors.primaryBackgroundColor,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(

                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ),
                ),


              ],
            );
          }  else if (!state.isLoading) {
            final Artist artist = state.artist!;
            return CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                // Hero Section with Artist Image
                SliverAppBar(
                  expandedHeight: 450,
                  pinned: true,
                  backgroundColor: AppColors.primaryBackgroundColor,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),

                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Artist Image
                        if (artist.thumbnails.isNotEmpty)
                          Image.network(
                            artist.thumbnails.first.url,
                            fit: BoxFit.cover,
                          ),
                        // Gradient Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                                Colors.black,
                              ],
                            ),
                          ),
                        ),
                        // Artist Name and Controls
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [
                              Text(
                                artist.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              // Play and Shuffle Buttons
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          if (artist.songs.isNotEmpty) {
                                            final song = artist.songs.first;
                                            final List<RelatedSong> relatedSongs = [];
                                            for(var relatedSong in artist.songs){
                                              relatedSongs.add(RelatedSong(url: "", song: relatedSong));
                                            }
                                            context.read<PlayerBloc>().add(
                                                PlaySongEvent(song: dartz.left(song),albumTracks: relatedSongs)
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.play_arrow, color: Colors.black, size: 20),
                                        label: const Text(
                                          'Play',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          if (artist.songs.isNotEmpty) {
                                            final List<RelatedSong> relatedSongs = [];
                                            for(var relatedSong in artist.songs){
                                              relatedSongs.add(RelatedSong(url: "", song: relatedSong));
                                            }
                                            final List<RelatedSong> tempSongList = List.from(relatedSongs);
                                            tempSongList.shuffle();
                                            context.read<PlayerBloc>().add(
                                                PlaySongEvent(song: dartz.left(tempSongList.first.song),albumTracks: tempSongList)
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.shuffle, color: Colors.white, size: 20),
                                        label: const Text(
                                          'Shuffle',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white.withOpacity(0.3),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Follow and Share Icons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  BlocBuilder<UserBloc, FetchedUserData>(
                                    builder: (context, state) {
                                        if(state.isLoading) {
                                        return  Column(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: IconButton(
                                                  onPressed: () {},
                                                  icon: const Icon(Icons.add,
                                                      color: Colors.white,
                                                      size: 24),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              const Text(
                                                'Follow',
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          );

                                    }else if(!state.isLoading){
                                          AppUser user = state.user;

                                          if(user.favouriteArtists.contains(widget.artistId)){

                                          return  Column(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      user.favouriteArtists.remove(widget.artistId);
                                                      context.read<AuthBloc>().add(UpdateUserProfileEvent(favouriteArtists: user.favouriteArtists));
                                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar.show(message: "You have unfollowed ${artist.name}."));
                                                    },
                                                    icon: const Icon(Icons.done,
                                                        color: Colors.white,
                                                        size: 24),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                const Text(
                                                  'Following',
                                                  style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12),
                                                ),
                                              ],
                                            );
                                          }else{
                                            return  Column(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      user.favouriteArtists.add(widget.artistId);
                                                      context.read<AuthBloc>().add(
                                                          UpdateUserProfileEvent(favouriteArtists: user.favouriteArtists));
                                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar.show(message: "You are now following ${artist.name}."));

                                                    },
                                                    icon: const Icon(Icons.add,
                                                        color: Colors.white,
                                                        size: 24),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                const Text(
                                                  'Follow',
                                                  style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12),
                                                ),
                                              ],
                                            );
                                          }
                                        }
                                        return const SizedBox();
                                    },
                                  ),

                                  const SizedBox(width: 48),
                                  Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                           Navigator.pushNamed(context, Routes.artistBioScreen,arguments: {'bio':artist.description});
                                          },
                                          icon: const Icon(Icons.info_outline, color: Colors.white, size: 24),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Bio',
                                        style: TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content Sections
                SliverToBoxAdapter(
                  child: Container(
                    color: AppColors.primaryBackgroundColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // Top Tracks Section (Show ALL songs, no VIEW ALL button)
                        if (artist.songs.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Top Tracks',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: artist.songs.length, // Show ALL songs
                            itemBuilder: (context, index) {
                              final song = artist.songs[index];
                              return songWidget(context: context, song: song);
                            },
                          ),
                          const SizedBox(height: 32),
                        ],

                        // Featured Albums Section
                        if (artist.albums.isNotEmpty) ...[
                          _buildSectionHeaderWithViewAll(context, 'Featured Albums', () {
                            Navigator.pushNamed(context, Routes.allAlbumScreen,arguments: {"albums": artist.albums,"artistName": artist.name});
                          }),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 250.h,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              itemCount: artist.albums.length,
                              itemBuilder: (context, index) {
                                final album = artist.albums[index];
                                return Container(
                                  width: 160.w,
                                  margin: const EdgeInsets.only(right: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          context.read<AlbumBloc>().add(
                                              SearchAlbum(albumId: album.browseId)
                                          );
                                        Navigator.pushNamed(context, Routes.albumScreen);
                                        },
                                        child: Container(
                                          height: 160,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            image: DecorationImage(
                                              image: NetworkImage(album.ytThumbnail.url),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        album.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        artist.name,
                                        style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 13,
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
                          ),
                          const SizedBox(height: 32),
                        ],

                        // EP & Singles Section
                        if (artist.singles.isNotEmpty) ...[
                          _buildSectionHeaderWithViewAll(context, 'EP & Singles', () {
                           Navigator.pushNamed(context, Routes.allSingleScreen,arguments: {"singles":artist.singles,"artistName": artist.name});
                          }),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 250.h,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              itemCount: artist.singles.length,
                              itemBuilder: (context, index) {
                                final single = artist.singles[index];
                                return GestureDetector(
                                  onTap: (){
                                    context.read<AlbumBloc>().add(
                                        SearchAlbum(albumId: single.browseId)
                                    );
                                  Navigator.pushNamed(context, Routes.albumScreen);
                                  },
                                  child: Container(
                                    width: 170.w,
                                    margin: const EdgeInsets.only(right: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 160,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            image: DecorationImage(
                                              image: NetworkImage(single.thumbnail.url),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          single.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          artist.name,
                                          style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          single.year,
                                          style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return Container(color: Colors.black);
        },
      ),
    );
  }

  Widget _buildSectionHeaderWithViewAll(BuildContext context, String title, VoidCallback onViewAllTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: onViewAllTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'VIEW ALL',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
