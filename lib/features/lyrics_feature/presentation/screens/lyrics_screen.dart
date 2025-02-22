import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/features/lyrics_feature/presentation/bloc/lyrics_bloc/lyrics_bloc.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';

class LyricsScreen extends StatelessWidget {
  const LyricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(title: const Text("Lyrics Screen"),),
       body: BlocBuilder<PlayerBloc, Player>(
         builder: (context, state) {
           if(state is PlayerState){
             if(state.errorMessage!= null && state.errorMessage!.isNotEmpty){
               return const Text("There is an error");

             }
           if(state.lyrics.isNotEmpty){
             return SingleChildScrollView(child: Text(state.lyrics));
           }else{
             return Text("NO Lyrics");
           }



           }else{
             return const CircularProgressIndicator();
           }
         },
       ),
     );
  }
}
