import 'package:jazz/features/auth_feature/domain/entities/user.dart';
import 'package:jazz/features/auth_feature/domain/repo/auth_repository.dart';

class GetUserByIdUseCase {
  final AuthRepository repository;
  GetUserByIdUseCase(this.repository);

  Future<AppUser> call(String userId) async {
    return await repository.getUserById(userId);
  }
}