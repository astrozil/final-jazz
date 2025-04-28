import 'package:dio/dio.dart';
import 'package:jazz/features/search_feature/domain/entities/album.dart';
import 'package:jazz/features/search_feature/domain/entities/artist.dart';
import 'package:jazz/features/search_feature/domain/entities/thumbnails.dart';
import '../../domain/entities/song.dart';

class YouTubeDataSource {
  final Dio dio = Dio();
  static const String baseUrl = 'https://ytmusic-4diq.onrender.com/search';

  Future<List<dynamic>?> search(String query, {String? filter}) async {
    // Build query parameters with the provided query.
    final Map<String, dynamic> queryParams = {
      "query": query,
    };

    // If filter is provided, add it to the query parameters.
    if (filter != null) {
      queryParams["filter"] = filter;
    }

    final response = await dio.get(baseUrl, queryParameters: queryParams);

    if (response.statusCode == 200 && response.data != null) {
      var data = response.data;

      // If filter is provided, return the raw list from the response.
      if (filter != null) {
        return List<dynamic>.from(data);
      }
      // Otherwise, parse the response into Song objects.
      else {
        List<Song> songs = [];
        for (var video in data) {
          songs.add(
            Song.fromJson(video)
          );
        }
        return songs;
      }
    } else {
      throw Exception("Failed to fetch download link: ${response.statusCode}");
    }
  }

  Future<List<Song>?> searchSongs(String query) async {
    final rawData = await search(query, filter: "songs");
    if (rawData != null) {
      List<Song> songs = [];
      for (var video in rawData) {
        songs.add(
          Song(
            url: "https://www.youtube.com/watch?v=${video['videoId']}",
            title: video['title'] ?? "",
            artists: video['artists'] != null
                ? video['artists'][0]['name']
                : video['artist'] ?? '',
            id: video['videoId'] ?? "",
            duration: video['duration'] ?? "",
            album: video['album'] ?? {},

            resultType: video['resultType']?? "",
            category: video['category'] ?? "",

            browseId: video['browseId'] ?? '',
            thumbnails: YtThumbnails(
              defaultThumbnail: YtThumbnail(
                url: video['thumbnails'][0]['url'] ?? "",
                width: video['thumbnails'][0]['width'] ?? 0,
                height: video['thumbnails'][0]['height'] ?? 0,
              ),
              mediumThumbnail: YtThumbnail(
                url: video['thumbnails'][0]['url'] ?? "",
                width: video['thumbnails'][0]['width'] ?? 0,
                height: video['thumbnails'][0]['height'] ?? 0,
              ),
              highThumbnail: YtThumbnail(
                url: video['thumbnails'][0]['url'] ?? "",
                width: video['thumbnails'][0]['width'] ?? 0,
                height: video['thumbnails'][0]['height'] ?? 0,
              ),
            ),
          ),
        );
      }
      return songs;
    }
    return null;
  }

  /// Searches for albums and returns a list of Album objects.
  Future<List<Album>?> searchAlbums(String query) async {
    final rawData = await search(query, filter: "albums");
    if (rawData != null) {
      List<Album> albums = [];
      for (var albumData in rawData) {
        albums.add(
          Album(
            artist: albumData['artists'] != null && albumData['artists'].isNotEmpty
                ? albumData['artists'][0]['name']
                : '',
            artistId: albumData['artists'] != null && albumData['artists'].isNotEmpty && albumData['artists'][0]['id'] != null
                ? albumData['artists'][0]['id']
                : '',
            description: '', // JSON doesn't include description.
            duration: "",
            ytThumbnail: albumData['thumbnails'] != null && albumData['thumbnails'].isNotEmpty
                ? YtThumbnail(
              url: albumData['thumbnails'][0]['url'] ?? "",
              width: albumData['thumbnails'][0]['width'] ?? 0,
              height: albumData['thumbnails'][0]['height'] ?? 0,
            )
                : YtThumbnail(url: "", width: 0, height: 0),
            title: albumData['title'] ?? "",
            trackCount: 0, // Not provided in JSON.
            tracks: [], // Not provided in JSON.
            year: albumData['year'] ?? "",
            type: albumData['type'] ?? "",
            browseId: albumData['browseId'] ?? ""
          ),
        );
      }
      return albums;
    }
    return null;
  }

  Future<List<Artist>?> searchArtists(String query) async {
    final rawData = await search(query, filter: "artists");
    if (rawData != null) {
      List<Artist> artists = [];
      for (var artistData in rawData) {
        artists.add(
          Artist.fromJson(artistData)
        );
      }
      return artists;
    }
    return null;
  }

  Future<List> getSuggestions(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final response = await dio.get(
      'https://ytmusic-4diq.onrender.com/search_suggestions',
      queryParameters: {
        'query': query
      }

    );

    if (response.statusCode == 200 && response.data != null) {
      final List suggestionList = response.data;
      return suggestionList;
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

}
