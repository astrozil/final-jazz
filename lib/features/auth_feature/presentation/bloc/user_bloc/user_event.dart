part of 'user_bloc.dart';

@immutable
sealed class UserEvent {}

final class FetchFavouriteSongs extends UserEvent{

}

final class FetchFavouriteArtists extends UserEvent{

}