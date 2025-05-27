import 'dart:math';
import 'dart:ui';

import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/features/auth_feature/domain/entities/user.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:jazz/features/auth_feature/presentation/screens/email_change_screen.dart';
import 'package:jazz/features/lyrics_feature/presentation/bloc/lyrics_bloc/lyrics_bloc.dart';
import 'package:jazz/features/lyrics_feature/presentation/screens/lyrics_screen.dart';
import 'package:jazz/features/playlist_feature/domain/repositories/playlist_repo.dart';
import 'package:jazz/features/playlist_feature/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/search_feature/presentation/bloc/artist_bloc/artist_bloc.dart';
import 'package:jazz/features/search_feature/presentation/widgets/custom_scroll_text.dart';
import 'package:jazz/features/search_feature/presentation/widgets/custom_slider_thumb.dart';
import 'package:jazz/features/search_feature/presentation/widgets/share_user_selection.dart';
import 'package:jazz/features/search_feature/presentation/widgets/user_selection_bottom_sheet.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';
import 'package:jazz/features/stream_feature/domain/entities/repeat_mode.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';
import 'package:jazz/features/stream_feature/presentation/screens/relatedSongsScreen.dart';

import '../../../../core/widgets/custom_snack_bar.dart';
import '../../../download_feature/domain/entities/download_request.dart';
import '../../../download_feature/presentation/bloc/DownloadedOrNotBloc/downloaded_or_not_bloc.dart';
import '../../../download_feature/presentation/bloc/download/download_bloc.dart';

class ExpandedCurrentSong extends StatefulWidget {
  ExpandedCurrentSong({super.key});

  @override
  State<ExpandedCurrentSong> createState() => _ExpandedCurrentSongState();
}

