import 'package:jazz/features/auth_feature/domain/repo/friend_request_repository.dart';

class RejectFriendRequestUseCase {
  final FriendRequestRepository repository;


  RejectFriendRequestUseCase(this.repository);

  Future<void> execute(String requestId, String currentUserId) async {
    // Reject the friend request
    await repository.rejectFriendRequest(requestId);
    // No notification is sent when request is rejected (optional)
  }
}
