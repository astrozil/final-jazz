
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/stream_feature/data/datasource/mp3StreamDatasource.dart';
import 'package:jazz/features/stream_feature/data/datasource/relatedSongDatasource.dart';
import 'package:jazz/features/stream_feature/data/models/Mp3StreamModel.dart';

import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';

import 'package:jazz/features/stream_feature/domain/entities/mp3Stream.dart';

import 'package:jazz/features/stream_feature/domain/repositories/streamRepository.dart';

class StreamRepoImpl implements StreamRepository {
  final Mp3streamDatasource mp3StreamDataSource;
 final RelatedSongDatasource relatedSongDatasource;
  StreamRepoImpl(this.mp3StreamDataSource,this.relatedSongDatasource);

  @override
  Future<Mp3Stream?> getMp3Stream(String videoId,String videoUrl) async {
    Mp3StreamModel? mp3StreamModel = await mp3StreamDataSource.getMp3Link(videoId,videoUrl);
    if (mp3StreamModel != null) {
      return Mp3Stream(url: mp3StreamModel.url);
    }
    return null;
  }

  @override
  Future<List<RelatedSong>?> getRelatedSong(String videoId,List<RelatedSong> relatedSongs)async {
    List<RelatedSong>? relatedSongsList = await relatedSongDatasource.getRelatedSongs(videoId,relatedSongs);



      return relatedSongsList;


  }
}
