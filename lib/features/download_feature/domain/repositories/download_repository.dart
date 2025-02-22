import 'package:dio/dio.dart';
import 'package:jazz/features/download_feature/domain/entities/download_request.dart';

abstract class DownloadRepository {
  Future<void> downloadSong(DownloadRequest downloadRequest,Function(double,int) onProgress,CancelToken cancelToken, {
  int alreadyDownloadedBytes = 0,
  });
}