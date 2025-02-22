  import 'dart:collection';

  import 'package:bloc/bloc.dart';
  import 'package:dio/dio.dart';
  import 'package:equatable/equatable.dart';
  import 'package:jazz/features/download_feature/domain/entities/download_request.dart';
  import 'package:jazz/features/download_feature/domain/usecases/download_songs.dart';

  part 'download_event.dart';
  part 'download_state.dart';

  class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
    final DownloadSongs downloadSongs;
    final Map<String,CancelToken> _cancelTokens = {};
    final Queue<DownloadRequest> _downloadQueue = Queue<DownloadRequest>();
    final Map<String, int> _downloadedBytes = {};
    bool _isDownloading = false;
    bool _isPaused = false;

    DownloadBloc(this.downloadSongs) : super(DownloadInitial()) {
      on<DownloadSongEvent>(_downloadSongsEvent);
      on<PauseDownloadEvent>(_pauseDownloadEvent);
      on<ResumeDownloadEvent>(_resumeDownloadEvent);
      on<DeleteDownloadEvent>(_deleteDownloadEvent);
    }

    Future<void> _downloadSongsEvent(DownloadSongEvent event, Emitter<DownloadState> emit) async {

      _downloadQueue.add(event.downloadRequest);


      if (!_isDownloading  && !_isPaused) {
        await _processNextRequest(emit);
      }
    }

    Future<void> _processNextRequest(Emitter<DownloadState> emit,{int alreadyDownloadedBytes = 0}) async {
      if (_downloadQueue.isEmpty ||  _isPaused) {

        _isDownloading = false;
        return;
      }
      _isPaused = false;
      _isDownloading = true;
      final DownloadRequest currentRequest = _downloadQueue.removeFirst();
      final String videoID = currentRequest.videoID;
      final String title = currentRequest.title;
      CancelToken cancelToken = CancelToken();
      _cancelTokens[videoID] = cancelToken;


  try {
    print("Current: ${currentRequest.alreadyDownloadedBytes}");
    final result = await downloadSongs(currentRequest, (progress,alreadyDownloadedBytes) {
      if (!emit.isDone) {

        emit(DownloadOnProgress(

            progress, currentRequest, _downloadQueue.toList()));
      }
    }, cancelToken,
    alreadyDownloadedBytes: currentRequest.alreadyDownloadedBytes
    );


    result.fold(
          (failure) {
        if (!emit.isDone) {
          emit(DownloadError(failure.message));
        }
      },
          (success) {
        if (!emit.isDone && !_isPaused) {
          _downloadedBytes.remove(videoID);
          emit(DownloadFinished(_downloadQueue.toList()));
        }
      },
    );


  }on DioException catch (e){
    if(e.type == DioExceptionType.cancel){

    }else{
      emit(DownloadError("Error Downloading"));
    }
      }catch(e) {
    emit(DownloadError("Error Downloading"));
      }
      await _processNextRequest(emit);
    }
    Future<void> _pauseDownloadEvent(PauseDownloadEvent event, Emitter emit) async {
      final CancelToken? cancelToken = _cancelTokens[event.downloadRequest.videoID];
      if (cancelToken != null && !cancelToken.isCancelled) {

        _isPaused = true;
        _isDownloading = false;

        cancelToken.cancel();
        _downloadedBytes[event.downloadRequest.videoID] = event.downloadRequest.alreadyDownloadedBytes;
        emit(DownloadPaused(event.downloadRequest,_downloadQueue.toList(),event.downloadRequest.alreadyDownloadedBytes));

      }
    }
    Future<void> _resumeDownloadEvent(ResumeDownloadEvent event, Emitter<DownloadState> emit) async {
      _downloadQueue.addFirst(event.downloadRequest);
      print(event.downloadRequest.alreadyDownloadedBytes);
      if (_isPaused) {
        _isPaused = false;
        await _processNextRequest(emit,alreadyDownloadedBytes: event.downloadRequest.alreadyDownloadedBytes);
      }
    }
    Future<void> _deleteDownloadEvent(DeleteDownloadEvent event, Emitter emit) async {
      final CancelToken? cancelToken = _cancelTokens[event.videoID];
      if (cancelToken != null && !cancelToken.isCancelled) {
        cancelToken.cancel();
      }
      _cancelTokens.remove(event.videoID);
      _downloadedBytes.remove(event.videoID);
      emit(DownloadDeleted());
    }


  }


