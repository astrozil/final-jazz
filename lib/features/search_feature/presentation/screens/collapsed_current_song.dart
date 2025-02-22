import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';

class CollapsedCurrentSong extends StatelessWidget {

  const CollapsedCurrentSong({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, Player>(
        builder: (context, state) {
          if (state is PlayerState) {
            if (state.currentSong != null) {

            return  state.currentSong!.fold((song) {
                return ListTile(
                  leading: Image.network(
                      song.thumbnails.defaultThumbnail.url),
                  title: Text(song.title),
                );
              },
                      (downloadedSong) {
                    return ListTile(
                      leading: Image.memory(
                          downloadedSong.image!),
                      title: Text(downloadedSong.songName),
                    );
                  }
              );
            }
          }
          return const SizedBox();
        }
    );
  }
}
