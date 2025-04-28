import 'package:jazz/features/auth_feature/domain/repo/auth_repository.dart';

class ResetPasswordUseCase {

  final AuthRepository authRepository;

  ResetPasswordUseCase({required this.authRepository});

  Future<void> execute({required String email})async{
    await authRepository.resetPassword(email: email);
  }
}