import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jazz/features/song_share_feature/data/models/shared_song_model.dart';

abstract class SongShareDataSource {
  Future<void> shareSong(SharedSongModel sharedSong);
  Stream<List<SharedSongModel>> getReceivedSharedSongs(String userId);
  Stream<List<SharedSongModel>> getSentSharedSongs(String userId);
  Future<void> markAsViewed(String sharedSongId);
}

class FirebaseSharedSongDataSource implements SongShareDataSource {
  final FirebaseFirestore _firestore;

  FirebaseSharedSongDataSource(this._firestore);

  @override
  Future<void> shareSong(SharedSongModel sharedSong) async {
    await _firestore.collection('sharedSongs').add({
      'senderId': sharedSong.senderId,
      'receiverId': sharedSong.receiverId,
      'songId': sharedSong.songId,
      'songName': sharedSong.songName,
      'artistName': sharedSong.artistName,
      'type': sharedSong.type,
      'albumArt': sharedSong.albumArt,
      'message': sharedSong.message,
      'isViewed': sharedSong.isViewed,
      'createdAt': Timestamp.fromDate(sharedSong.createdAt),
    });
  }

  @override
  Stream<List<SharedSongModel>> getReceivedSharedSongs(String userId) {
    return _firestore
        .collection('sharedSongs')
        .where('receiverId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SharedSongModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    });
  }

  @override
  Stream<List<SharedSongModel>> getSentSharedSongs(String userId) {
    return _firestore
        .collection('sharedSongs')
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SharedSongModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    });
  }

  @override
  Future<void> markAsViewed(String sharedSongId) async {
    await _firestore.collection('sharedSongs').doc(sharedSongId).update({
      'isViewed': true,
    });
  }
}