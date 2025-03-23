import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/features/download_feature/domain/entities/downloadedSong.dart';
import 'package:jazz/features/download_feature/presentation/bloc/downloadedSongsBloc/downloaded_songs_bloc.dart';
import 'package:jazz/features/stream_feature/domain/entities/songHistory.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';
import 'package:just_audio/just_audio.dart';

class DownloadedSongsScreen extends StatelessWidget {
  const DownloadedSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Downloaded Songs"),),
      body: BlocBuilder<DownloadedSongsBloc,DownloadedSongsState>(
          builder: (context,state){
        if(state is GotDownloadedSongsState){
          return ListView.builder(
              itemCount: state.downloadedSongs.length,
              itemBuilder: (context,index){
              DownloadedSong downloadedSong = state.downloadedSongs[index];
              Uint8List? image = downloadedSong.image;
              return GestureDetector(
                onTap: ()async{
                  context.read<PlayerBloc>() .add(PlaySongEvent(song:right(downloadedSong)));

              await Future.delayed(const Duration(seconds: 1),(){
               if(context.mounted) context.read<PlayerBloc>().add(UpdateStateEvent(state: context.read<PlayerBloc>().state.copyWith(relatedSongs: SongHistory(history: right(state.downloadedSongs)),currentSongIndex: index)));
              });

                },
                child: ListTile(title: Text(downloadedSong.album),
                subtitle: Text(downloadedSong.artist),
                leading: image != null ? Image.memory(image) : const Icon(Icons.music_note) ,
                ),
              );
          });
        }
        return const Text("No Downloaded Song");
      }),
    );
  }
}
