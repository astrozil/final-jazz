part of 'search_users_bloc.dart';

@immutable
sealed class SearchUsersState {}

final class SearchUsersInitial extends SearchUsersState {}
class SearchUsersLoading extends SearchUsersState {}

class SearchUsersSuccess extends SearchUsersState {
  final List<AppUser> users;
  SearchUsersSuccess(this.users);
}

class SearchFailure extends SearchUsersState {
  final String error;
  SearchFailure(this.error);
}