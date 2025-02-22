import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/features/download_feature/domain/entities/downloadedSong.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';

import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';




class RelatedSongScreen extends StatelessWidget {
  const RelatedSongScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Related Songs Screen"),),
      body:  BlocBuilder<PlayerBloc, Player>(
            builder: (context, state) {


              if(state is PlayerState){
                if(state.currentSong != null){
                return state.currentSong!.fold(
                    (song){

                     return  state.relatedSongs.history.fold(
                          (relatedSongs){
                            return ListView.builder(
                                itemCount: relatedSongs.length,
                                itemBuilder: (context, index) {
                                  Song relatedSong = relatedSongs[index].song;
                                  return InkWell(
                                    onTap: () {
                                      context.read<PlayerBloc>().add(
                                          PlayChosenSongEvent(chosenIndex: index));
                                    },
                                    child: ListTile(
                                      tileColor: relatedSong.id == song.id ? Colors
                                          .grey.shade300 : Colors.transparent,
                                      leading: Image.network(
                                          relatedSong.thumbnails.defaultThumbnail.url),
                                      title: Text(relatedSong.title),
                                    ),
                                  );
                                });
                          },
                          (downloadedSongs){
                            return const SizedBox();
                          }
                      );
                    },
                    (downloadedSong){
                      return state.relatedSongs.history.fold(
                          (relatedSongs){
                            return const SizedBox();
                          },
                          (downloadedSongs){
                            return ListView.builder(
                                itemCount: downloadedSongs.length,
                                itemBuilder: (context, index) {
                                  DownloadedSong songDownloaded = downloadedSongs[index];
                                  return InkWell(
                                    onTap: () {
                                      context.read<PlayerBloc>().add(
                                          PlayChosenSongEvent(chosenIndex: index));
                                    },
                                    child: ListTile(
                                      tileColor: songDownloaded.songFile == downloadedSong.songFile ? Colors
                                          .grey.shade300 : Colors.transparent,
                                      leading: Image.memory(
                                          songDownloaded.image!),
                                      title: Text("${songDownloaded.songName}"),
                                    ),
                                  );
                                });
                          }
                      );

                    }
                );
              }}
          return const SizedBox();

            }),
      );

  }
}
