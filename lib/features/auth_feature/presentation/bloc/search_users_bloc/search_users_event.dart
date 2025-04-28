part of 'search_users_bloc.dart';

@immutable
sealed class SearchUsersEvent {}
class SearchQueryChanged extends SearchUsersEvent {
  final String query;
  SearchQueryChanged(this.query);
}

class SearchResultsReceived extends SearchUsersEvent {
  final List<AppUser> users;
  SearchResultsReceived(this.users);
}

class SearchError extends SearchUsersEvent {
  final String error;
  SearchError(this.error);
}