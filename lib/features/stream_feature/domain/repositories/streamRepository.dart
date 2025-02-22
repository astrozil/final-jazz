import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';
import 'package:jazz/features/stream_feature/domain/entities/mp3Stream.dart';


abstract class StreamRepository {
  Future<Mp3Stream?> getMp3Stream(String videoId,String videoUrl);
  Future<List<RelatedSong>?> getRelatedSong(String videoId,List<RelatedSong> relatedSongs);
}
