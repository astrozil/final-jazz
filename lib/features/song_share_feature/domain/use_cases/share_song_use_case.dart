import 'package:jazz/features/auth_feature/domain/entities/notification.dart';
import 'package:jazz/features/auth_feature/domain/repo/auth_repository.dart';
import 'package:jazz/features/auth_feature/domain/repo/notification_repository.dart';
import 'package:jazz/features/auth_feature/domain/repo/push_notification_repository.dart';
import 'package:jazz/features/song_share_feature/domain/entities/shared_song.dart';
import 'package:jazz/features/song_share_feature/domain/repo/song_share_repo.dart';

class ShareSong {
  final SharedSongRepository sharedSongRepository;
  final NotificationRepository notificationRepository;
  final PushNotificationRepository pushNotificationRepository;
  final AuthRepository userRepository;

  ShareSong(this.sharedSongRepository, this.notificationRepository,
      this.pushNotificationRepository, this.userRepository);

  Future<void> execute(SharedSong sharedSong) async {
    // Share the song
    await sharedSongRepository.shareSong(sharedSong);

    // Create a notification
    final sender = await userRepository.getUserById(sharedSong.senderId);
    final receiver = await userRepository.getUserById(sharedSong.receiverId);

    final notification = Notification(
      id: '',
      userId: sharedSong.receiverId,
      title: 'New Song Shared',
      body: '${sender.name} shared "${sharedSong.songName}" by ${sharedSong
          .artistName} with you',
      type: 'shared_song',
      relatedUserId: sharedSong.senderId,
      isRead: false,
      createdAt: DateTime.now(),
    );
    await notificationRepository.createNotification(notification);

    // Send push notification
    if (receiver.fcmToken!.isNotEmpty) {
      await pushNotificationRepository.sendPushNotification(
        receiver.fcmToken!,
        'New Song Shared',
        '${sender.name} shared "${sharedSong.songName}" by ${sharedSong
            .artistName} with you',
        {
          'type': 'shared_song',
          'senderId': sharedSong.senderId,
          'songId': sharedSong.songId,
          'message': sharedSong.message,
        },
      );
    }
  }
}