import 'package:jazz/features/auth_feature/data/data_source/notification_data_source.dart';
import 'package:jazz/features/auth_feature/data/models/notification_model.dart';
import 'package:jazz/features/auth_feature/domain/entities/notification.dart';
import 'package:jazz/features/auth_feature/domain/repo/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDataSource dataSource;

  NotificationRepositoryImpl(this.dataSource);

  @override
  Future<void> createNotification(Notification notification) =>
      dataSource.createNotification(NotificationModel(
        id: notification.id,
        userId: notification.userId,
        title: notification.title,
        body: notification.body,
        type: notification.type,
        relatedUserId: notification.relatedUserId,
        isRead: notification.isRead,
        createdAt: notification.createdAt,
      ));

  @override
  Future<void> markAsRead(String notificationId) =>
      dataSource.markAsRead(notificationId);

  @override
  Stream<List<Notification>> getUserNotifications() =>
      dataSource.getUserNotifications();

  @override
  Future<void> deleteNotification({required String notificationId})async {
    dataSource.deleteNotification(notificationId);
  }
}