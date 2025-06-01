import 'package:dartz/dartz.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';

import '../../features/download_feature/domain/entities/download_request.dart';
import '../../features/download_feature/presentation/bloc/DownloadedOrNotBloc/downloaded_or_not_bloc.dart';
import '../../features/download_feature/presentation/bloc/download/download_bloc.dart';
import '../../features/playlist_feature/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import '../../features/search_feature/domain/entities/song.dart';
import '../../features/search_feature/presentation/bloc/artist_bloc/artist_bloc.dart';
import '../../features/search_feature/presentation/widgets/share_user_selection.dart';
import '../../features/search_feature/presentation/widgets/user_selection_bottom_sheet.dart';
import '../../features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';
import '../app_color.dart';
import '../routes.dart';
import 'custom_snack_bar.dart';

Widget songWidget({
  required BuildContext context,
  required Song song,
   List<RelatedSong>? songs
}){
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: InkWell(
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      onTap: () {
        if(songs==null){
          context.read<PlayerBloc>().add(UpdateStateEvent(state: context.read<PlayerBloc>().state.copyWith(isFromAlbum: false)));
          context.read<PlayerBloc>().add(PlaySongEvent(song: left(song)));

        }else {
          context.read<PlayerBloc>().add(PlaySongEvent(
              song: left(song), albumTracks: songs
          ));
        }
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              song.thumbnails.highThumbnail.url,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  song.artists.map((artist) => artist['name'] as String).join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
              onTap: () {
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
                      return Column(
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
                                  const Color.fromRGBO(37, 39, 40, 1),
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
                                                const Text(
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
                                  Navigator.pushNamed(context, Routes.artistDetailScreen,arguments: {"artistId": song.artists.first['id']});
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
                                        return Column(
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
                                                          Navigator.pushNamed(context, Routes.artistDetailScreen,arguments: {"artistId": song.artists[index]['id']});
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
                      );
                    });
              },
              child: const Icon(Icons.more_horiz_outlined, color: Colors.white70)),
        ],
      ),
    ),
  );
}