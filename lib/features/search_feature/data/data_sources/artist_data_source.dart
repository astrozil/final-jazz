import 'package:dio/dio.dart';
import 'package:jazz/features/search_feature/domain/entities/artist.dart';

class ArtistDataSource {
  final Dio dio;
  final String baseUrl;
  final String artistsUrl;

  ArtistDataSource({
    Dio? dio,
    this.baseUrl = 'https://ytmusic-4diq.onrender.com/artist/',
    this.artistsUrl = 'https://ytmusic-4diq.onrender.com/artists'
  }) : dio = dio ?? Dio();

  /// Retrieves the artist data for a given [artistId]
  Future<Artist> fetchArtist(String artistId) async {
    final String url = '$baseUrl$artistId';
    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {

        final artist = Artist.fromJson(response.data);
        return artist;
      } else {
        throw Exception('Failed to load artist data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching artist data: $error');
    }
  }
  Future<List> fetchArtists(List<String>artistIdList) async {
    final String url = artistsUrl;
     List artists = [];

    try {
      final response = await dio.post(url,data: {
        "artist_ids": artistIdList
      });
      if (response.statusCode == 200) {

        artists = response.data['artists'];

        return artists;

      } else {
        throw Exception('Failed to load artist data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching artist data: $error');
    }
  }

}
