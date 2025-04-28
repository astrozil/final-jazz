import 'package:jazz/features/auth_feature/domain/entities/notification.dart';
import 'package:jazz/features/auth_feature/domain/repo/auth_repository.dart';
import 'package:jazz/features/auth_feature/domain/repo/friend_request_repository.dart';
import 'package:jazz/features/auth_feature/domain/repo/notification_repository.dart';
import 'package:jazz/features/auth_feature/domain/repo/push_notification_repository.dart';

class SendFriendRequestUseCase {
  final FriendRequestRepository repository;
  final AuthRepository userRepository;
  final NotificationRepository notificationRepository;
  final PushNotificationRepository pushNotificationRepository;

  SendFriendRequestUseCase(this.repository, this.userRepository, this.notificationRepository, this.pushNotificationRepository);

  Future<void> execute(String senderId, String receiverId) async {
    // Send the friend request
    await repository.sendFriendRequest(senderId, receiverId);

    // Get sender and receiver info
    final sender = await userRepository.getUserById(senderId);
    final receiver = await userRepository.getUserById(receiverId);

    // Create notification in database
    final notification = Notification(
      id: '',  // Firebase will generate this
      userId: receiverId,
      title: 'New Friend Request',
      body: '${sender.name} sent you a friend request',
      type: 'friend_request',
      relatedUserId: senderId,
      isRead: false,
      createdAt: DateTime.now(),
    );
    await notificationRepository.createNotification(notification);

    // Send push notification if receiver has FCM token
    if (receiver.fcmToken != null && receiver.fcmToken!.isNotEmpty) {
      await pushNotificationRepository.sendPushNotification(
        receiver.fcmToken!,
        'New Friend Request',
        '${sender.name} sent you a friend request',
        {
          'type': 'friend_request',
          'senderId': senderId,
        },
      );
    }
  }
}