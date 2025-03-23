import 'package:dio/dio.dart';
import 'package:jazz/features/playlist_feature/domain/entities/billboard_song.dart';


class BillboardDataSource {
  final Dio dio;
  final String baseUrl;

  BillboardDataSource({
    Dio? dio,
    this.baseUrl = 'https://ytmusic-4diq.onrender.com/billboard',
  }) : dio = dio ?? Dio();

  Future<List<BillboardSong>> fetchBillboardSongs() async {
    List<BillboardSong> billboardSongs = [];
    try {
      final response = await dio.get(baseUrl);
      if (response.statusCode == 200) {

        final result = response.data;
        for(var billboardSong in result ){
          billboardSongs.add(BillboardSong.fromJson(billboardSong));
        }
        return billboardSongs;
      } else {
        throw Exception('Failed to load artist data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching artist data: $error');
    }
  }
}
