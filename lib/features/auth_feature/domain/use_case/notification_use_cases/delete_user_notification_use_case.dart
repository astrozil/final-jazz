import 'package:jazz/features/auth_feature/domain/repo/notification_repository.dart';

class DeleteUserNotificationUseCase{
  final NotificationRepository notificationRepository;

  DeleteUserNotificationUseCase({required this.notificationRepository});

  Future<void> call({required String notificationId})async{
    await notificationRepository.deleteNotification(notificationId: notificationId);
  }

}