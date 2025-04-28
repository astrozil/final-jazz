import 'package:jazz/features/auth_feature/domain/entities/friend_request.dart';
import 'package:jazz/features/auth_feature/domain/repo/friend_request_repository.dart';

class CancelSentFriendRequestUseCase {
  final FriendRequestRepository repository;


  CancelSentFriendRequestUseCase
      (this.repository);

  Future<void> execute(String requestId)  {

    return repository.cancelSentFriendRequest(requestId);

  }
}
