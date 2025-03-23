import 'package:dio/dio.dart';
import 'package:jazz/features/search_feature/domain/entities/artist.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';

class TrendingDataSource {
  final Dio dio;
  final String baseUrl;

  TrendingDataSource({
    Dio? dio,
    this.baseUrl = 'https://ytmusic-4diq.onrender.com/trending',
  }) : dio = dio ?? Dio();

  Future<List<RelatedSong>> fetchTrendingSongs() async {
      List<RelatedSong> trendingSongs = [];
    try {
      final response = await dio.get(baseUrl);
      if (response.statusCode == 200) {

        final result = response.data;
        for(var song in result ){
          trendingSongs.add(RelatedSong(url: "", song:Song.fromJson(song) ));
        }
        return trendingSongs;
      } else {
        throw Exception('Failed to load artist data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching artist data: $error');
    }
  }
}
