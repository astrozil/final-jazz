part of 'notification_bloc.dart';

@immutable
sealed class NotificationEvent {}
class GetUserNotificationsEvent extends NotificationEvent {}

class MarkNotificationAsReadEvent extends NotificationEvent {
  final String notificationId;
  MarkNotificationAsReadEvent(this.notificationId);
}

class SetCurrentUserIdNotificationEvent extends NotificationEvent {
  final String userId;
  SetCurrentUserIdNotificationEvent(this.userId);
}

// Private events
class _NotificationsUpdated extends NotificationEvent {
  final List<Notification> notifications;
  _NotificationsUpdated(this.notifications);
}

class _NotificationError extends NotificationEvent {
  final String message;
  _NotificationError(this.message);
}
