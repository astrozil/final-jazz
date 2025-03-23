import 'package:jazz/features/auth_feature/domain/repo/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<void> call(String email, String password) async {
    return repository.signUp(email, password);
  }
}