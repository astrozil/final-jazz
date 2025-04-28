import 'package:jazz/features/auth_feature/domain/repo/push_notification_repository.dart';

class PushNotificationInitializeUseCase {
  final PushNotificationRepository repository;


  PushNotificationInitializeUseCase(this.repository);

  Future<void> execute()async  {

    await repository.initialize();

  }
}
