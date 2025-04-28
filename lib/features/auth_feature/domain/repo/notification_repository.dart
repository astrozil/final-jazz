import 'package:jazz/features/auth_feature/domain/entities/notification.dart';

abstract class NotificationRepository {
  Future<void> createNotification(Notification notification);
  Future<void> markAsRead(String notificationId);
  Stream<List<Notification>> getUserNotifications();
}