// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

    // // Create user in Supabase.

  }

  Future<void> signIn(String email, String password) async {
    // Sign in with Firebase.

      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );


    // Sign in with Supabase.
    // final response = await Supabase.instance.client.auth.signInWithPassword(
    //     email: email, password: password);
    // if (response.user == null) {
    //   throw Exception("Supabase sign in error");
    // }
  }
  Future<void> updateEmail({

    required String password,
    required String newEmail,
  }) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception("No user is currently signed in.");
    }

    try {
      // Step 1: Re-authenticate the user first (required for security-sensitive operations)
      AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!, password: password);
      await user.reauthenticateWithCredential(credential);

      // Step 2: Update the email with verification
      await user.verifyBeforeUpdateEmail(newEmail);

      // Step 3: Update the email in Firestore if you store user emails there
      if (user.uid.isNotEmpty) {
        await firebaseFirestore.collection('Users').doc(user.uid).update({
          'email': newEmail
        });
      }
    } catch (e) {
      throw Exception("Failed to update email: ${e.toString()}");
    }
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign in aborted');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser
        .authentication;
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
    // await Supabase.instance.client.auth.signOut();
  }
  Future<void> resetPassword({required String email}) async {

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);




  }

  Future<void> createUserProfile(AppUser user) async {
    await firebaseFirestore.collection('Users').doc(user.id).set(user.toJson());
  }

  Future<void> updateUserProfile(AppUser user) async {
    await firebaseFirestore.collection('Users').doc(user.id).update(
        user.toJson());
  }

  Future<void> changePassword(String email, String oldPassword,
      String newPassword) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception("No user is currently signed in.");
    }


      AuthCredential credential = EmailAuthProvider.credential(
          email: email, password: oldPassword);
      await user.reauthenticateWithCredential(credential);

      // Update password in Firebase
      await user.updatePassword(newPassword);

  }

  Stream<List<AppUser>> searchUsers(String query,) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final searchTerm = query.trim();
    final searchTermLower = searchTerm.toLowerCase();
    final searchTermUpper = searchTerm.toUpperCase();

    if (searchTerm.isEmpty) {
      return Stream.value([]);
    }

    // Create multiple queries to cover different case variations
    return firebaseFirestore
        .collection('Users')
        .orderBy('name')
        .startAt([searchTermUpper])
        .endAt(['$searchTermLower\uf8ff'])
        .limit(20)
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs
          .map((doc) => AppUser.fromJson(doc.data() as Map<String, dynamic>))
          .where((user) =>
      user.name.toLowerCase().contains(searchTermLower) &&
          user.id != currentUserId) // Filter out the current user
          .toList();
      return users;
    });
  }

  Future<AppUser> getUserById(String userId) async {
    final doc = await firebaseFirestore.collection('Users').doc(userId).get();
    if (!doc.exists) {
      throw Exception('User not found');
    }
    return AppUser.fromJson(doc.data() !);
  }

  Future<void> updateFcmToken(String userId, String token) async {
    await firebaseFirestore.collection('Users').doc(userId).update({
      'fcmToken': token,
    });
  }

  Stream<List<AppUser>> getFriends(String userId) {
    return firebaseFirestore
        .collection('Users')
        .doc(userId)
        .collection('friends')
        .snapshots()
        .asyncMap((snapshot) async {
      final friends = <AppUser>[];
      for (var doc in snapshot.docs) {
        print(doc.id);
        final friendId = doc.id;
        final userDoc = await firebaseFirestore.collection('Users').doc(friendId).get();
        if (userDoc.exists) {
          print(userDoc.data());
         try{
           friends.add(AppUser.fromJson(userDoc.data()!));
         }catch(e){
           print(e.toString());
         }
        }
      }
      return friends;
    });
  }

}