import 'package:jazz/features/auth_feature/domain/entities/notification.dart';

import 'package:jazz/features/auth_feature/domain/repo/notification_repository.dart';

class MarkAsReadUseCase {
  final NotificationRepository repository;


  MarkAsReadUseCase(this.repository);

  Future<void> execute(String notificationId) async {

    await repository.markAsRead(notificationId);

  }
}
