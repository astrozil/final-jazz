import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jazz/features/song_share_feature/domain/entities/shared_song.dart';

class SharedSongModel extends SharedSong {
  SharedSongModel({
    required String id,
    required String senderId,
    required String receiverId,
    required String songId,
    required String songName,
    required String artistName,
    required String type,
    required String albumArt,
    required String message,
    required bool isViewed,
    required DateTime createdAt,
  }) : super(
    id: id,
    senderId: senderId,
    receiverId: receiverId,
    songId: songId,
    songName: songName,
    artistName: artistName,
    type: type,
    albumArt: albumArt,
    message: message,
    isViewed: isViewed,
    createdAt: createdAt,
  );

  factory SharedSongModel.fromJson(Map<String, dynamic> json) {
    return SharedSongModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      songId: json['songId'] ?? '',
      songName: json['songName'] ?? '',
      artistName: json['artistName'] ?? [],
      type: json['type'] ?? 'single',
      albumArt: json['albumArt'] ?? '',
      message: json['message'] ?? '',
      isViewed: json['isViewed'] ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'songId': songId,
      'songName': songName,
      'artistName': artistName,
      'type': type,
      'albumArt': albumArt,
      'message': message,
      'isViewed': isViewed,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}