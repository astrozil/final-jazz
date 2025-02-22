import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jazz/core/failure/failure.dart';
import 'package:jazz/features/download_feature/domain/entities/download_request.dart';
import 'package:jazz/features/download_feature/domain/repositories/download_repository.dart';

class DownloadSongs {
  final DownloadRepository downloadRepository;

  DownloadSongs(this.downloadRepository);

  Future<Either<Failure,void>> call (DownloadRequest downloadRequest,Function(double,int) onProgress,CancelToken cancelToken, {
  int alreadyDownloadedBytes = 0,
  })async{


    try{
      await downloadRepository.downloadSong(downloadRequest,onProgress,cancelToken,alreadyDownloadedBytes: alreadyDownloadedBytes);
      return right(null);
    }catch (e){
      return left(ServerFailure("Failed to download song"));
    }
  }

}