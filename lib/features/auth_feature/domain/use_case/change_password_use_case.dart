import 'package:jazz/features/auth_feature/domain/repo/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository authRepository;
  ChangePasswordUseCase({required this.authRepository});

  Future<void> call(String email, String oldPassword, String newPassword)async{
    return authRepository.changePassword(email, oldPassword, newPassword);
  }
}