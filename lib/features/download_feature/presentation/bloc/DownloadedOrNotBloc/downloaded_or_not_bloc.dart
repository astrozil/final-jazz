import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

part 'downloaded_or_not_event.dart';
part 'downloaded_or_not_state.dart';

class DownloadedOrNotBloc extends Bloc<DownloadedOrNotEvent, DownloadedOrNotState> {
  DownloadedOrNotBloc() : super(DownloadedOrNotInitial()) {
    on<CheckIfDownloadedEvent>((event, emit)async {
      Future<bool> isSongDownloaded(String videoID,String title,String artist) async {
        final directory = await getExternalStorageDirectory();
        final filePath = '${directory?.path}/$title-$artist-$videoID.mp3'; // Assuming mp3 format, adjust as needed
        final file = File(filePath);
        return file.existsSync();
      }
      bool isDownloaded = await isSongDownloaded(event.videoID, event.title,event.artist);
      if(isDownloaded){
        emit(DownloadedSongState());
      }else{
        emit(NotDownloadedSongState());
      }

    });

    on<DeleteDownloadedSongEvent>((event,emit)async{
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory?.path}/${event.title}-${event.artist}-${event.videoID}.mp3'; // Assuming mp3 format, adjust as needed
      final file = File(filePath);

      if(file.existsSync()){
        file.deleteSync();
        emit(DeletedSongState());
      }
    });
  }

}
