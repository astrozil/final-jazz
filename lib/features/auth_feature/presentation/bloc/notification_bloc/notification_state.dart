part of 'notification_bloc.dart';

@immutable
sealed class NotificationState {}

class NotificationInitial extends NotificationState {}
class NotificationLoading extends NotificationState {}
class NotificationSuccess extends NotificationState {}
class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}

class NotificationsLoaded extends NotificationState {
  final List<Notification> notifications;
  NotificationsLoaded(this.notifications);
}
