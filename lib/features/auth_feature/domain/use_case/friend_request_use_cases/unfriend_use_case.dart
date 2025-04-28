import 'package:jazz/features/auth_feature/domain/entities/friend_request.dart';
import 'package:jazz/features/auth_feature/domain/repo/friend_request_repository.dart';

class UnfriendUseCase {
  final FriendRequestRepository repository;


  UnfriendUseCase
      (this.repository);

   Future<void> execute(String friendUserId,String userId)async  {

    return repository.unFriend(friendUserId,userId);

  }
}
