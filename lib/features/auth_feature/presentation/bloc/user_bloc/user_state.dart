part of 'user_bloc.dart';

@immutable
sealed class UserState {}

final class FetchedUserData extends UserState {
  final bool isLoading;
 final AppUser user;
 final String? error;


  FetchedUserData({ required this.isLoading,required this.user, this.error});

  FetchedUserData copyWith({
    bool? isLoading,
    AppUser? user,
    String? error
  }){
    return FetchedUserData(
        isLoading: isLoading ?? this.isLoading ,
        user: user ?? this.user,
       error: error?? this.error
    );
  }
}
