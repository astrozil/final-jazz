import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jazz/features/auth_feature/domain/entities/user.dart';
import 'package:meta/meta.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, FetchedUserData> {
  UserBloc() : super(FetchedUserData(
    isLoading: false,
      user: AppUser(
          id: "",
          name: "",
          email: "",
          signInWithGoogle: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now() ))) {
    on<FetchFavouriteSongs>((event, emit)async {

      emit(state.copyWith(isLoading: true));
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

              emit(state.copyWith(isLoading: false,user: state.user.copyWith(favouriteSongs: user.favouriteSongs)));

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
        emit(state.copyWith(error: e.toString()));
        emit(state.copyWith(error: null));
      }
    });

    on<FetchFavouriteArtists>((event, emit)async{

      emit(state.copyWith(isLoading: true));
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

              emit(state.copyWith(isLoading: false,user: state.user.copyWith(favouriteArtists: user.favouriteArtists)));

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
        emit(state.copyWith(error: e.toString()));
        emit(state.copyWith(error: null));
      }
    });
  }
}
