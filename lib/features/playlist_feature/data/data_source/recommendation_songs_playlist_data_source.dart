import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jazz/features/auth_feature/domain/entities/user.dart';
import 'package:jazz/features/search_feature/domain/entities/artist.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';

class RecommendationSongsPlaylistDataSource {
  final Dio dio;
  final String baseUrl;

  RecommendationSongsPlaylistDataSource({
    Dio? dio,
    this.baseUrl = 'https://ytmusic-4diq.onrender.com/recommendations',
  }) : dio = dio ?? Dio();

  Future<List<RelatedSong>> fetchRecommendedSongs() async {
    List<RelatedSong> recommendedSongs = [];
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection("Users").doc(userId).get();
      AppUser appUser = AppUser.fromJson(documentSnapshot.data() as Map<String,dynamic>);
      final response = await dio.post(baseUrl,
      data: {
        "song_ids": appUser.songHistory
      }
      );
      if (response.statusCode == 200) {

        final result = response.data;
        for(var song in result ){
          recommendedSongs.add(RelatedSong(url: "", song:Song.fromJson(song) ));
        }
        return recommendedSongs;
      } else {
        throw Exception('Failed to load artist data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching artist data: $error');
    }
  }
}
