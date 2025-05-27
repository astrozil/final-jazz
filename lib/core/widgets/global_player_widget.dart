import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/currentSongWidgetBloc/current_song_widget_bloc.dart';
import 'package:jazz/features/search_feature/presentation/screens/collapsed_current_song.dart';
import 'package:jazz/features/search_feature/presentation/screens/expanded_current_song.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';

class GlobalPlayerWidget extends StatefulWidget {

   GlobalPlayerWidget({super.key});

  @override
  State<GlobalPlayerWidget> createState() => _GlobalPlayerWidgetState();
}

class _GlobalPlayerWidgetState extends State<GlobalPlayerWidget> {
  final DraggableScrollableController _scrollableController = DraggableScrollableController();

  void _expandBox() {
    _scrollableController.animateTo(
      1.0, // Full expansion
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
  @override
  void initState() {
    _scrollableController.addListener(() {
      // Check the size of the sheet
      if (_scrollableController.size > 0.15) {
        context.read<CurrentSongWidgetBloc>().add(CurrentSongWidgetExpandEvent());
      } else if (_scrollableController.size < 0.14) {
        context.read<CurrentSongWidgetBloc>().add(CurrentSongWidgetCollapseEvent());
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  BlocBuilder<PlayerBloc, Player>(
      builder: (context, state) {

        if(state is PlayerState) {

          if(state.currentSong != null){
            return Positioned.fill(

              child: DraggableScrollableSheet(
                controller: _scrollableController,
                minChildSize: 0.13,
                maxChildSize: 1.0,
                initialChildSize: 0.13,
                snap: true,
                snapSizes: const [0.13, 1.0],
                builder: (context, scrollController) {
                  return GestureDetector(

                    onTap: ()   {
                      if (_scrollableController.size <= 0.14) {
                        _expandBox();
                      }
                    },

                    child: Container(
                      color: Colors.transparent,

                      child: ListView(
                        controller: scrollController,
                        children: [


                          BlocBuilder<CurrentSongWidgetBloc, CurrentSongWidgetState>(
                            builder: (context, state) {
                              if (state is CurrentSongWidgetCollapseState) {
                                return const CollapsedCurrentSong();
                              } else if (state is CurrentSongWidgetExpandState) {
                                return  ExpandedCurrentSong();
                              }
                              return const SizedBox();
                            },
                          ),

                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }}
        return const SizedBox();
      },
    );
  }
}
