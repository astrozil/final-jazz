
import 'package:jazz/features/auth_feature/domain/entities/user.dart';

abstract class AuthRepository {
  Future<void> signUp(String email, String password);
  Future<void> signIn(String email, String password);
  Future<void> resetPassword({required String email});
  Future<void> signInWithGoogle();
  Future<bool> isUserLoggedIn();
  Future<void> logout();
  Stream<List<AppUser>> searchUsers(String query);
  Future<void> createUserProfile(AppUser user);
  Future<void> updateUserProfile(AppUser user);
  Future<void> changePassword(String email, String oldPassword, String newPassword);
  Future<AppUser> getUserById(String userId);
  Stream<List<AppUser>> getFriends(String userId);
  Future<void> updateFcmToken(String userId, String token);
  Future<void> updateEmail({
    required String password,
    required String newEmail,
  });


}