// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gotrue/src/types/types.dart' as gotrue;
import 'package:jazz/features/auth_feature/domain/entities/user.dart';

class AuthDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final FirebaseFirestore firebaseFirestore;

  AuthDataSource({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.firebaseFirestore,
  });

  Future<void> signUp(String email, String password) async {
    // Create user in Firebase.
    await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Create user in Supabase.
    final response = await Supabase.instance.client.auth.signUp(email: email, password: password);
    // Instead of checking for an error field, verify the response contains a user.
    if (response.user == null) {
      throw Exception("Supabase sign up error");
    }
  }

  Future<void> signIn(String email, String password) async {
    // Sign in with Firebase.
    await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Sign in with Supabase.
    final response = await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
    if (response.user == null) {
      throw Exception("Supabase sign in error");
    }
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign in aborted');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    // Sign in with Firebase using the Google credentials.
    await firebaseAuth.signInWithCredential(credential);



  }

  Future<bool> isUserLoggedIn() async {
    return firebaseAuth.currentUser != null;
  }

  Future<void> logout() async {
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
    await Supabase.instance.client.auth.signOut();
  }

  Future<void> createUserProfile(AppUser user) async {
    await firebaseFirestore.collection('Users').doc(user.id).set(user.toJson());
  }

  Future<void> updateUserProfile(AppUser user) async {
    await firebaseFirestore.collection('Users').doc(user.id).update(user.toJson());
  }

  Future<void> changePassword(String email, String oldPassword, String newPassword) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception("No user is currently signed in.");
    }

    try {

      AuthCredential credential = EmailAuthProvider.credential(email: email, password: oldPassword);
      await user.reauthenticateWithCredential(credential);

      // Update password in Firebase
      await user.updatePassword(newPassword);


      final response = await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        throw Exception("Supabase password update failed.");
      }
    } catch (e) {
      throw Exception("Failed to update password: $e");
    }
  }

}
