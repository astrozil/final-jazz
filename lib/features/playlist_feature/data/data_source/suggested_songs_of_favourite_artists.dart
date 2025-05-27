import 'package:dio/dio.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/search_feature/domain/entities/thumbnails.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';

class SuggestedSongsOfFavouriteArtistsDataSource {
  final Dio dio;
  final String baseUrl;

  SuggestedSongsOfFavouriteArtistsDataSource({
    Dio? dio,
    this.baseUrl = 'https://ytmusic-4diq.onrender.com/mix',
  }) : dio = dio ?? Dio();

  Future<List<RelatedSong>> fetchMixSongs({required String artistIds}) async {
    List<RelatedSong> mixSongs = [];
    try {
      final response = await dio.get(
        baseUrl,
        queryParameters: {'artists': artistIds},
      );
      if (response.statusCode == 200) {

        final result = response.data;

        for (var song in result) {
          mixSongs.add(RelatedSong(url: "", song: Song(
            url: song['url'] as String? ??
                (song['videoId'] != null ? "https://www.youtube.com/watch?v=${song['videoId']}" : ""),
            title: song['title'] as String? ?? "",
            artists: song['artists'] is List
                ? List<Map<dynamic, dynamic>>.from(song['artists'] as List)
                : [{
              'name': song['artist']
            }],
            id: song['videoId'] as String? ?? "",
            resultType: song['resultType'] as String? ?? "",
            category: song['category'] as String? ?? "",
            browseId: song['browseId'] as String? ?? "",
            thumbnails:  YtThumbnails.fromJson(song['thumbnails']),
            album: song['album'] != null?  song['album'] is Map ? Map<dynamic, dynamic>.from(song['album']) : null : null,
            duration: song['duration'] as String? ?? "",
          )));
        }
        return mixSongs;
      } else {
        throw Exception(
            'Failed to load mix songs. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching mix songs: $error');
    }
  }
}
