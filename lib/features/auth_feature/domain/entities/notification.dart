class Notification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String relatedUserId;
  final bool isRead;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.relatedUserId,
    required this.isRead,
    required this.createdAt,
  });
}