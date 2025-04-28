class SharedSong {
  final String id;
  final String senderId;
  final String receiverId;
  final String songId;
  final String songName;
  final List artistName;
  final String type;
  final String albumArt;
  final String message;
  final bool isViewed;
  final DateTime createdAt;

  SharedSong({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.songId,
    required this.songName,
    required this.artistName,
    required this.albumArt,
    required this.type,
    required this.message,
    required this.isViewed,
    required this.createdAt,
  });
}