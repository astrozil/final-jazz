// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:jazz/features/search_feature/domain/entities/song.dart';
// import 'package:jazz/features/stream_feature/presentation/bloc/mp3StreamBloc/mp3_stream_bloc.dart';
//
// import 'package:jazz/features/stream_feature/presentation/screens/relatedSongsScreen.dart';
//
// class StreamScreen extends StatelessWidget {
//   const StreamScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Stream Screen"),
//       ),
//       body:  BlocBuilder<Mp3StreamBloc, Mp3StreamState>(
//           builder: (context, state) {
//             Song? currentSong = state.song;
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Image.network(currentSong!.thumbnails.highThumbnail.url ?? ""),
//                 Text(currentSong.title ?? ""),
//              if (state is Mp3StreamPositionUpdate && currentSong != null)
//
//                   ...[
//
//
//                   Slider(
//                     min: 0,
//                     max: state.totalDuration.inMilliseconds.toDouble(),
//                     value: state.position.inMilliseconds.toDouble(),
//                     onChanged: (value) {
//                       context.read<Mp3StreamBloc>().seekTo(
//                           Duration(milliseconds: value.toInt()));
//                     },
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(_formatDuration(state.position)),
//                       Text(_formatDuration(state.totalDuration)),
//                     ],
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       context.read<Mp3StreamBloc>().add(
//                           PauseMp3Stream(currentSong));
//                     },
//                     child: Text("Pause"),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       context.read<Mp3StreamBloc>().add(
//                         PlayNextSong(currentSong));
//                     },
//                     child: Text("Next"),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       context.read<Mp3StreamBloc>().add(
//                           PlayPreviousSong(currentSong));
//                     },
//                     child: Text("Previous"),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context){
//                       return RelatedSongScreen();
//                     }));
//                     },
//                     child: Text("Related Songs"),
//                   )
//
//                 ] else if (state is Mp3StreamPaused && currentSong != null) ...[
//                   ElevatedButton(
//                     onPressed: () {
//                       context.read<Mp3StreamBloc>().add(
//                           ResumeMp3Stream(currentSong));
//                     },
//                     child: Text("Resume"),
//                   ),
//                 ]
//               ],
//             );
//           },
//         ),
//       );
//
//   }
//
//   String _formatDuration(Duration duration) {
//     return "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
//   }
// }
