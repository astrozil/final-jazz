import 'package:jazz/features/auth_feature/data/data_source/friend_request_data_source.dart';
import 'package:jazz/features/auth_feature/domain/entities/friend_request.dart';
import 'package:jazz/features/auth_feature/domain/repo/friend_request_repository.dart';

class FriendRequestRepositoryImpl implements FriendRequestRepository {
  final FriendRequestDataSource dataSource;

  FriendRequestRepositoryImpl(this.dataSource);

  @override
  Future<void> sendFriendRequest(String senderId, String receiverId) =>
      dataSource.sendFriendRequest(senderId, receiverId);

  @override
  Future<void> acceptFriendRequest(String requestId) =>
      dataSource.acceptFriendRequest(requestId);

  @override
  Future<void> rejectFriendRequest(String requestId) =>
      dataSource.rejectFriendRequest(requestId);

  @override
  Stream<List<FriendRequest>> getSentRequests(String userId) =>
      dataSource.getSentRequests(userId);

  @override
  Stream<List<FriendRequest>> getReceivedRequests(String userId) =>
      dataSource.getReceivedRequests(userId);

  @override
  Future<void> cancelSentFriendRequest(String requestId)async {
    await dataSource.cancelSentFriendRequest(requestId);
  }

  @override
  Future<void> unFriend(String friendUserId, String userId)async {
    await dataSource.unFriend(friendUserId, userId);
  }
}
