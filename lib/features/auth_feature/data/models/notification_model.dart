import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jazz/features/auth_feature/domain/entities/notification.dart';

class NotificationModel extends Notification {
  NotificationModel({
    required String id,
    required String userId,
    required String title,
    required String body,
    required String type,
    required bool isRead,
    required String relatedUserId,


    required DateTime createdAt,
  }) : super(
    id: id,
    userId: userId,
    title: title,
    body: body,
    type: type,
    relatedUserId: relatedUserId,
   isRead: isRead,
    createdAt: createdAt,
  );

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? '',
      relatedUserId: json['relatedUserId'] ?? '',
  isRead: json['isRead']?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'relatedUserId': relatedUserId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}