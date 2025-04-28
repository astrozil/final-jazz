part of 'friend_request_bloc.dart';

@immutable
sealed class FriendRequestState {}

class FriendRequestInitial extends FriendRequestState {}
class FriendRequestLoading extends FriendRequestState {}
class FriendRequestSuccess extends FriendRequestState {}
class FriendRequestError extends FriendRequestState {
  final String message;
  FriendRequestError(this.message);
}

class AllFriendRequestsLoaded extends FriendRequestState{
  final List<FriendRequest> requests;

  AllFriendRequestsLoaded({required this.requests});
}

class ReceivedFriendRequestsLoaded extends FriendRequestState {
  final List<FriendRequest> requests;
  ReceivedFriendRequestsLoaded(this.requests);
}

class SentFriendRequestsLoaded extends FriendRequestState {
  final List<FriendRequest> requests;
  SentFriendRequestsLoaded(this.requests);
}

