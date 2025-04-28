import 'package:jazz/features/auth_feature/domain/entities/friend_request.dart';

abstract class FriendRequestRepository {
  Future<void> sendFriendRequest(String senderId, String receiverId);
  Future<void> cancelSentFriendRequest(String requestId);
  Future<void> acceptFriendRequest(String requestId);
  Future<void> rejectFriendRequest(String requestId);
  Future<void> unFriend(String friendUserId,String userId);
  Stream<List<FriendRequest>> getSentRequests(String userId);
  Stream<List<FriendRequest>> getReceivedRequests(String userId);
}