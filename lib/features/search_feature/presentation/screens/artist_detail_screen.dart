import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/widgets/confirm_widget.dart';
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
      body: BlocBuilder<ArtistBloc, ArtistState>(
        builder: (context, state) {
          if (state is ArtistInitial) {
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
          } else if (state is ArtistFetchError) {
            return Center(
              child: Text(
                'Error: ${state.errorMessage}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (state is ArtistFetchSuccess) {
            final Artist artist = state.artist;
            return CustomScrollView(
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
                                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                              return ArtistBioScreen(bio: artist.description);
                                            }));
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
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(

                                     width: 50.w,
                                    alignment: Alignment.center,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8.r),
                                        child: Image.network(song.thumbnails.highThumbnail.url, height: 50.h,width: 50.w,fit: BoxFit.cover,)),
                                  ),
                                  title: Text(
                                    song.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    artist.name,
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 14,
                                    ),
                                  ),
                                  trailing: GestureDetector(
                                    onTap:  () {
                                      context.read<DownloadedOrNotBloc>().add(CheckIfDownloadedEvent(song.id,song.title,song.artists.first['name']));
                                      showModalBottomSheet(
                                          context: context,
                                          enableDrag: true,
                                          backgroundColor: const Color.fromRGBO(
                                              37, 39, 40, 1),
                                          shape: const RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.vertical(
                                                  top:
                                                  Radius.circular(
                                                      20))),
                                          builder: (context) {
                                            return Container(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        SizedBox(width: 80.w,),
                                                        Container(
                                                          margin: const EdgeInsets.only(top: 8),
                                                          height: 4,
                                                          width: 40,
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey[300],
                                                            borderRadius: BorderRadius.circular(2),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          },
                                                          child:  Text('Cancel',style: TextStyle(color: Colors.white.withOpacity(0.8)),),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 30.h,),
                                                  Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        context
                                                            .read<PlaylistBloc>()
                                                            .add(FetchPlaylists());
                                                        showModalBottomSheet(
                                                          context: context,
                                                          shape: const RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.vertical(
                                                                top: Radius.circular(20)),
                                                          ),
                                                          isScrollControlled: true,
                                                          backgroundColor:
                                                          Color.fromRGBO(37, 39, 40, 1),
                                                          builder: (_) => Padding(
                                                            padding: EdgeInsets.only(
                                                              bottom: MediaQuery.of(context)
                                                                  .viewInsets
                                                                  .bottom,
                                                            ),
                                                            child: Container(
                                                              width: double.infinity,
                                                              padding: const EdgeInsets.all(16),
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment.start,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(
                                                                        bottom: 16.0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                      children: [
                                                                        SizedBox(
                                                                          width: 80.w,
                                                                        ),
                                                                        Text(
                                                                          "Playlists",
                                                                          style: TextStyle(
                                                                            color: Colors.white,
                                                                            fontSize: 20,
                                                                          ),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed: () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child: Text(
                                                                            'Cancel',
                                                                            style: TextStyle(
                                                                                color: Colors.white
                                                                                    .withOpacity(
                                                                                    0.8)),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  BlocBuilder<PlaylistBloc,
                                                                      PlaylistState>(
                                                                    builder:
                                                                        (context, playlistState) {
                                                                      if (playlistState
                                                                      is PlaylistLoaded &&
                                                                          !playlistState.isLoading) {
                                                                        final playlists =
                                                                            playlistState
                                                                                .userPlaylists;
                                                                        if (playlists.isNotEmpty) {
                                                                          return Container(
                                                                            constraints:
                                                                            const BoxConstraints(
                                                                                maxHeight: 300),
                                                                            child: ListView.builder(
                                                                              shrinkWrap: true,
                                                                              itemCount:
                                                                              playlists.length,
                                                                              itemBuilder:
                                                                                  (context, index) {
                                                                                final playlist =
                                                                                playlists[index];
                                                                                return ListTile(

                                                                                  leading: Container(
                                                                                    width: 40,
                                                                                    height: 40,
                                                                                    decoration:
                                                                                    BoxDecoration(
                                                                                      color: Colors
                                                                                          .transparent,
                                                                                      borderRadius:
                                                                                      BorderRadius
                                                                                          .circular(
                                                                                          8),
                                                                                    ),
                                                                                    child: Icon(
                                                                                      Icons
                                                                                          .my_library_music,
                                                                                      color: Colors
                                                                                          .grey
                                                                                          .withOpacity(
                                                                                          0.5),
                                                                                      size: 40.sp,
                                                                                    ),
                                                                                  ),
                                                                                  title: Text(
                                                                                    playlist['title'],
                                                                                    style: const TextStyle(
                                                                                        color: Colors
                                                                                            .white),
                                                                                  ),
                                                                                  subtitle: Text(
                                                                                    "${playlist['tracks'].length} songs",
                                                                                    style: TextStyle(
                                                                                        color: Colors
                                                                                            .grey[
                                                                                        400]),
                                                                                  ),
                                                                                  onTap: () {

                                                                                    context
                                                                                        .read<
                                                                                        PlaylistBloc>()
                                                                                        .add(
                                                                                        AddSongToPlaylist(
                                                                                          songId:
                                                                                          song.id,
                                                                                          playlistId:
                                                                                          playlist['playlistId'],
                                                                                        ));
                                                                                    Navigator.pop(
                                                                                        context);
                                                                                    ScaffoldMessenger.of(context)
                                                                                        .hideCurrentSnackBar();
                                                                                    ScaffoldMessenger.of(context)
                                                                                        .showSnackBar(CustomSnackBar.show(
                                                                                        message:
                                                                                        "Added to your playlist",
                                                                                        backgroundColor: AppColors
                                                                                            .snackBarBackgroundColor)

                                                                                    );
                                                                                  },
                                                                                );
                                                                              },
                                                                            ),
                                                                          );
                                                                        }
                                                                      }
                                                                      return SizedBox(
                                                                        height: 100,
                                                                        child: Center(
                                                                          child: Text(
                                                                            "No playlists found. Create one.",
                                                                            style: TextStyle(
                                                                                color:
                                                                                Colors.grey[400]),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                  const SizedBox(height: 16),
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      Navigator.pushNamed(context,
                                                                          Routes.newPlaylistScreen);
                                                                    },
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor: Colors.white,
                                                                      foregroundColor: Colors.black,
                                                                      minimumSize: const Size(
                                                                          double.infinity, 50),
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                        BorderRadius.circular(15),
                                                                      ),
                                                                    ),
                                                                    child: const Row(
                                                                      mainAxisAlignment:
                                                                      MainAxisAlignment.center,
                                                                      children: [
                                                                        Icon(Icons.add, size: 20),
                                                                        SizedBox(width: 8),
                                                                        Text("Create New Playlist"),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.playlist_add,color: Colors.grey.withOpacity(0.6),size: 25,),
                                                          SizedBox(width: 20.w,),
                                                          Text("Add to playlist", style: TextStyle(color: Colors.white, fontSize: 18.sp ),)
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  BlocBuilder<DownloadedOrNotBloc, DownloadedOrNotState>(
                                                    builder: (context, state) {
                                                      if(state is DownloadedSongState){
                                                        return  Padding(
                                                          padding: const EdgeInsets.all(16.0),
                                                          child: InkWell(
                                                            splashFactory: NoSplash.splashFactory,
                                                            highlightColor: Colors.transparent,
                                                            onTap: (){
                                                              Navigator.pop(context);
                                                              context.read<DownloadedOrNotBloc>().add(DeleteDownloadedSongEvent(song.id, song.title,song.artists.first['name']));
                                                              ScaffoldMessenger.of(context)
                                                                  .hideCurrentSnackBar();
                                                              ScaffoldMessenger.of(context)
                                                                  .showSnackBar(CustomSnackBar.show(
                                                                  message:
                                                                  "Removed from downloaded content",
                                                                  backgroundColor: AppColors
                                                                      .snackBarBackgroundColor));
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Image.asset("assets/icons/downloaded.png"),
                                                                SizedBox(width: 20.w,),
                                                                Text("Remove from downloaded content", style: TextStyle(color: Colors.white, fontSize: 18.sp ),)
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }else{
                                                        return  Padding(
                                                          padding: const EdgeInsets.all(16.0),
                                                          child: InkWell(
                                                            splashFactory: NoSplash.splashFactory,
                                                            highlightColor: Colors.transparent,
                                                            onTap: (){
                                                              Navigator.pop(context);
                                                              context.read<DownloadBloc>().add(
                                                                  DownloadSongEvent(DownloadRequest(videoID:song.id,title: song.title,artist: song.artists.first['name'],thumbnail:song.thumbnails.highThumbnail.url,videoUrl: "https://www.youtube.com/watch?v=${song.id}")));
                                                              ScaffoldMessenger.of(context)
                                                                  .hideCurrentSnackBar();
                                                              ScaffoldMessenger.of(context)
                                                                  .showSnackBar(CustomSnackBar.show(
                                                                  message:
                                                                  "Added to download queue",
                                                                  backgroundColor: AppColors
                                                                      .snackBarBackgroundColor));
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Image.asset("assets/icons/download.png"),
                                                                SizedBox(width: 20.w,),
                                                                Text("Download", style: TextStyle(color: Colors.white, fontSize: 18.sp ),)
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: InkWell(
                                                      splashFactory: NoSplash.splashFactory,
                                                      highlightColor: Colors.transparent,
                                                      onTap: (){
                                                        Navigator.pop(context);
                                                        if(song.artists.length==1){
                                                          context.read<ArtistBloc>().add(FetchArtistEvent(artistId: song.artists.first['id']));
                                                          Navigator.pushNamed(context, Routes.artistDetailScreen);
                                                        }else if(song.artists.length >1){
                                                          showModalBottomSheet(
                                                              context: context,
                                                              enableDrag: true,
                                                              backgroundColor: const Color.fromRGBO(
                                                                  37, 39, 40, 1),
                                                              shape: const RoundedRectangleBorder(
                                                                  borderRadius:
                                                                  BorderRadius.vertical(
                                                                      top:
                                                                      Radius.circular(
                                                                          20))),
                                                              builder: (context){
                                                                return Container(
                                                                    child: Column(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                                                          child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              SizedBox(width: 80.w,),
                                                                              Container(
                                                                                margin: const EdgeInsets.only(top: 8),
                                                                                height: 4,
                                                                                width: 40,
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.grey[300],
                                                                                  borderRadius: BorderRadius.circular(2),
                                                                                ),
                                                                              ),
                                                                              TextButton(
                                                                                onPressed: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child:  Text('Cancel',style: TextStyle(color: Colors.white.withOpacity(0.8)),),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        SizedBox(height: 30.h,),
                                                                        SizedBox(
                                                                          height: 200.h,
                                                                          child: ListView.builder(
                                                                              itemCount: song.artists.length,
                                                                              itemBuilder: (context,index){
                                                                                return Padding(
                                                                                  padding: const EdgeInsets.all(16.0),
                                                                                  child: InkWell(
                                                                                    splashFactory: NoSplash.splashFactory,
                                                                                    highlightColor: Colors.transparent,
                                                                                    onTap: (){
                                                                                      context.read<ArtistBloc>().add(FetchArtistEvent(artistId: song.artists[index]['id']));
                                                                                      Navigator.pushNamed(context, Routes.artistDetailScreen);
                                                                                    },
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Image.asset("assets/icons/artist.png"),
                                                                                        SizedBox(width: 20.w,),
                                                                                        Text(song.artists[index]['name'], style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.normal ),)
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              }
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                );
                                                              });
                                                        }
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Image.asset("assets/icons/artist.png"),
                                                          SizedBox(width: 20.w,),
                                                          Text("Go to artist", style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.normal ),)
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        showCustomBottomSheet(
                                                            context: context,
                                                            builder: (context) =>
                                                                UserSelectionBottomSheet(
                                                                    song: song),
                                                            backgroundColor: AppColors
                                                                .primaryBackgroundColor);
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Image.asset("assets/icons/share.png",color: Colors.grey.withOpacity(0.6),),
                                                          SizedBox(width: 20.w,),
                                                          Text("Share", style: TextStyle(color: Colors.white, fontSize: 18.sp ),)
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 50.h,),
                                                ],
                                              ),
                                            );
                                          });
                                    },
                                    child: Icon(
                                      Icons.more_horiz_outlined, color: Colors.white60, size: 20,

                                    ),
                                  ),
                                  onTap: () {
                                    final isFromAlbum = context.read<PlayerBloc>().state.isFromAlbum;
                                    if (isFromAlbum) {
                                      context.read<PlayerBloc>().add(
                                          UpdateStateEvent(
                                              state: context.read<PlayerBloc>().state.copyWith(isFromAlbum: false)
                                          )
                                      );
                                    }
                                    context.read<PlayerBloc>().add(PlaySongEvent(song: dartz.left(song)));
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                        ],

                        // Featured Albums Section
                        if (artist.albums.isNotEmpty) ...[
                          _buildSectionHeaderWithViewAll(context, 'Featured Albums', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllAlbumsScreen(albums: artist.albums, artistName: artist.name),
                              ),
                            );
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
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => AlbumScreen()),
                                          );
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllSinglesScreen(singles: artist.singles, artistName: artist.name),
                              ),
                            );
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => AlbumScreen()),
                                    );
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
