import 'package:jazz/features/auth_feature/domain/entities/user.dart';
import 'package:jazz/features/auth_feature/domain/repo/auth_repository.dart';

class CreateUserProfileUseCase {
  final AuthRepository repository;
  CreateUserProfileUseCase(this.repository);

  Future<void> call(AppUser user) async {
    return repository.createUserProfile(user);
  }
}