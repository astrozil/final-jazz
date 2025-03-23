import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jazz/features/auth_feature/domain/entities/user.dart';
import 'package:jazz/features/auth_feature/domain/use_case/change_password_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/create_user_profile_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/get_auth_status_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/google_sign_in_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/logout_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/sign_in_usecase.dart';
import 'package:jazz/features/auth_feature/domain/use_case/sign_up_usecase.dart';
import 'package:jazz/features/auth_feature/domain/use_case/update_user_profile_use_case.dart';
import 'package:meta/meta.dart';

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
  AuthBloc( {
    required this.signInWithGoogleUseCase,
    required this.signUpUseCase,
    required this.signInUseCase,
  required this.getAuthStatusUseCase,
    required this.logoutUseCase,
    required this.createUserProfileUseCase,
    required this.updateUserProfileUseCase,
    required this.changePasswordUseCase
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
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });

    on<SignInEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await signInUseCase(event.email, event.password);
        emit(AuthSuccess(isNewUser: false));
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
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
    on<ChangePasswordEvent>((event, emit)async{
      emit(AuthLoading());
      try{
      await  changePasswordUseCase(event.email,event.oldPassword,event.newPassword);
        emit(PasswordChanged());
      }catch(e){
        emit(AuthFailure(message: e.toString()));
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

  }
}
