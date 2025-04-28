import 'package:jazz/features/auth_feature/domain/repo/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  Future<void> call() async {
    return await repository.logout();

  }
}