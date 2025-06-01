import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:googleapis_auth/auth_io.dart';
import 'package:jazz/features/auth_feature/domain/repo/push_notification_repository.dart';

class PushNotificationRepositoryImpl implements PushNotificationRepository {
  final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final dio = Dio();

  PushNotificationRepositoryImpl(
      this._firebaseMessaging,
      this._localNotifications,

      );

  @override
  Future<void> initialize() async {
    // Request permission
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(
      initializationSettings,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'friend_requests_channel',
      'Friend Requests',
      description: 'This channel is used for friend request notifications',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon,
            ),
          ),
          payload: json.encode(message.data),
        );
      }
    });
  }

  @override
  Future<String?> getFcmToken() async {
    return await _firebaseMessaging.getToken();
  }

  @override
  Future<void> sendPushNotification(String receiverToken, String title, String body, Map<String, dynamic> data) async {
     print(data);
    try {
      final accessToken = await getAccessToken();

      // Send push notification via FCM HTTP v1 API
      await dio.post(
        'https://fcm.googleapis.com/v1/projects/jazz-cfa1f/messages:send',
        data: {
          'message': {
            'token': receiverToken,
            'notification': {
              'title': title,
              'body': body,
            },
            'data': data,
          },
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      print('Notification sent successfully!');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<String> getAccessToken() async {
    // Path to your service account JSON file
    final jsonString = await rootBundle.loadString('assets/sa.json');
    final serviceAccountCredentials = ServiceAccountCredentials.fromJson(
      json.decode(jsonString),
    );
    // Load the service account credentials


    // Define the required scope for FCM
    const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    // Obtain an authenticated HTTP client
    final client = await clientViaServiceAccount(serviceAccountCredentials, scopes);

    // Extract and return the access token
    return client.credentials.accessToken.data;
  }
}