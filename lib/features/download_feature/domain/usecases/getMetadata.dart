import 'package:dartz/dartz.dart';
import 'package:jazz/core/failure/failure.dart';

import 'package:jazz/features/download_feature/domain/entities/downloadedSong.dart';
import 'package:jazz/features/download_feature/domain/repositories/getDownloadedSongDataRepository.dart';


class GetMetadata{
  final GetDownloadedSongDataRepository getDownloadedSongDataRepository;

  GetMetadata({required this.getDownloadedSongDataRepository});

  Future<Either<Failure,List<DownloadedSong>?>> call()async{
    try{
    List<DownloadedSong>? metadataList =  await getDownloadedSongDataRepository.getMetadata();
    return right(metadataList);
    }catch(e){
      return left(InternalStorageFailure("Internal Storage Failure"));
    }
  }
}