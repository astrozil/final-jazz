import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/features/auth_feature/domain/entities/user.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:jazz/features/lyrics_feature/presentation/bloc/lyrics_bloc/lyrics_bloc.dart';
import 'package:jazz/features/lyrics_feature/presentation/screens/lyrics_screen.dart';
import 'package:jazz/features/playlist_feature/domain/repositories/playlist_repo.dart';
import 'package:jazz/features/playlist_feature/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';
import 'package:jazz/features/stream_feature/domain/entities/repeat_mode.dart';

import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';


import 'package:jazz/features/stream_feature/presentation/screens/relatedSongsScreen.dart';


class ExpandedCurrentSong extends StatelessWidget {
  const ExpandedCurrentSong({super.key});
  void _showBottomSheet(BuildContext context,String songId) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          height: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if(state is UserDataFetched){
                  AppUser user = state.user;
                  if(user.favouriteSongs.contains(songId)){
                    return ElevatedButton(onPressed: (){
                      Navigator.pop(context);
                      context.read<PlaylistBloc>().add(RemoveFavouriteSong(songId: songId));
                    }, child: Text("Remove From Favorite Songs"));
                  }else{
                    return ElevatedButton(onPressed: (){
                      Navigator.pop(context);
                      context.read<PlaylistBloc>().add(AddFavouriteSong(songId: songId));

                    }, child: Text("Add to Favourite Songs"));
                }
                }
                return CircularProgressIndicator();
              },
            )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, Player>(
        builder: (context, state) {
          if (state is PlayerState) {
            if (state.currentSong != null) {
              return Column(
                  children: [
                    state.currentSong!.fold((song) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network(
                              song.thumbnails.highThumbnail.url ?? ""),
                          Text(song.title ?? ""),

                        ],
                      );
                    },
                            (downloadedSong) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.memory(downloadedSong.image!),
                              Text(downloadedSong.songName),
                            ],
                          );
                        }
                    ),
                    Slider(
                      min: 0,
                      max: state.totalDuration
                          .inMilliseconds.toDouble(),
                      value: state.songPosition.inMilliseconds
                          .toDouble(),
                      onChanged: (value) {
                        context.read<PlayerBloc>().seekTo(
                            Duration(milliseconds: value.toInt()));
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween,
                      children: [
                        Text(_formatDuration(
                            state.songPosition)),
                        Text(_formatDuration(
                            state.totalDuration)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<PlayerBloc>().add(
                            PausePlayerEvent());
                      },
                      child: Text("Pause"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<PlayerBloc>().add(
                            PlayNextSongEvent());
                      },
                      child: Text("Next"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<PlayerBloc>().add(
                            PlayPreviousEvent());
                      },
                      child: Text("Previous"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) {
                          return RelatedSongScreen();
                        }));
                      },
                      child: Text("Related Songs"),
                    ),
                    BlocBuilder<PlayerBloc, Player>(
                      builder: (context, state) {
                        if (state is PlayerState) {
                          bool isShuffled = state.isShuffleEnabled;
                          if (isShuffled) {
                            return ElevatedButton(
                              onPressed: () {
                                context.read<PlayerBloc>().add(
                                    ToggleShuffleEvent(
                                        isShuffled: !isShuffled));
                              },
                              child: Text("Unshuffle"),
                            );
                          } else {
                            return ElevatedButton(
                              onPressed: () {
                                context.read<PlayerBloc>().add(
                                    ToggleShuffleEvent(
                                        isShuffled: !isShuffled,index: state.currentSongIndex));
                              },
                              child: Text("Shuffle"),
                            );
                          }
                        }
                        return SizedBox();
                      },
                    ),
                    BlocBuilder<
                        PlayerBloc,
                        Player>(
                      builder: (context, state) {
                        if (state is PlayerState) {
                          if(!state.isPlaylistRepeatEnabled && !state.isSongRepeatEnabled){
                            return ElevatedButton(
                              onPressed: () {
                                context.read<PlayerBloc>().add(
                                    ToggleRepeatModeEvent(mode: RepeatMode.playlist));
                              },
                              child: Text("Repeat Playlist"),
                            );
                          }else if(state.isPlaylistRepeatEnabled){
                            return ElevatedButton(
                              onPressed: () {
                                context.read<PlayerBloc>().add(
                                    ToggleRepeatModeEvent(mode: RepeatMode.song));
                              },
                              child: Text("Repeat Current Song"),
                            );
                          }else if(state.isSongRepeatEnabled){
                            return ElevatedButton(
                              onPressed: () {
                                context.read<PlayerBloc>().add(
                                    ToggleRepeatModeEvent(mode: RepeatMode.none));
                              },
                              child: Text("Undo Repeat"),
                            );
                          }

                        }
                        return SizedBox();

                      },
                    ),
                    ElevatedButton(onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) {
                            return const LyricsScreen();
                          }));
                      // mp3StreamBlocState.song!.fold(
                      //         (relatedSong){
                      //
                      //
                      //       Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      //         return const LyricsScreen();
                      //       }));
                      //     },
                      //         (downloadedSong){
                      //       context.read<LyricsBloc>().add(GetLyricsEvent(artist: downloadedSong.artist, songName: downloadedSong.songName));
                      //     }
                      // );

                    }, child: const Text("Lyrics")),
                     state.currentSong!.fold(
                         (song){
                          return ElevatedButton(onPressed: ()
                          {


                            _showBottomSheet(context, song.id);
                            context.read<AuthBloc>().add(FetchUserDataEvent());
                          }, child: Text("Favourite Songs"));

                         }
                     , (downloadedSong){
                           return SizedBox();
                     }),

                      BlocBuilder<PlayerBloc, Player>(
                        builder: (context, state) {

                          if(state is PlayerState){

                            if(!state.isPlaying){
                              return ElevatedButton(
                                onPressed: () {
                                  context.read<PlayerBloc>().add(
                                      ResumePlayerEvent());
                                },
                                child: Text("Resume"),
                              );
                            }else{

                            }
                          }
                          return SizedBox();
                        }
                      ),


                  ]
              );
              // return mp3StreamBlocState.song!.fold(
              //         (song) {
              //
              //       return Column(
              //         crossAxisAlignment: CrossAxisAlignment.center,
              //         children: [
              //           Image.network(song.thumbnails.highThumbnail.url ?? ""),
              //           Text(song.title ?? ""),
              //           BlocBuilder<SongPositionBloc, SongPositionState>(
              //               builder: (context, songPositionState) {
              //                 if (songPositionState is SongPositionUpdatedState) {
              //
              //                   return Column(
              //                     children: [
              //                       Slider(
              //                         min: 0,
              //                         max: songPositionState.totalDuration
              //                             .inMilliseconds.toDouble(),
              //                         value: songPositionState.position.inMilliseconds
              //                             .toDouble(),
              //                         onChanged: (value) {
              //                           context.read<Mp3StreamBloc>().seekTo(
              //                               Duration(milliseconds: value.toInt()));
              //                         },
              //                       ),
              //
              //
              //                       Row(
              //                         mainAxisAlignment: MainAxisAlignment
              //                             .spaceBetween,
              //                         children: [
              //                           Text(_formatDuration(
              //                               songPositionState.position)),
              //                           Text(_formatDuration(
              //                               songPositionState.totalDuration)),
              //                         ],
              //                       ),
              //                     ],
              //                   );
              //                 }
              //                 return Column(
              //                   children: [
              //                     Slider(
              //                       min: 0,
              //                       max: Duration.zero.inMilliseconds.toDouble(),
              //                       value: Duration.zero.inMilliseconds.toDouble(),
              //                       onChanged: (value) {
              //                         context.read<Mp3StreamBloc>().seekTo(
              //                             Duration(milliseconds: value.toInt()));
              //                       },
              //                     ),
              //
              //
              //                     Row(
              //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                       children: [
              //                         Text(_formatDuration(Duration.zero)),
              //                         Text(_formatDuration(Duration.zero)),
              //                       ],
              //                     ),
              //                   ],
              //                 );
              //               }),
              //           ElevatedButton(
              //             onPressed: () {
              //               context.read<Mp3StreamBloc>().add(
              //                   PauseMp3Stream(left(song)));
              //             },
              //             child: Text("Pause"),
              //           ),
              //           ElevatedButton(
              //             onPressed: () {
              //               context.read<Mp3StreamBloc>().add(
              //                   PlayNextSong());
              //             },
              //             child: Text("Next"),
              //           ),
              //           ElevatedButton(
              //             onPressed: () {
              //               context.read<Mp3StreamBloc>().add(
              //                   PlayPreviousSong(left(song)));
              //             },
              //             child: Text("Previous"),
              //           ),
              //           ElevatedButton(
              //             onPressed: () {
              //               Navigator.push(
              //                   context, MaterialPageRoute(builder: (context) {
              //                 return RelatedSongScreen();
              //               }));
              //             },
              //             child: Text("Related Songs"),
              //           ),
              //           BlocBuilder<ShuffleStateBloc, ShuffleState>(
              //             builder: (context, state) {
              //               if (state is UnShuffledSongsState) {
              //                 return ElevatedButton(
              //                   onPressed: () {
              //                     context.read<Mp3StreamBloc>().add(
              //                         ShuffleSongHistoryEvent(left(song)));
              //                   },
              //                   child: Text("Shuffle"),
              //                 );
              //               }
              //               return ElevatedButton(
              //                 onPressed: () {
              //                   context.read<Mp3StreamBloc>().add(
              //                       UnShuffleSongHistoryEvent(left(song)));
              //                 },
              //                 child: Text("Unshuffle"),
              //               );
              //             },
              //           ),
              //           BlocBuilder<
              //               RepeatSongOrPlaylistBloc,
              //               RepeatSongOrPlaylistState>(
              //             builder: (context, state) {
              //               if (state is NoRepeatState) {
              //                 return ElevatedButton(
              //                   onPressed: () {
              //                     context.read<RepeatSongOrPlaylistBloc>().add(
              //                         RepeatPlaylistEvent());
              //                   },
              //                   child: Text("Repeat Playlist"),
              //                 );
              //               } else if (state is PlaylistRepeatState) {
              //                 return ElevatedButton(
              //                   onPressed: () {
              //                     context.read<RepeatSongOrPlaylistBloc>().add(
              //                         RepeatSongEvent());
              //                   },
              //                   child: Text("Repeat Current Song"),
              //                 );
              //               }
              //               return ElevatedButton(
              //                 onPressed: () {
              //                   context.read<RepeatSongOrPlaylistBloc>().add(
              //                       UndoRepeatEvent());
              //                 },
              //                 child: Text("Undo Repeat"),
              //               );
              //             },
              //           ),
              //
              //           if (mp3StreamBlocState is Mp3StreamPaused) ...[
              //             ElevatedButton(
              //               onPressed: () {
              //                 context.read<Mp3StreamBloc>().add(
              //                     ResumeMp3Stream(left(song)));
              //               },
              //               child: Text("Resume"),
              //             ),
              //           ]
              //         ],
              //       );
              //     },
              //         (downloadedSong) {
              //       return const SizedBox();
              //     }
              // );
            }
            return const SizedBox();
          }
          return const SizedBox();
        }


    );
  }

  String _formatDuration(Duration duration) {
    return "${duration.inMinutes}:${(duration.inSeconds % 60)
        .toString()
        .padLeft(2, '0')}";
  }

}


// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';
//
// class ExpandedCurrentSong extends StatelessWidget {
//   const ExpandedCurrentSong({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<PlayerBloc, Player>(
//       builder: (context, state) {
//         if(state is PlayerState){
//           return Text("OK");
//         }
//         return const SizedBox();
//       },
//     );
//   }
// }
