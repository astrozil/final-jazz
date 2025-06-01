import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/core/widgets/song_widget.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/search_feature/presentation/bloc/search/search_bloc.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';
 // Adjust the import path as needed

class SongsResultScreen extends StatelessWidget {
  const SongsResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          leading: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios_new_outlined,color: Colors.white,),

          ),
          backgroundColor: AppColors.primaryBackgroundColor,
          title: const Text("Songs",style: TextStyle(color: Colors.white),)),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) {

            return  const Center(child: CircularProgressIndicator(color: Colors.white,));
          } else if (state is SearchLoaded) {
            final List<Song> songs = state.songs;
            print(songs);
            if (songs.isEmpty) {
              return const Center(child: Text("No songs found."));
            }
            return ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return songWidget(context: context, song: song,);
              },
            );
          } else if (state is SearchError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return Container();
        },
      ),
    );
  }
}
