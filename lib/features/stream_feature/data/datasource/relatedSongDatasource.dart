import 'package:dio/dio.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/search_feature/domain/entities/thumbnails.dart';
import 'package:jazz/features/stream_feature/data/datasource/mp3StreamDatasource.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';

class RelatedSongDatasource {
  final Mp3streamDatasource mp3streamDatasource;
  final Dio dio = Dio();

  static const String baseUrl = 'https://ytmusic-4diq.onrender.com/related/';

  RelatedSongDatasource(this.mp3streamDatasource);

  Future<List<RelatedSong>> getRelatedSongs(
      String videoId, List<RelatedSong> existingRelatedSongs) async {
    try {
      final response = await dio.get("$baseUrl$videoId");

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as List;
        final List<RelatedSong> fetchedSongs = data.map((video) {
          // Safely extract thumbnail data
          final thumbnailsData = video['thumbnail'];
          final thumbnail = (thumbnailsData is List && thumbnailsData.isNotEmpty)
              ? thumbnailsData[0]
              : null;

          // Create a single YtThumbnail instance to be reused for all resolutions
          final ytThumbnail = YtThumbnail(
            url: thumbnail?['url'] ?? "",
            width: thumbnail?['width'] ?? 0,
            height: thumbnail?['height'] ?? 0,
          );

          return RelatedSong(
            url: "",
            song: Song(
              url: "https://www.youtube.com/watch?v=${video['videoId']}",
              title: video['title'] ?? "",
              artist: video['artists'] is List && video['artists'].isNotEmpty
                  ? video['artists'][0]['name']
                  : "",
              id: video['videoId'] ?? "",
              resultType: video["resultType"]?? "" ,
              category: video['category'] ?? "",
              browseId: video["browseId"] ?? "",
              thumbnails: YtThumbnails(
                defaultThumbnail: ytThumbnail,
                mediumThumbnail: ytThumbnail,
                highThumbnail: ytThumbnail,
              ),
            ),
          );
        }).toList();

        // Create a set of existing song IDs for efficient filtering.
        final existingIds =
        existingRelatedSongs.map((rs) => rs.song.id).toSet();

        // Filter out any fetched song that already exists.
        final uniqueSongs = fetchedSongs
            .where((song) => !existingIds.contains(song.song.id))
            .toList();

        return uniqueSongs;
      } else {
        // Handle non-200 responses appropriately.
        throw Exception(
            'Failed to fetch related songs: ${response.statusCode}');
      }
    } catch (error) {
      // Log the error or handle it as needed.
      rethrow;
    }
  }
}
