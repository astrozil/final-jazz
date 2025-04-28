import 'package:jazz/features/auth_feature/domain/repo/auth_repository.dart';

class UpdateFcmToken {
  final AuthRepository repository;
  UpdateFcmToken(this.repository);

  Future<void> call(String userId,String token) async {
    await  repository.updateFcmToken(userId, token);
  }
}