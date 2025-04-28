import 'package:jazz/features/auth_feature/domain/entities/user.dart';
import 'package:jazz/features/auth_feature/domain/repo/auth_repository.dart';

class GetFriendsUseCase {
  final AuthRepository repository;
  GetFriendsUseCase(this.repository);

  Stream<List<AppUser>> call(String userId)  {
    return  repository.getFriends(userId);
  }
}