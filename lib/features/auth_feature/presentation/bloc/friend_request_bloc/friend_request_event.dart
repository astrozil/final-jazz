part of 'friend_request_bloc.dart';

@immutable
sealed class FriendRequestEvent {}

class SendFriendRequestEvent extends FriendRequestEvent {
  final String receiverId;
  SendFriendRequestEvent(this.receiverId);
}

class AcceptFriendRequestEvent extends FriendRequestEvent {
  final String requestId;
  AcceptFriendRequestEvent(this.requestId);
}
class CancelSentFriendRequestEvent extends FriendRequestEvent {
  final String requestId;
  CancelSentFriendRequestEvent(this.requestId);
}

class RejectFriendRequestEvent extends FriendRequestEvent {
  final String requestId;
  RejectFriendRequestEvent(this.requestId);
}
class UnfriendEvent extends FriendRequestEvent {
  final String friendUserId;

  UnfriendEvent({required this.friendUserId,});

}


class GetReceivedFriendRequestsEvent extends FriendRequestEvent {}
class GetSentFriendRequestsEvent extends FriendRequestEvent {}

class SetCurrentUserIdEvent extends FriendRequestEvent {
  final String userId;
  SetCurrentUserIdEvent(this.userId);
}

// Private events for internal use
class _ReceivedFriendRequestsUpdated extends FriendRequestEvent {
  final List<FriendRequest> requests;
  _ReceivedFriendRequestsUpdated(this.requests);
}

class _SentFriendRequestsUpdated extends FriendRequestEvent {
  final List<FriendRequest> requests;
  _SentFriendRequestsUpdated(this.requests);
}

class _FriendRequestError extends FriendRequestEvent {
  final String message;
  _FriendRequestError(this.message);
}
class GetAllRequestsEvent extends FriendRequestEvent{

            }

class _AllRequestsUpdated extends FriendRequestEvent {
  final List<FriendRequest> requests;

  _AllRequestsUpdated(this.requests);
}