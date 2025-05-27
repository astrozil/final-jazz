import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/core/widgets/confirm_widget.dart';
import 'package:jazz/features/playlist_feature/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';

import '../../../../core/widgets/custom_snack_bar.dart';
import '../../../download_feature/domain/entities/download_request.dart';
import '../../../download_feature/presentation/bloc/DownloadedOrNotBloc/downloaded_or_not_bloc.dart';
import '../../../download_feature/presentation/bloc/download/download_bloc.dart';
import '../../../download_feature/presentation/bloc/downloadedSongsBloc/downloaded_songs_bloc.dart';
import '../../../download_feature/presentation/screens/downloaded_songs_screen.dart';
import '../../../search_feature/presentation/bloc/artist_bloc/artist_bloc.dart';
import '../../../search_feature/presentation/widgets/share_user_selection.dart';
import '../../../search_feature/presentation/widgets/user_selection_bottom_sheet.dart';

class SpecifiedUserPlaylistScreen extends StatefulWidget {

  const SpecifiedUserPlaylistScreen({super.key,});

  @override
  State<SpecifiedUserPlaylistScreen> createState() => _SpecifiedUserPlaylistScreenState();
}

class _SpecifiedUserPlaylistScreenState extends State<SpecifiedUserPlaylistScreen> {
  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),


      ),
      body: BlocBuilder<PlaylistBloc, PlaylistState>(
        builder: (context, state) {
          if (state is PlaylistLoaded && !state.isLoading) {
            final playlist = state.userPlaylist;
            final songs = state.songsFromSongIdList;


            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Album Cover - Single image or grid based on track count
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildAlbumCover(songs),
                  ),
                ),

                // Playlist Info
                SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          playlist["title"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        const SizedBox(height: 8),
                        Text(
                          "${songs.length} TRACKS",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Play and Shuffle Buttons
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (songs.isNotEmpty) {
                                context.read<PlayerBloc>().add(
                                    PlaySongEvent(song: dartz.left(songs.first.song), albumTracks: songs)
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.play_arrow),
                                SizedBox(width: 8),
                                Text(
                                  "Play",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final List<RelatedSong> shuffleSongs = List.from(state.songsFromSongIdList);
                              shuffleSongs.shuffle();

                              context.read<PlayerBloc>().add(
                                  PlaySongEvent(song: dartz.left(shuffleSongs.first.song), albumTracks: shuffleSongs)
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shuffle),
                                SizedBox(width: 8),
                                Text(
                                  "Shuffle",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Action Buttons
                SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(Icons.edit, "Edit",playlist["title"],playlist["playlistId"]),
                      GestureDetector(
                        onTap: (){
                          showDialog(context: context, builder: (context){
                            return confirmWidget(context: context,
                                title: "Delete playlist?",
                                text: "This playlist will be permanently deleted.",
                                confirmButton: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    onPressed: (){
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      context.read<PlaylistBloc>().add(DeletePlaylist(playlist["playlistId"]));
                                      context.read<PlaylistBloc>().add(FetchPlaylists());
                                    },
                                    child: const Text("Delete",style: TextStyle(color: Colors.white),)));
                          });
                        },
                        child: Column(
                          children: [
                            SizedBox(height: 10.h,),
                            Image.asset(
                              "assets/icons/delete.png",
                              height: 30.h,

                              width: 30.w,
                              color: Colors.red,

                            ),
                            SizedBox(height: 10.h,),
                            const Text(
                              "Delete",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )


                    ],
                  ),
                ),

                // Song List
                SliverPadding(
                  padding: const EdgeInsets.only(top: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final song = songs[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: InkWell(
                            onTap: () {
                              context.read<PlayerBloc>().add(PlaySongEvent(
                                  song: dartz.left(song.song), albumTracks: songs
                              ));
                            },
                            child: Row(
                              children: [
                                Hero(
                                  tag: 'song_image_${song.song.id}',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      song.song.thumbnails.defaultThumbnail.url,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        song.song.title,
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
                                        song.song.artists.map((artist) => artist['name'] as String).join(', '),
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
                                        context.read<DownloadedOrNotBloc>().add(CheckIfDownloadedEvent(song.song.id,song.song.title,song.song.artists.first['name']));
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
                                                                context.read<DownloadedOrNotBloc>().add(DeleteDownloadedSongEvent(song.song.id, song.song.title,song.song.artists.first['name']));

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
                                                                    DownloadSongEvent(DownloadRequest(videoID:song.song.id,title: song.song.title,artist: song.song.artists.first['name'],thumbnail:song.song.thumbnails.highThumbnail.url,videoUrl: "https://www.youtube.com/watch?v=${song.song.id}")));
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
                                                    )
                                                    ,
                                                    Padding(
                                                      padding: const EdgeInsets.all(16.0),
                                                      child: InkWell(
                                                        splashFactory: NoSplash.splashFactory,
                                                        highlightColor: Colors.transparent,
                                                        onTap: (){
                                                          Navigator.pop(context);
                                                          if(song.song.artists.length==1){
                                                            context.read<ArtistBloc>().add(FetchArtistEvent(artistId: song.song.artists.first['id']));
                                                            Navigator.pushNamed(context, Routes.artistDetailScreen,arguments: {"artistId": song.song.artists.first['id']});
                                                          }else if(song.song.artists.length >1){
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
                                                                                itemCount: song.song.artists.length,
                                                                                itemBuilder: (context,index){
                                                                                  return Padding(
                                                                                    padding: const EdgeInsets.all(16.0),
                                                                                    child: InkWell(
                                                                                      splashFactory: NoSplash.splashFactory,
                                                                                      highlightColor: Colors.transparent,
                                                                                      onTap: (){
                                                                                        context.read<ArtistBloc>().add(FetchArtistEvent(artistId: song.song.artists[index]['id']));
                                                                                        Navigator.pushNamed(context, Routes.artistDetailScreen,arguments: {"artistId": song.song.artists[index]['id']});
                                                                                      },
                                                                                      child: Row(
                                                                                        children: [
                                                                                          Image.asset("assets/icons/artist.png"),
                                                                                          SizedBox(width: 20.w,),
                                                                                          Text(song.song.artists[index]['name'], style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.normal ),)
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
                                                        onTap:(){
                                                          Navigator.pop(context);
                                                          ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar.show(message: "Song has been removed from playlist."));
                                                   context.read<PlaylistBloc>().add(RemoveSongFromPlaylist(songId: song.song.id, playlistId: playlist["playlistId"]));
                                                   final newSongList = playlist['tracks'];
                                                   newSongList.removeAt(index);

                                                   context.read<PlaylistBloc>().add(FetchSongsFromSongIdList(songIdList: newSongList,playlistId: playlist["playlistId"]));
                                              },    
                                                        child: Row(
                                                          children: [
                                                            Image.asset("assets/icons/delete.png",color: Colors.red,height: 30.h,width: 30.w,),
                                                            SizedBox(width: 20.w,),
                                                            Text("Remove from playlist", style: TextStyle(color: Colors.white, fontSize: 18.sp ),)
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
                                                                      song: song.song),
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
                                      child: const Icon(Icons.more_horiz_outlined, color: Colors.white70)),


                              ],
                            ),
                          ),
                        );
                      },
                      childCount: songs.length,
                    ),
                  ),
                ),
              ],
            );
          }

          // Loading state
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildAlbumCover(List<dynamic> songs) {
    if (songs.isEmpty) {
      // Fallback for empty songs list
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.music_note, size: 80, color: Colors.white70),
          ),
        ),
      );
    }

    // For a single track, show a large image
    if (songs.length == 1) {
      return AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            songs[0].song.thumbnails.highThumbnail.url,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // For multiple tracks, show a grid
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: AspectRatio(
          aspectRatio: 1,
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _buildAlbumGridItems(songs),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAlbumGridItems(List<dynamic> songs) {
    final List<Widget> gridItems = [];

    // Logic based on track count
    if (songs.length == 2) {
      // For 2 tracks: pattern [1,2,1,2]
      gridItems.add(_buildGridItem(songs[0]));
      gridItems.add(_buildGridItem(songs[1]));
      gridItems.add(_buildGridItem(songs[0]));
      gridItems.add(_buildGridItem(songs[1]));
    } else if (songs.length == 3) {
      // For 3 tracks: pattern [1,2,3,1]
      gridItems.add(_buildGridItem(songs[0]));
      gridItems.add(_buildGridItem(songs[1]));
      gridItems.add(_buildGridItem(songs[2]));
      gridItems.add(_buildGridItem(songs[0]));
    } else {
      // For 4 or more tracks: show first 4 tracks
      for (int i = 0; i < 4 && i < songs.length; i++) {
        gridItems.add(_buildGridItem(songs[i]));
      }
    }

    return gridItems;
  }

  Widget _buildGridItem(dynamic song) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        song.song.thumbnails.highThumbnail.url,
        height: 20.h,
        width: 20.w,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label,String playlistTitle,String playlistId) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white70),
          onPressed: () {
            Navigator.pushNamed(context, Routes.userPlaylistTitleUpdateScreen,arguments: {"playlistTitle": playlistTitle,"playlistId":playlistId});
          },
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
