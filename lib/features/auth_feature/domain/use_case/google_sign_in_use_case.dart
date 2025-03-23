import 'package:jazz/features/auth_feature/domain/repo/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<void> call() async {
    return repository.signInWithGoogle();
  }
}