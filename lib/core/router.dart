
import 'package:flutter/material.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/features/auth_feature/presentation/screens/auth_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/password_change_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/profile_edit_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/profile_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/set_favourite_artists_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/set_name_screen.dart';
import 'package:jazz/features/playlist_feature/presentation/screens/favourite_songs_playlist_screen.dart';
import 'package:jazz/features/search_feature/presentation/screens/search_screen.dart';

class AppRouter{
  Route? onGenerateRoute(RouteSettings routeSettings){
    switch (routeSettings.name){
      case  Routes.searchScreen:
        return MaterialPageRoute(builder: (_)=>  SearchScreen());

      case Routes.authScreen:

        return MaterialPageRoute(builder: (_)=>  AuthScreen());
      case Routes.profileScreen:
        return MaterialPageRoute(builder: (_)=>const ProfileScreen());

      case Routes.setNameScreen:
        return MaterialPageRoute(builder: (_)=>  SetNameScreen());

      case Routes.profileEditScreen:
        return MaterialPageRoute(builder: (_)=>const ProfileEditScreen());
      case Routes.setFavouriteArtistsScreen:
        return MaterialPageRoute(builder: (_)=>  SetFavouriteArtistsScreen());
      case Routes.passwordChangeScreen:
        return MaterialPageRoute(builder: (_)=> PasswordChangeScreen());
      case Routes.favouriteSongsPlaylistScreen:
        return MaterialPageRoute(builder: (_)=> const FavouriteSongsPlaylistScreen());
        default:
        return null;
    }
  }
}