import 'package:dio/dio.dart';
import 'package:jazz/features/download_feature/data/datasources/download_datasource.dart';
import 'package:jazz/features/download_feature/domain/entities/download_request.dart';

import '../../domain/repositories/download_repository.dart';

import 'dart:io';

class DownloadRepositoryImpl implements DownloadRepository {
  final DownloadDataSource dataSource;

  DownloadRepositoryImpl(this.dataSource);

  @override
  Future<void> downloadSong(DownloadRequest downloadRequest, Function(double,int) onProgress,CancelToken cancelToken, {
    int alreadyDownloadedBytes = 0,
  })async {
    await dataSource.downloadSongFromYoutube(downloadRequest,onProgress,cancelToken,alreadyDownloadedBytes: alreadyDownloadedBytes);
  }
}
