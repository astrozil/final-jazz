import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jazz/features/auth_feature/data/models/friend_request_model.dart';

abstract class FriendRequestDataSource {
  Future<void> sendFriendRequest(String senderId, String receiverId);
  Future<void> cancelSentFriendRequest(String requestId);
  Future<void> acceptFriendRequest(String requestId);
  Future<void> rejectFriendRequest(String requestId);
  Future<void> unFriend(String friendUserId,String userId);
  Stream<List<FriendRequestModel>> getSentRequests(String userId);
  Stream<List<FriendRequestModel>> getReceivedRequests(String userId);
}


class FirebaseFriendRequestDataSource implements FriendRequestDataSource {
  final FirebaseFirestore _firestore;

  FirebaseFriendRequestDataSource(this._firestore);

  @override
  Future<void> sendFriendRequest(String senderId, String receiverId) async {
    // Check if a friend request already exists with the same sender and receiver
    final querySnapshot = await _firestore
        .collection('friendRequests')
        .where('senderId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('receiverId', isEqualTo: receiverId)
        .get();
    final querySnapshot2 = await _firestore
        .collection('friendRequests')
        .where('senderId', isEqualTo: receiverId)
        .where('receiverId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    // Only add a new request if no existing request is found
    if (querySnapshot.docs.isEmpty && querySnapshot2.docs.isEmpty) {
      await _firestore.collection('friendRequests').add({
        'senderId': FirebaseAuth.instance.currentUser!.uid,
        'receiverId': receiverId,
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });
    } else {
      // Optional: Handle the case where a request already exists
      print('Friend request already exists');
      // You could throw an exception or return a message here
    }
  }


  @override
  Future<void> acceptFriendRequest(String requestId) async {
    await _firestore.collection('friendRequests').doc(requestId).update({
      'status': 'accepted',
    });

    // Add users to each other's friends list
    final requestDoc = await _firestore.collection('friendRequests').doc(
        requestId).get();
    final requestData = requestDoc.data();

    if (requestData != null) {
      final senderId = requestData['senderId'] as String;
      final receiverId = requestData['receiverId'] as String;

      // Add to sender's friends
      await _firestore.collection('Users').doc(senderId)
          .collection('friends')
          .doc(receiverId)
          .set({
        'addedAt': Timestamp.now(),
      });

      // Add to receiver's friends
      await _firestore.collection('Users').doc(receiverId)
          .collection('friends')
          .doc(senderId)
          .set({
        'addedAt': Timestamp.now(),
      });
    }
  }

  @override
  Future<void> rejectFriendRequest(String requestId) async {
    await _firestore.collection('friendRequests').doc(requestId).update({
      'status': 'rejected',
    });
  }

  @override
  Stream<List<FriendRequestModel>> getSentRequests(String userId) {

    return _firestore
        .collection('friendRequests')
        .where('senderId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FriendRequestModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    });
  }

  @override
  Stream<List<FriendRequestModel>> getReceivedRequests(String userId) {
    return _firestore
        .collection('friendRequests')
        .where('receiverId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FriendRequestModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    });
  }

  @override
  Future<void> cancelSentFriendRequest(String requestId) async{
    await _firestore.collection('friendRequests')
        .doc(requestId).delete();
  }

  @override
  Future<void> unFriend(String friendUserId,String userId)async {
    await _firestore.collection('Users').doc(userId).collection("friends").doc(friendUserId).delete();
    await _firestore.collection('Users').doc(friendUserId).collection('friends').doc(userId).delete();
    final sentRequests = await _firestore.collection("friendRequests")
        .where('senderId',isEqualTo: userId)
    .where('receiverId',isEqualTo: friendUserId)
    .get();

    for(var doc in sentRequests.docs){
      await doc.reference.delete();
    }
    final receivedRequests = await _firestore.collection("friendRequests")
        .where('senderId',isEqualTo: friendUserId)
        .where('receiverId',isEqualTo: userId)
        .get();

    for(var doc in receivedRequests.docs){
      await doc.reference.delete();
    }
  }
}