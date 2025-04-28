import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jazz/features/auth_feature/domain/entities/user.dart';
import 'package:jazz/features/auth_feature/domain/use_case/auth_use_cases/change_password_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/auth_use_cases/create_user_profile_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/auth_use_cases/get_auth_status_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/auth_use_cases/get_friends_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/auth_use_cases/google_sign_in_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/auth_use_cases/logout_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/auth_use_cases/reset_password_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/auth_use_cases/sign_in_usecase.dart';
import 'package:jazz/features/auth_feature/domain/use_case/auth_use_cases/sign_up_usecase.dart';
import 'package:jazz/features/auth_feature/domain/use_case/auth_use_cases/update_email_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/auth_use_cases/update_user_profile_use_case.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpUseCase signUpUseCase;
  final SignInUseCase signInUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final GetAuthStatusUseCase getAuthStatusUseCase;
  final LogoutUseCase logoutUseCase;
  final CreateUserProfileUseCase createUserProfileUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final GetFriendsUseCase getFriendsUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
 final UpdateEmailUseCase updateEmailUseCase;

    StreamSubscription? friendsSubscription;
  AuthBloc( {
    required this.signInWithGoogleUseCase,
    required this.signUpUseCase,
    required this.signInUseCase,
  required this.getAuthStatusUseCase,
    required this.logoutUseCase,
    required this.createUserProfileUseCase,
    required this.updateUserProfileUseCase,
    required this.changePasswordUseCase,
    required this.getFriendsUseCase,
    required this.resetPasswordUseCase,
    required this.updateEmailUseCase
  }) : super(AuthInitial()) {
    on<SignUpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await signUpUseCase(event.email, event.password);
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          final newUser = AppUser(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? "New User",
            email: event.email,
            profilePictureUrl: firebaseUser.photoURL,
            favouriteArtists: [],
            favouriteSongs: [],
            songHistory: [],
            playlists: [],
            signInWithGoogle: false,
            searchHistory: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await createUserProfileUseCase(newUser);
          emit(AuthSuccess(isNewUser: true));
        }
      }on FirebaseAuthException catch (e) {
        String errorMessage;

        switch (e.code) {
        // Email/Password Authentication Errors
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          case 'user-disabled':
            errorMessage = 'This user account has been disabled.';
            break;
          case 'user-not-found':
            errorMessage = 'No user found with this email address.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password. Please try again.';
            break;
          case 'email-already-in-use':
            errorMessage = 'This email is already registered. Please use another email or sign in.';
            break;
          case 'weak-password':
            errorMessage = 'The password is too weak. Please use a stronger password.';
            break;
          case 'operation-not-allowed':
            errorMessage = 'This sign-in method is not allowed. Please contact support.';
            break;

        // Account Linking Errors
          case 'account-exists-with-different-credential':
            errorMessage = 'An account already exists with the same email but different sign-in credentials.';
            break;
          case 'credential-already-in-use':
            errorMessage = 'This credential is already associated with a different user account.';
            break;

        // Rate Limiting Errors
          case 'too-many-requests':
            errorMessage = 'Too many requests. Please try again later.';
            break;

        // Network Errors
          case 'network-request-failed':
            errorMessage = 'Network error. Please check your internet connection and try again.';
            break;

        // Session Errors
          case 'expired-action-code':
            errorMessage = 'The action code has expired. Please request a new one.';
            break;
          case 'invalid-action-code':
            errorMessage = 'The action code is invalid. Please request a new one.';
            break;

        // Other Errors
          case 'requires-recent-login':
            errorMessage = 'This operation requires recent authentication. Please sign in again.';
            break;
          case 'provider-already-linked':
            errorMessage = 'This provider is already linked to your account.';
            break;
          case 'no-such-provider':
            errorMessage = 'This provider is not linked to your account.';
            break;
          case 'invalid-credential':
            errorMessage = 'The credential is malformed or has expired.';
            break;
          case 'invalid-verification-code':
            errorMessage = 'The verification code is invalid. Please try again.';
            break;
          case 'invalid-verification-id':
            errorMessage = 'The verification ID is invalid. Please try again.';
            break;
          case 'captcha-check-failed':
            errorMessage = 'The reCAPTCHA response is invalid. Please try again.';
            break;
          case 'app-not-authorized':
            errorMessage = 'This app is not authorized to use Firebase Authentication.';
            break;
          case 'missing-verification-code':
            errorMessage = 'The verification code is missing. Please try again.';
            break;
          case 'missing-verification-id':
            errorMessage = 'The verification ID is missing. Please try again.';
            break;
          case 'quota-exceeded':
            errorMessage = 'Quota exceeded. Please try again later.';
            break;
          case 'second-factor-already-in-use':
            errorMessage = 'This second factor is already enrolled for this account.';
            break;
          case 'maximum-second-factor-count-exceeded':
            errorMessage = 'Maximum number of second factors already enrolled for this account.';
            break;
          case 'unsupported-first-factor':
            errorMessage = 'This first factor is not supported.';
            break;
          case 'unsupported-tenant-operation':
            errorMessage = 'This operation is not supported in a multi-tenant context.';
            break;
          case 'unverified-email':
            errorMessage = 'Your email is not verified. Please verify your email first.';
            break;
          case 'user-cancelled':
            errorMessage = 'The operation was cancelled by the user.';
            break;
          case 'user-token-expired':
            errorMessage = 'Your session has expired. Please sign in again.';
            break;
          case 'web-storage-unsupported':
            errorMessage = 'Web storage is not supported or is disabled.';
            break;
          case 'tenant-id-mismatch':
            errorMessage = 'The provided tenant ID does not match the Auth instance\'s tenant ID.';
            break;
          default:
            errorMessage = e.message ?? 'An unknown authentication error occurred.';
        }

        emit(AuthFailure(message: errorMessage));
      } on FirebaseException catch (e) {
        // Handle other Firebase exceptions (non-auth)
        String errorMessage = 'Firebase Error: ${e.message ?? 'Unknown Firebase error occurred.'}';
        emit(AuthFailure(message: errorMessage));
      } catch (e) {
        print(e.hashCode);
        emit(AuthFailure(message: 'An unexpected error occurred: ${e.toString()}'));
      }
    });

    on<SignInEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await signInUseCase(event.email, event.password);
        emit(AuthSuccess(isNewUser: false));
      } on FirebaseAuthException catch (e) {
        String errorMessage;

        switch (e.code) {
        // Email/Password Authentication Errors
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          case 'user-disabled':
            errorMessage = 'This user account has been disabled.';
            break;
          case 'user-not-found':
            errorMessage = 'No user found with this email address.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password. Please try again.';
            break;
          case 'email-already-in-use':
            errorMessage = 'This email is already registered. Please use another email or sign in.';
            break;
          case 'weak-password':
            errorMessage = 'The password is too weak. Please use a stronger password.';
            break;
          case 'operation-not-allowed':
            errorMessage = 'This sign-in method is not allowed. Please contact support.';
            break;

        // Account Linking Errors
          case 'account-exists-with-different-credential':
            errorMessage = 'An account already exists with the same email but different sign-in credentials.';
            break;
          case 'credential-already-in-use':
            errorMessage = 'This credential is already associated with a different user account.';
            break;

        // Rate Limiting Errors
          case 'too-many-requests':
            errorMessage = 'Too many requests. Please try again later.';
            break;

        // Network Errors
          case 'network-request-failed':
            errorMessage = 'Network error. Please check your internet connection and try again.';
            break;

        // Session Errors
          case 'expired-action-code':
            errorMessage = 'The action code has expired. Please request a new one.';
            break;
          case 'invalid-action-code':
            errorMessage = 'The action code is invalid. Please request a new one.';
            break;

        // Other Errors
          case 'requires-recent-login':
            errorMessage = 'This operation requires recent authentication. Please sign in again.';
            break;
          case 'provider-already-linked':
            errorMessage = 'This provider is already linked to your account.';
            break;
          case 'no-such-provider':
            errorMessage = 'This provider is not linked to your account.';
            break;
          case 'invalid-credential':
            errorMessage = 'Your email or password is incorrect.';
            break;
          case 'invalid-verification-code':
            errorMessage = 'The verification code is invalid. Please try again.';
            break;
          case 'invalid-verification-id':
            errorMessage = 'The verification ID is invalid. Please try again.';
            break;
          case 'captcha-check-failed':
            errorMessage = 'The reCAPTCHA response is invalid. Please try again.';
            break;
          case 'app-not-authorized':
            errorMessage = 'This app is not authorized to use Firebase Authentication.';
            break;
          case 'missing-verification-code':
            errorMessage = 'The verification code is missing. Please try again.';
            break;
          case 'missing-verification-id':
            errorMessage = 'The verification ID is missing. Please try again.';
            break;
          case 'quota-exceeded':
            errorMessage = 'Quota exceeded. Please try again later.';
            break;
          case 'second-factor-already-in-use':
            errorMessage = 'This second factor is already enrolled for this account.';
            break;
          case 'maximum-second-factor-count-exceeded':
            errorMessage = 'Maximum number of second factors already enrolled for this account.';
            break;
          case 'unsupported-first-factor':
            errorMessage = 'This first factor is not supported.';
            break;
          case 'unsupported-tenant-operation':
            errorMessage = 'This operation is not supported in a multi-tenant context.';
            break;
          case 'unverified-email':
            errorMessage = 'Your email is not verified. Please verify your email first.';
            break;
          case 'user-cancelled':
            errorMessage = 'The operation was cancelled by the user.';
            break;
          case 'user-token-expired':
            errorMessage = 'Your session has expired. Please sign in again.';
            break;
          case 'web-storage-unsupported':
            errorMessage = 'Web storage is not supported or is disabled.';
            break;
          case 'tenant-id-mismatch':
            errorMessage = 'The provided tenant ID does not match the Auth instance\'s tenant ID.';
            break;
          default:
            errorMessage = e.message ?? 'An unknown authentication error occurred.';
        }

        emit(AuthFailure(message: errorMessage));
      } on FirebaseException catch (e) {
        // Handle other Firebase exceptions (non-auth)
        String errorMessage = 'Firebase Error: ${e.message ?? 'Unknown Firebase error occurred.'}';
        emit(AuthFailure(message: errorMessage));
      } catch (e) {
        print(e.hashCode);
        emit(AuthFailure(message: 'An unexpected error occurred: ${e.toString()}'));
      }
    });
    on<GoogleSignInEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await signInWithGoogleUseCase();
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {

          DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .doc(firebaseUser.uid)
              .get();


          if (!docSnapshot.exists) {

            final newUser = AppUser(
              id: firebaseUser.uid,
              name: firebaseUser.displayName ?? '',
              email: firebaseUser.email ?? '',
              profilePictureUrl: firebaseUser.photoURL,
              signInWithGoogle: true,
              favouriteArtists: [],
              favouriteSongs: [],
              songHistory: [],
              playlists: [],

              searchHistory: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            await createUserProfileUseCase(newUser);
            emit(AuthSuccess(isNewUser: true));
            return;
          }
        }
        emit(AuthSuccess(isNewUser: false));
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });

    on<CheckAuthUserStatus>((event, emit) async {
      final isLoggedIn = await getAuthStatusUseCase();

        emit(IsLoggedIn(isLoggedIn: isLoggedIn));

    });
    on<LogoutEvent>((event, emit) async {
      await logoutUseCase();
      emit(IsLoggedIn(isLoggedIn: false));
    });

    on<UpdateUserProfileEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {

          final docSnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .doc(firebaseUser.uid)
              .get();

          if (docSnapshot.exists) {
            final currentUser = AppUser.fromJson(docSnapshot.data()!);


            final updatedUser = currentUser.copyWith(
              name: event.name,
              email: event.email,
              profilePictureUrl: event.profilePictureUrl,
              favouriteArtists: event.favouriteArtists,
              favouriteSongs: event.favouriteSongs,
              songHistory: event.songHistory,
              playlists: event.playlists,
              searchHistory: event.searchHistory,
              updatedAt: event.updatedAt ?? DateTime.now(),
            );


            await updateUserProfileUseCase(updatedUser);
            emit(UserDataUpdated());
          } else {
            throw Exception("User profile not found");
          }
        }
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });
    on<ChangePasswordEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await changePasswordUseCase(event.email, event.oldPassword, event.newPassword);
        emit(PasswordChanged());
      } on FirebaseAuthException catch (e) {
        String message;
        switch (e.code) {
          case 'wrong-password':
            message = "The current password is incorrect.";
            break;
          case 'user-not-found':
            message = "No user found for this email.";
            break;
          case 'invalid-email':
            message = "The email address is invalid.";
            break;
          case 'weak-password':
            message = "The new password is too weak. Please choose a stronger password.";
            break;
          case 'requires-recent-login':
            message = "This operation requires recent authentication. Please log in again and try.";
            break;
          case 'too-many-requests':
            message = "Too many attempts. Please try again later.";
            break;
          case 'invalid-credential':
          // This is the error you are seeing from RecaptchaAction
            message = "The supplied authentication credential is incorrect, malformed, or has expired. Please check your current password and try again.";
            break;
          case 'user-disabled':
            message = "This user account has been disabled.";
            break;
          default:
            message = e.message ?? "An unknown error occurred. Please try again.";
        }
        emit(AuthFailure(message: message));
      } catch (e) {
        emit(AuthFailure(message: "An unexpected error occurred. Please try again."));
      }
    });

    on<FetchUserDataEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {

          final docSnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .doc(firebaseUser.uid)
              .get();


          if (docSnapshot.exists) {

            try {
              final user = AppUser.fromJson(docSnapshot.data()!);

              emit(UserDataFetched(user: user));
            }catch(e){
              print(e.toString());
            }
          } else {

            throw Exception("User data not found.");
          }
        } else {
          throw Exception("No logged in user.");
        }
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });
    on<GetFriendsEvent>((event,emit)async{
      final userId = FirebaseAuth.instance.currentUser!.uid;
      emit(AuthLoading());

         friendsSubscription?.cancel();
         friendsSubscription = getFriendsUseCase.call(userId).listen(
             (friends)=> add(AuthUpdateStateEvent(state: FriendsLoaded(friends: friends))) ,
           onError:(error)=> add(AuthUpdateStateEvent(state:  AuthFailure(message: error.toString())))
         );

    });

    on<AuthUpdateStateEvent>((event,emit){
      emit(event.state);
    });
    on<ResetPasswordEvent>((event,emit)async{
      emit(AuthLoading());
      try {
        final users =await FirebaseFirestore.instance.collection("Users").get();
        for(var user in users.docs){
          if(event.email == user.data()['email']){
            await resetPasswordUseCase.execute(email: event.email);
            emit(ResetPasswordSuccess());
            return;
          }
        }
        emit(ResetPasswordFail(message: "This email is not registered"));
           return;
      }catch(e){
        emit(ResetPasswordFail(message: e.toString()));
      }
    });

    on<UpdateEmailEvent>((event, emit) async {
      emit(AuthLoading());
      try {

        await updateEmailUseCase(password: event.password, newEmail: event.newEmail);
        emit(EmailUpdated());
      }on FirebaseException catch (e) {
        if (e.code == 'auth/operation-not-allowed') {
          emit(AuthFailure(message: 'Email update requires verification. Check your inbox.'));
        } else if (e.code == 'auth/requires-recent-login') {
          emit(AuthFailure(message: 'Please login again before changing your email.'));
        } else if (e.code == 'auth/email-already-in-use') {
          emit(AuthFailure(message: 'This email is already in use by another account.'));
        } else if (e.code == 'auth/invalid-email') {
          emit(AuthFailure(message: 'The email address is invalid.'));
        } else {
          emit(AuthFailure(message: 'Failed to update email: ${e.toString()}'));
        }
      }catch(e){
        emit(AuthFailure(message: "Something went wrong. Please try again later."));
      }
    });

  }
}
