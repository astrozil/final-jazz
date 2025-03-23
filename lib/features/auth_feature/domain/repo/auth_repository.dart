
import 'package:jazz/features/auth_feature/domain/entities/user.dart';

abstract class AuthRepository {
  Future<void> signUp(String email, String password);
  Future<void> signIn(String email, String password);
  Future<void> signInWithGoogle();
  Future<bool> isUserLoggedIn();
  Future<void> logout();
  Future<void> createUserProfile(AppUser user);
  Future<void> updateUserProfile(AppUser user);
  Future<void> changePassword(String email, String oldPassword, String newPassword);
}