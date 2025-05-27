import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:jazz/features/auth_feature/domain/entities/notification.dart';
import 'package:jazz/features/auth_feature/domain/use_case/notification_use_cases/delete_user_notification_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/notification_use_cases/get_user_notifications_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/notification_use_cases/mark_as_read_use_case.dart';
import 'package:meta/meta.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetUserNotificationsUseCase _getUserNotifications;
  final MarkAsReadUseCase _markNotificationAsRead;
  final DeleteUserNotificationUseCase _deleteUserNotificationUseCase;
  StreamSubscription? _notificationsSubscription;
  String _currentUserId = '';

  NotificationBloc(
      this._getUserNotifications,
      this._markNotificationAsRead,
      this._deleteUserNotificationUseCase
      ) : super(NotificationInitial()) {
    on<GetUserNotificationsEvent>(_onGetUserNotifications);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsRead);
    on<SetCurrentUserIdNotificationEvent>(_onSetCurrentUserId);
    on<_NotificationsUpdated>(_onNotificationsUpdated);
    on<_NotificationError>(_onNotificationError);
    on<DeleteNotification>(_onDeleteNotification);
  }

  void _onSetCurrentUserId(
      SetCurrentUserIdNotificationEvent event,
      Emitter<NotificationState> emit,
      ) {
    _currentUserId = event.userId;
  }

  void _onGetUserNotifications(
      GetUserNotificationsEvent event,
      Emitter<NotificationState> emit,
      ) {
    emit(NotificationLoading());
    _notificationsSubscription?.cancel();
    _notificationsSubscription = _getUserNotifications
        .execute()
        .listen(
          (notifications){

            add(_NotificationsUpdated(notifications));
          },
      onError: (error) => add(_NotificationError(error.toString())),
    );
  }

  Future<void> _onMarkNotificationAsRead(
      MarkNotificationAsReadEvent event,
      Emitter<NotificationState> emit,
      ) async {
    try {
      await _markNotificationAsRead.execute(event.notificationId);
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  void _onNotificationsUpdated(
      _NotificationsUpdated event,
      Emitter<NotificationState> emit,
      ) {
    emit(NotificationsLoaded(event.notifications));
  }

  void _onNotificationError(
      _NotificationError event,
      Emitter<NotificationState> emit,
      ) {
    emit(NotificationError(event.message));
  }
  void _onDeleteNotification(DeleteNotification event,Emitter<NotificationState>  emit)async{
    try{
     await _deleteUserNotificationUseCase(notificationId: event.notificationId);
      emit(DeletedNotification());
    }catch(e){
      emit(NotificationError("Notification didn't deleted. Try again later."));
    }
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}