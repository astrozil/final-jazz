import 'package:jazz/features/download_feature/data/datasources/downloadedSongsMetadataDatasource.dart';
import 'package:jazz/features/download_feature/domain/entities/downloadedSong.dart';
import 'package:jazz/features/download_feature/domain/repositories/getDownloadedSongDataRepository.dart';

class GetDownloadedSongDataRepoImpl extends GetDownloadedSongDataRepository{
  final DownloadedSongsMetadataDataSource downloadedSongsMetadataDataSource;

  GetDownloadedSongDataRepoImpl({required this.downloadedSongsMetadataDataSource});
  @override
  Future<List<DownloadedSong>?> getMetadata()async {
 return await downloadedSongsMetadataDataSource.getDownloadedSongsMetadata();

  }

}