import 'package:jazz/features/auth_feature/domain/repo/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<void> call(String email, String password) async {
    return repository.signIn(email, password);
  }
}