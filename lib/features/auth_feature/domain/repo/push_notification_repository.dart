abstract class PushNotificationRepository {
  Future<void> sendPushNotification(String receiverToken, String title, String body, Map<String, dynamic> data);
  Future<String?> getFcmToken();
  Future<void> initialize();
}