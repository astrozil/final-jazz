import 'package:jazz/features/download_feature/domain/entities/downloadedSong.dart';


abstract class GetDownloadedSongDataRepository{
  Future<List<DownloadedSong>?> getMetadata();
}