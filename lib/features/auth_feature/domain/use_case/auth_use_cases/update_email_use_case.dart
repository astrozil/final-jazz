
import 'package:jazz/features/auth_feature/domain/repo/auth_repository.dart';

class UpdateEmailUseCase {
  final AuthRepository repository;

  UpdateEmailUseCase(this.repository);

  Future<void> call({required String password, required String newEmail}) async {
    return repository.updateEmail(password: password, newEmail: newEmail);
  }
}