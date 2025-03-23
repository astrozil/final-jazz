import 'package:jazz/features/auth_feature/domain/repo/auth_repository.dart';

class GetAuthStatusUseCase {
  final AuthRepository repository;
  GetAuthStatusUseCase(this.repository);

  Future<bool> call() async {
    return await repository.isUserLoggedIn();
  }
}