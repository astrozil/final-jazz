import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';

class FavouritePlaylistDataSource{
  final FirebaseFirestore _fireStore;
  final FirebaseAuth _firebaseAuth;
  final Dio dio;
  final String baseUrl;

  FavouritePlaylistDataSource({
    Dio? dio,
    this.baseUrl = 'https://ytmusic-4diq.onrender.com/songs',
    required FirebaseFirestore fireStore,
    required FirebaseAuth firebaseAuth}) :
        dio = dio ?? Dio(),
        _fireStore = fireStore,
        _firebaseAuth = firebaseAuth;

  Future<List<RelatedSong>> fetchBillboardSongs(List<String> songIds) async {
    List<RelatedSong> favouriteSongs = [];
    try {
      final response = await dio.post(baseUrl,data: {
        "song_ids": songIds
      });
      if (response.statusCode == 200) {

        final result = response.data;
        for(var favouriteSong in result ){
          favouriteSongs.add(RelatedSong.fromJson(favouriteSong));
        }
        return favouriteSongs;
      } else {
        throw Exception('Failed to load favourite songs data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching favourite songs data: $error');
    }
  }

  Future<void> addFavouriteSong( String songId) async {
    final String userId = _firebaseAuth.currentUser!.uid;
    try {
      await _fireStore.collection('Users').doc(userId).update({
        'favouriteSongs': FieldValue.arrayUnion([songId]),
        'updatedAt': "${DateTime.now()}",
      });
    } catch (e) {
      print('Error adding favourite song: $e');
    }
  }

  Future<void> removeFavouriteSong( String songId) async {

    final String userId = _firebaseAuth.currentUser!.uid;
    try {
      await _fireStore.collection('Users').doc(userId).update({
        'favouriteSongs': FieldValue.arrayRemove([songId]),
        'updatedAt': "${DateTime.now()}",
      });
    } catch (e) {
      print('Error removing favourite song: $e');
    }
  }



}