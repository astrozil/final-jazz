import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPlaylistDataSource {
  final FirebaseFirestore _fireStore;
  final FirebaseAuth _firebaseAuth;

  UserPlaylistDataSource(
      {required FirebaseFirestore fireStore,
      required FirebaseAuth firebaseAuth})
      : _fireStore = fireStore,
        _firebaseAuth = firebaseAuth;
  Future<void> createPlaylist(String title) async {
    final String userId = _firebaseAuth.currentUser!.uid;
    try {
      DocumentReference docRef = _fireStore.collection("Users").doc(userId);

      await docRef.collection("Playlists").doc("$userId${DateTime.now()}").set({
        "title": title,
        "tracks": [],
      });
    } catch (e) {
      print('Error adding favourite song: $e');
    }
  }
  Future<void> deletePlaylist(String playlistId) async {
    final String userId = _firebaseAuth.currentUser!.uid;
    try {
      DocumentReference docRef = _fireStore.collection("Users").doc(userId);

      await docRef.collection("Playlists").doc(playlistId).delete();
    } catch (e) {
      print('Error adding favourite song: $e');
    }
  }

  Future<List<Map>?> fetchPlaylists()async{
    final String userId = _firebaseAuth.currentUser!.uid;
    List<Map<String,dynamic>> playlists = [];
    try{
      QuerySnapshot querySnapshot = await _fireStore.collection("Users").doc(userId)
                                    .collection("Playlists").get();
      for (var playlist in querySnapshot.docs) {
        playlists.add(playlist.data() as Map<String,dynamic>);
      }
      return  playlists;
    }catch(e){
      print(e.toString());
    }
    return null;
  }

  Future<void> changePlaylistTitle(String title,String playlistId)async{
    final String userId = _firebaseAuth.currentUser!.uid;

    try{
     await _fireStore.collection("Users").doc(userId)
          .collection("Playlists").doc(playlistId).update({
       "title": title
     });
    }catch(e){
      print(e.toString());
    }
  }


  Future<void> addSongToPlaylist(String songId, String playlistId) async {
    final String userId = _firebaseAuth.currentUser!.uid;
    try {
      CollectionReference subCollectionRef =
          _fireStore.collection("Users").doc(userId).collection("Playlists");
      await subCollectionRef.doc(playlistId).update({
        'tracks': FieldValue.arrayUnion([songId])
      });
      await _fireStore.collection("Users").doc(userId).update({});
    } catch (e) {
      print('Error adding favourite song: $e');
    }
  }

  Future<void> removeSongFromPlaylist(String songId, String playlistId) async {
    final String userId = _firebaseAuth.currentUser!.uid;
    try {
      CollectionReference subCollectionRef =
          _fireStore.collection("Users").doc(userId).collection("Playlists");
      await subCollectionRef.doc(playlistId).update({
        'songs': FieldValue.arrayRemove([songId])
      });
    } catch (e) {
      print('Error adding favourite song: $e');
    }
  }
}
