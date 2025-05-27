part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}



final class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final bool isNewUser;

  AuthSuccess({required this.isNewUser});

}
class AuthFailure extends AuthState {
  final String message;
   AuthFailure({required this.message});


}

class ResetPasswordSuccess extends AuthState{

}
class ResetPasswordFail extends AuthState{
final String message;

  ResetPasswordFail({required this.message});
}
class IsLoggedIn extends AuthState{
  final bool isLoggedIn;

  IsLoggedIn({required this.isLoggedIn});

}

final class UserDataUpdated extends AuthState{

}
final class PasswordChanged extends AuthState{

}

class UserDataFetched extends AuthState {
  final AppUser user;
  UserDataFetched({required this.user});
}
class FavouriteSongsFetched extends AuthState{
  final List<String> favouriteSongs;

  FavouriteSongsFetched({required this.favouriteSongs});
}
class FriendsLoaded extends AuthState{
  final List<AppUser> friends;

  FriendsLoaded({required this.friends});
}
class EmailUpdated extends AuthState{

}