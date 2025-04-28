import 'package:jazz/features/auth_feature/domain/entities/notification.dart';

import 'package:jazz/features/auth_feature/domain/repo/notification_repository.dart';
import 'package:jazz/features/auth_feature/domain/repo/push_notification_repository.dart';

class SendPushNotificationUseCase {
  final PushNotificationRepository repository;


  SendPushNotificationUseCase(this.repository);

  Future<void> execute(String receiverToken, String title, String body, Map<String, dynamic> data)async  {

    await repository.sendPushNotification(receiverToken, title, body, data);

  }
}
