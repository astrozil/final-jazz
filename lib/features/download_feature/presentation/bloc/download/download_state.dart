part of 'download_bloc.dart';

sealed class DownloadState extends Equatable {
  const DownloadState();
}

final class DownloadInitial extends DownloadState {
  @override
  List<Object> get props => [];
}


final class DownloadOnProgress extends DownloadState{
  final DownloadRequest downloadRequest;
  final List<DownloadRequest> downloadRequestList;
  final double progress;

  const DownloadOnProgress(this.progress,this.downloadRequest,this.downloadRequestList);
  @override
  // TODO: implement props
  List<Object?> get props => [progress,downloadRequest,downloadRequestList];
}
final class DownloadPaused extends DownloadState{

  final DownloadRequest downloadRequest;
  final List<DownloadRequest> downloadRequestList;
  final int alreadyDownloadedBytes;
  const DownloadPaused(this.downloadRequest,this.downloadRequestList,this.alreadyDownloadedBytes);
  @override
  // TODO: implement props
  List<Object?> get props => [downloadRequest,downloadRequestList,alreadyDownloadedBytes];

}
final class DownloadDeleted extends DownloadState{
  @override
  // TODO: implement props
  List<Object?> get props => [];

}
final class DownloadResumed extends DownloadState{
  final int alreadyDownloadedBytes;
  const DownloadResumed(this.alreadyDownloadedBytes);
  @override
  // TODO: implement props
  List<Object?> get props => [alreadyDownloadedBytes];
}

final class DownloadFinished extends DownloadState{
  final List<DownloadRequest> downloadRequestList;
  const DownloadFinished(this.downloadRequestList);
  @override
  // TODO: implement props
  List<Object?> get props => [downloadRequestList];
}
final class DownloadError extends DownloadState{
 final String message;
 const DownloadError(this.message);
  @override
  // TODO: implement props
  List<Object?> get props => [message];
}

