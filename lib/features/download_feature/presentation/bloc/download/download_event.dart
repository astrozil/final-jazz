part of 'download_bloc.dart';

sealed class DownloadEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class DownloadSongEvent extends DownloadEvent{
  final DownloadRequest downloadRequest;


  DownloadSongEvent(this.downloadRequest,);

  @override

  List<Object> get props => [downloadRequest];
}

class PauseDownloadEvent extends DownloadEvent {
  final DownloadRequest downloadRequest;

   PauseDownloadEvent(this.downloadRequest);

  @override
  List<Object> get props => [downloadRequest];
}

class ResumeDownloadEvent extends DownloadEvent {
  final DownloadRequest downloadRequest;
   ResumeDownloadEvent(this.downloadRequest);

  @override
  List<Object> get props => [downloadRequest];
}

class DeleteDownloadEvent extends DownloadEvent {
  final String videoID;
   DeleteDownloadEvent(this.videoID);

  @override
  List<Object> get props => [videoID];
}

