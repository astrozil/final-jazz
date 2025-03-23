
import 'package:jazz/features/auth_feature/data/data_source/auth_data_source.dart';
import 'package:jazz/features/auth_feature/domain/entities/user.dart';
import 'package:jazz/features/auth_feature/domain/repo/auth_repository.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource authDataSource;

  AuthRepositoryImpl(this.authDataSource);

  @override
  Future<void> signUp(String email, String password) async {
    await authDataSource.signUp(
      email,
      password,
    );
  }

  @override
  Future<void> signIn(String email, String password) async {
    await authDataSource.signIn(
      email,
      password,
    );
  }
  @override
  Future<void> signInWithGoogle() async {
    return authDataSource.signInWithGoogle();
  }

  @override
  Future<bool> isUserLoggedIn()async {
    return authDataSource.isUserLoggedIn();
  }
  @override
  Future<void> logout()async {
     return authDataSource.logout();
  }
  @override
  Future<void> createUserProfile(AppUser user)async {
    return authDataSource.createUserProfile(user);
  }

  @override
  Future<void> updateUserProfile(AppUser user)async {
    return authDataSource.updateUserProfile(user);
  }
  @override
  Future<void> changePassword(String email, String oldPassword, String newPassword) {
  return authDataSource.changePassword(email, oldPassword, newPassword);
  }
}