class _ExpandedCurrentSongState extends State<ExpandedCurrentSong>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController backgroundImageController;
  late Animation<double> _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<UserBloc>().add(FetchFavouriteSongs());
    backgroundImageController = AnimationController(
      duration:
          const Duration(seconds: 60), // Even longer for smoother transition
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    backgroundImageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, Player>(
      builder: (context, state) {
        if (state is PlayerState) {
          if (state.currentSong != null) {
            return Stack(
              children: [
                state.currentSong!.fold((song) {
                  return AnimatedBuilder(
                    animation: backgroundImageController,
                    builder: (context, child) {
                      // Get the screen dimensions
                      final Size screenSize = MediaQuery.of(context).size;
                      final double screenWidth = screenSize.width;
                      final double screenHeight = screenSize.height;

                      // Calculate the diagonal of the screen
                      final double screenDiagonal = sqrt(
                          screenWidth * screenWidth +
                              screenHeight * screenHeight);

                      // Calculate maximum scale needed (based on screen diagonal)
                      // This ensures complete coverage at any rotation angle
                      final double maxScale =
                          screenDiagonal / min(screenWidth, screenHeight);

                      // Apply rotation
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateZ(backgroundImageController.value * 2 * pi)
                          ..scale(
                              maxScale, maxScale), // Apply the calculated scale
                        child: RepaintBoundary(child: child!),
                      );
                    },
                    child: Image.network(
                      song.thumbnails.highThumbnail.url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      alignment: Alignment.center,
                      filterQuality: FilterQuality.high,
                    ),
                  );
                }, (downloadedSong) {
                  return AnimatedBuilder(
                    animation: backgroundImageController,
                    builder: (context, child) {
                      // Get the screen dimensions
                      final Size screenSize = MediaQuery.of(context).size;
                      final double screenWidth = screenSize.width;
                      final double screenHeight = screenSize.height;

                      // Calculate the diagonal of the screen
                      final double screenDiagonal = sqrt(
                          screenWidth * screenWidth +
                              screenHeight * screenHeight);

                      // Calculate maximum scale needed (based on screen diagonal)
                      // This ensures complete coverage at any rotation angle
                      final double maxScale =
                          screenDiagonal / min(screenWidth, screenHeight);

                      // Apply rotation
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateZ(backgroundImageController.value * 2 * pi)
                          ..scale(
                              maxScale, maxScale), // Apply the calculated scale
                        child: RepaintBoundary(child: child!),
                      );
                    },
                    child: Image.memory(
                      downloadedSong.image!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      alignment: Alignment.center,
                      filterQuality: FilterQuality.high,
                    ),
                  );
                }),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.7), // Optional overlay
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // App Bar / Navigation

                      const Center(
                        child: Text(
                          "Now Playing",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Album Art and Song Info
                      state.currentSong!.fold(
                        (song) {
                          return Column(
                            children: [
                              Container(
                                height: 350.h,
                                width: 350.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 5,
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.network(
                                  song.thumbnails.highThumbnail.url ?? "",
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 25),
                              Container(
                                padding: EdgeInsets.only(left: 25.w),
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ConditionalScrollText(
                                          text: song.title ?? "",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          width: 220.w,
                                        ),
                                        const SizedBox(height: 8),
                                        ConditionalScrollText(
                                          text: song.artists
                                                  .map((song) => song['name'])
                                                  .join(",") ??
                                              "Unknown Artist",
                                          style: TextStyle(
                                            color: Colors.grey[300],
                                            fontSize: 16,
                                          ),
                                          width: 220.w,
                                        ),
                                      ],
                                    ),
                                    BlocListener<PlaylistBloc, PlaylistLoaded>(
                                      listener: (context, playlistState) {
                                        if (!playlistState.isLoading) {
                                          context
                                              .read<UserBloc>()
                                              .add(FetchFavouriteSongs());
                                        }
                                        if (playlistState.addedToFavourite) {
                                          ScaffoldMessenger.of(context)
                                              .hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(CustomSnackBar.show(
                                                  message:
                                                      "Added to My Collection",
                                                  backgroundColor: AppColors
                                                      .snackBarBackgroundColor));
                                        } else if (playlistState
                                            .removedFromFavourite) {
                                          ScaffoldMessenger.of(context)
                                              .hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(CustomSnackBar.show(
                                                  message:
                                                      "Removed from My Collection",
                                                  backgroundColor: AppColors
                                                      .snackBarBackgroundColor));
                                        }
                                      },
                                      child: BlocBuilder<UserBloc,
                                          FetchedUserData>(
                                        builder: (context, state) {
                                          if (state.user.favouriteSongs
                                              .contains(song.id)) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  context
                                                      .read<PlaylistBloc>()
                                                      .add(RemoveFavouriteSong(
                                                          songId: song.id));
                                                },
                                                child: const Icon(
                                                  Icons.favorite,
                                                  color: Colors.pink,
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  context
                                                      .read<PlaylistBloc>()
                                                      .add(AddFavouriteSong(
                                                          songId: song.id));
                                                },
                                                child: const Icon(
                                                  Icons.favorite_border,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
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
                                          child: Image.asset(
                                              "assets/icons/share.png")),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8.0),
                                      child: GestureDetector(
                                          onTap: () {
                                            context.read<DownloadedOrNotBloc>().add(CheckIfDownloadedEvent(song.id,song.title,song.artists.first['name']));
                                            showModalBottomSheet(

                                                context: context,

                                                enableDrag: true,

                                                backgroundColor: Color.fromRGBO(
                                                    37, 39, 40, 1),
                                                shape: RoundedRectangleBorder(
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
                                                      )
                                                     ,
                                                      Padding(
                                                        padding: const EdgeInsets.all(16.0),
                                                        child: InkWell(
                                                          splashFactory: NoSplash.splashFactory,
                                                          highlightColor: Colors.transparent,
                                                          onTap: (){
                                                            Navigator.pop(context);
                                                            if(song.artists.length==1){
                                                              context.read<ArtistBloc>().add(FetchArtistEvent(artistId: song.artists.first['id']));
                                                              Navigator.pushNamed(context, Routes.artistDetailScreen,arguments: {"artistId": song.artists.first["id"]});
                                                            }else if(song.artists.length >1){
                                                               showModalBottomSheet(
                                                                   context: context,

                                                                   enableDrag: true,

                                                                   backgroundColor: Color.fromRGBO(
                                                                       37, 39, 40, 1),
                                                                   shape: RoundedRectangleBorder(
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
                                                                                     Navigator.pushNamed(context, Routes.artistDetailScreen,arguments: {"artistId": song.artists[index]["id"]});
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
                                                      SizedBox(height: 50.h,),
                                                    ],
                                                  );
                                                });
                                          },
                                          child: Icon(
                                            Icons.more_horiz,
                                            color: Colors.white,
                                          )),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        (downloadedSong) {
                          return Column(
                            children: [
                              Container(
                                width: 350.w,
                                height: 350.h,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 5,
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: OverflowBox(
                                  alignment: Alignment.center,
                                  maxWidth: 700
                                      .w, // 20% wider than container (adjust for crop amount)
                                  maxHeight: 700.h, // 20% taller than container
                                  child: Image.memory(
                                    scale: 0.1,
                                    downloadedSong.image!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),
                              Padding(
                                padding: const EdgeInsets.only(left: 25.0),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        downloadedSong.songName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        downloadedSong.artist,
                                        style: TextStyle(
                                          color: Colors.grey[300],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      // Playback Progress
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 5,
                                thumbShape: const RectangularSliderThumbShape(
                                    width: 5, height: 14, borderRadius: 20),
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 14),
                                activeTrackColor: Colors.white,
                                inactiveTrackColor:
                                    Colors.grey.withOpacity(0.3),
                                thumbColor: Colors.white,
                                overlayColor: Colors.purple.withOpacity(0.3),
                              ),
                              child: Slider(
                                min: 0,
                                max: state.totalDuration.inMilliseconds
                                    .toDouble(),
                                value: state.songPosition.inMilliseconds
                                    .toDouble(),
                                onChanged: (value) {
                                  context.read<PlayerBloc>().seekTo(
                                      Duration(milliseconds: value.toInt()));
                                },
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(state.songPosition),
                                    style: TextStyle(
                                        color: Colors.grey[400], fontSize: 12),
                                  ),
                                  Text(
                                    _formatDuration(state.totalDuration),
                                    style: TextStyle(
                                        color: Colors.grey[400], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Playback Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Shuffle Button
                          BlocBuilder<PlayerBloc, Player>(
                            builder: (context, state) {
                              if (state is PlayerState) {
                                bool isShuffled = state.isShuffleEnabled;
                                return Container(
                                  height: 40.h,
                                  width: 40.w,
                                  decoration: BoxDecoration(
                                      color: isShuffled
                                          ? Colors.white.withOpacity(0.2)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.shuffle,
                                      color: isShuffled
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.5),
                                      size: 25,
                                    ),
                                    onPressed: () {
                                      context.read<PlayerBloc>().add(
                                          ToggleShuffleEvent(
                                              isShuffled: !isShuffled,
                                              index: state.currentSongIndex));
                                    },
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),

                          // Previous Button
                          IconButton(
                            icon: const Icon(Icons.skip_previous,
                                color: Colors.white, size: 35),
                            onPressed: () {
                              context
                                  .read<PlayerBloc>()
                                  .add(PlayPreviousEvent());
                            },
                          ),

                          // Play/Pause Button
                          BlocBuilder<PlayerBloc, Player>(
                            builder: (context, state) {
                              if (state is PlayerState) {
                                return IconButton(
                                  style: const ButtonStyle(
                                      splashFactory: NoSplash.splashFactory),
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  icon: Icon(
                                    state.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                  onPressed: () {
                                    if (state.isPlaying) {
                                      context
                                          .read<PlayerBloc>()
                                          .add(PausePlayerEvent());
                                    } else {
                                      context
                                          .read<PlayerBloc>()
                                          .add(ResumePlayerEvent());
                                    }
                                  },
                                );
                              }
                              return const Icon(Icons.play_arrow,
                                  color: Colors.white, size: 35);
                            },
                          ),

                          // Next Button
                          IconButton(
                            icon: const Icon(Icons.skip_next,
                                color: Colors.white, size: 35),
                            onPressed: () {
                              context
                                  .read<PlayerBloc>()
                                  .add(PlayNextSongEvent());
                            },
                          ),

                          // Repeat Button
                          BlocBuilder<PlayerBloc, Player>(
                            builder: (context, state) {
                              if (state is PlayerState) {
                                IconData iconData;
                                Color iconColor;

                                if (state.isSongRepeatEnabled) {
                                  iconData = Icons.repeat_one;
                                  iconColor = Colors.white;
                                } else if (state.isPlaylistRepeatEnabled) {
                                  iconData = Icons.repeat;
                                  iconColor = Colors.white;
                                } else {
                                  iconData = Icons.repeat;
                                  iconColor = Colors.white.withOpacity(0.5);
                                }

                                return Container(
                                  height: 40.h,
                                  width: 40.w,
                                  decoration: BoxDecoration(
                                      color: state.isPlaylistRepeatEnabled ||
                                              state.isSongRepeatEnabled
                                          ? Colors.white.withOpacity(0.2)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: IconButton(
                                    icon: Icon(
                                      iconData,
                                      color: iconColor,
                                      size: 25,
                                    ),
                                    onPressed: () {
                                      if (!state.isPlaylistRepeatEnabled &&
                                          !state.isSongRepeatEnabled) {
                                        context.read<PlayerBloc>().add(
                                            ToggleRepeatModeEvent(
                                                mode: RepeatMode.playlist));
                                      } else if (state
                                          .isPlaylistRepeatEnabled) {
                                        context.read<PlayerBloc>().add(
                                            ToggleRepeatModeEvent(
                                                mode: RepeatMode.song));
                                      } else if (state.isSongRepeatEnabled) {
                                        context.read<PlayerBloc>().add(
                                            ToggleRepeatModeEvent(
                                                mode: RepeatMode.none));
                                      }
                                    },
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // Additional Functions Row
                      state.currentSong!.fold(
                        (song) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton(
                                context: context,
                                icon: Icons.lyrics,
                                label: "Lyrics",
                                onTap: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (context) {
                                    return const LyricsScreen();
                                  }));
                                },
                              ),

                              // Related Songs Button
                              _buildActionButton(
                                context: context,
                                icon: Icons.queue_music,
                                label: "Related",
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                        return const RelatedSongScreen();
                                      }));
                                },
                              ),
                              _buildActionButton(
                                context: context,
                                icon: Icons.playlist_add,
                                label: "Add to Playlist",
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
                                                              state.currentSong!
                                                                  .fold(
                                                                (song) {
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
                                                                          .snackBarBackgroundColor));
                                                                },
                                                                (downloadedSong) {},
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
                              ),
                            ],
                          );
                        },
                        (downloadedSong) =>  Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              context: context,
                              icon: Icons.lyrics,
                              label: "Lyrics",
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return const LyricsScreen();
                                }));
                              },
                            ),

                            // Related Songs Button
                            _buildActionButton(
                              context: context,
                              icon: Icons.queue_music,
                              label: "Related",
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                      return const RelatedSongScreen();
                                    }));
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const Center(
            child: Text(
              "No song is currently playing",
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    return "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
  }
}
