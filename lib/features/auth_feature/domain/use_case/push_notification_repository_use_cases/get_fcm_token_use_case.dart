import 'package:jazz/features/auth_feature/domain/entities/notification.dart';

import 'package:jazz/features/auth_feature/domain/repo/notification_repository.dart';
import 'package:jazz/features/auth_feature/domain/repo/push_notification_repository.dart';

class GetFcmTokenUseCase {
  final PushNotificationRepository repository;


  GetFcmTokenUseCase(this.repository);

  Future<String?> execute()async  {

    return repository.getFcmToken();

  }
}
