import 'package:jazz/features/auth_feature/domain/entities/notification.dart';

import 'package:jazz/features/auth_feature/domain/repo/notification_repository.dart';

class GetUserNotificationsUseCase {
  final NotificationRepository repository;


  GetUserNotificationsUseCase(this.repository);

  Stream<List<Notification>> execute()  {

    return repository.getUserNotifications();

  }
}
