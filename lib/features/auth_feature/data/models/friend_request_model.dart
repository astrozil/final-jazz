import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jazz/features/auth_feature/domain/entities/friend_request.dart';

class FriendRequestModel extends FriendRequest {
  FriendRequestModel({
    required String id,
    required String senderId,
    required String receiverId,
    required String status,
    required DateTime createdAt,
  }) : super(
    id: id,
    senderId: senderId,
    receiverId: receiverId,
    status: status,
    createdAt: createdAt,
  );

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}