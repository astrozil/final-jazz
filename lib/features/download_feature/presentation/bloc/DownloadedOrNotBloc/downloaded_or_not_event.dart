part of 'downloaded_or_not_bloc.dart';

@immutable
sealed class DownloadedOrNotEvent {}
class CheckIfDownloadedEvent extends DownloadedOrNotEvent{

  final String videoID;
  final String title;
  final String artist;

  CheckIfDownloadedEvent(this.videoID,this.title,this.artist);
}

class DeleteDownloadedSongEvent extends DownloadedOrNotEvent{
  final String videoID;
  final String title;
  final String artist;

  DeleteDownloadedSongEvent(this.videoID,this.title,this.artist);
}