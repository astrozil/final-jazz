import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:jazz/features/download_feature/domain/entities/downloadedSong.dart';
import 'package:jazz/features/download_feature/domain/usecases/getMetadata.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

part 'downloaded_songs_event.dart';
part 'downloaded_songs_state.dart';

class DownloadedSongsBloc extends Bloc<DownloadedSongsEvent, DownloadedSongsState> {
  final GetMetadata getMetadata;
  DownloadedSongsBloc({required this.getMetadata}) : super(DownloadedSongsInitial()) {
    on<GetDownloadedSongsEvent>((event, emit)async {
       final result =   await getMetadata();
       result.fold(
         (failure)=> emit(ErrorGettingDownloadedSongsState()),
           (metadata){
          metadata!= null ?
              emit(GotDownloadedSongsState(downloadedSongs: metadata)):
              emit(NoDownloadedSongsState());
           }
       );
    });
}
}
