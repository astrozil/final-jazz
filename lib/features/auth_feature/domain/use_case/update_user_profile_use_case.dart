import 'package:jazz/features/auth_feature/domain/entities/user.dart';
import 'package:jazz/features/auth_feature/domain/repo/auth_repository.dart';

class UpdateUserProfileUseCase {
  final AuthRepository authRepository;

  UpdateUserProfileUseCase({required this.authRepository});

  Future<void> call(AppUser user)async{
    return authRepository.updateUserProfile(user);
  }
}