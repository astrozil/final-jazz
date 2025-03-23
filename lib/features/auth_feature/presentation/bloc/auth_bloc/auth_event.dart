part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class SignUpEvent extends AuthEvent {
  final String email;
  final String password;

   SignUpEvent({required this.email, required this.password});


}

class SignInEvent extends AuthEvent {
  final String email;
  final String password;

   SignInEvent({required this.email, required this.password});


}

class GoogleSignInEvent extends AuthEvent {}

class CheckAuthUserStatus extends AuthEvent{

}

class LogoutEvent extends AuthEvent{

}
class UpdateUserProfileEvent extends AuthEvent {
  final String? name;
  final String? email;
  final String? profilePictureUrl;
  final List<String>? favouriteArtists;
  final List<String>? favouriteSongs;
  final List<String>? songHistory;
  final List<String>? playlists;
  final List<String>? searchHistory;
  final DateTime? updatedAt;

  UpdateUserProfileEvent({
    this.name,
    this.email,
    this.profilePictureUrl,
    this.favouriteArtists,
    this.favouriteSongs,
    this.songHistory,
    this.playlists,
    this.searchHistory,
    this.updatedAt,
  });
}

class ChangePasswordEvent extends AuthEvent{
  final String email;
  final String oldPassword;
  final String newPassword;

  ChangePasswordEvent({required this.email, required this.oldPassword, required this.newPassword});
}
class FetchUserDataEvent extends AuthEvent {}