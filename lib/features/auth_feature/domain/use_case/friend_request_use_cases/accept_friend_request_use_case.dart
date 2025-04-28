import 'package:jazz/features/auth_feature/domain/entities/notification.dart';
import 'package:jazz/features/auth_feature/domain/repo/auth_repository.dart';
import 'package:jazz/features/auth_feature/domain/repo/friend_request_repository.dart';
import 'package:jazz/features/auth_feature/domain/repo/notification_repository.dart';
import 'package:jazz/features/auth_feature/domain/repo/push_notification_repository.dart';

class AcceptFriendRequestUseCase {
  final FriendRequestRepository repository;
  final AuthRepository userRepository;
  final NotificationRepository notificationRepository;
  final PushNotificationRepository pushNotificationRepository;

  AcceptFriendRequestUseCase(this.repository, this.userRepository, this.notificationRepository, this.pushNotificationRepository);

  Future<void> execute(String requestId, String currentUserId) async {
    // Accept the friend request
    await repository.acceptFriendRequest(requestId);

    // Get the request details to know who sent it
    // final requests = await repository.getReceivedRequests(currentUserId).first;
    // final request = requests.firstWhere((req) => req.id == requestId,
    //     );
    // // Get user information
    // final currentUser = await userRepository.getUserById(currentUserId);
    // final requester = await userRepository.getUserById(request.senderId);
    //
    // // Create notification for the requester
    // final notification = Notification(
    //   id: '',
    //   userId: request.senderId,
    //   title: 'Friend Request Accepted',
    //   body: '${currentUser.name} accepted your friend request',
    //   type: 'request_accepted',
    //   relatedUserId: currentUserId,
    //   isRead: false,
    //   createdAt: DateTime.now(),
    // );
    // await notificationRepository.createNotification(notification);
    //
    // // Send push notification if requester has FCM token
    // if (requester.fcmToken != null && requester.fcmToken!.isNotEmpty) {
    //   await pushNotificationRepository.sendPushNotification(
    //     requester.fcmToken!,
    //     'Friend Request Accepted',
    //     '${currentUser.name} accepted your friend request',
    //     {
    //       'type': 'request_accepted',
    //       'userId': currentUserId,
    //     },
    //   );
    // }
  }
}