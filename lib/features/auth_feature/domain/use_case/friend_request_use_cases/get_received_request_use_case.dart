import 'package:jazz/features/auth_feature/domain/entities/friend_request.dart';
import 'package:jazz/features/auth_feature/domain/repo/friend_request_repository.dart';

class GetReceivedRequestUseCase {
  final FriendRequestRepository repository;


  GetReceivedRequestUseCase
      (this.repository);

  Stream<List<FriendRequest>> execute(String requestId)  {

    return repository.getReceivedRequests(requestId);

  }
}
