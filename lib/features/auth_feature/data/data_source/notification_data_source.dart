import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jazz/features/auth_feature/data/models/notification_model.dart';

abstract class NotificationDataSource {
  Future<void> createNotification(NotificationModel notification);
  Future<void> markAsRead(String notificationId);
  Stream<List<NotificationModel>> getUserNotifications();
}

class FirebaseNotificationDataSource implements NotificationDataSource {
  final FirebaseFirestore _firestore;

  FirebaseNotificationDataSource(this._firestore);

  @override
  Future<void> createNotification(NotificationModel notification) async {
    await _firestore.collection('notifications').add(notification.toJson());
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  @override
  Stream<List<NotificationModel>> getUserNotifications() {

    final String userId = FirebaseAuth.instance.currentUser!.uid;
    print(userId);
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {


      return snapshot.docs.map((doc) {
        return NotificationModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    });
  }
}