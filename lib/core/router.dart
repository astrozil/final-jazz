
import 'package:flutter/material.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/core/widgets/app_with_player.dart';

import 'package:jazz/features/auth_feature/presentation/screens/auth_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/email_change_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/forgot_password_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/friend_requests_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/friends_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/login_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/notification_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/password_change_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/profile_edit_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/profile_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/reset_password_success_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/sent_friend_requests_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/set_favourite_artists_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/set_name_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/sign_up_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/user_search_screen.dart';
import 'package:jazz/features/download_feature/presentation/screens/downloaded_songs_screen.dart';
import 'package:jazz/features/playlist_feature/presentation/screens/favourite_songs_playlist_screen.dart';
import 'package:jazz/features/playlist_feature/presentation/screens/recommended_songs_playlist_screen.dart';
import 'package:jazz/features/playlist_feature/presentation/screens/specified_user_playlist_screen.dart';
import 'package:jazz/features/playlist_feature/presentation/screens/user_playlist_screen.dart';
import 'package:jazz/features/search_feature/presentation/screens/search_screen.dart';
import 'package:jazz/features/song_share_feature/presentation/screens/shared_songs_screen.dart';

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

      case Routes.userPlaylistScreen:
        return MaterialPageRoute(builder: (_)=>  UserPlaylistScreen());
      case Routes.specifiedUserPlaylist:
        final Map args = routeSettings.arguments as Map;
        return MaterialPageRoute(builder: (_)=> SpecifiedUserPlaylistScreen(specifiedUserPlaylist: args['specifiedUserPlaylist'] ,));
      case Routes.recommendedSongsPlaylistScreen:
        return MaterialPageRoute(builder: (_)=> const RecommendedSongsPlaylistScreen());
      case Routes.userSearchScreen:
        return MaterialPageRoute(builder: (_)=>  UserSearchScreen());
      case Routes.friendRequestsScreen:
        return MaterialPageRoute(builder: (_)=> const FriendRequestsScreen());
      case Routes.friendsScreen:
        return MaterialPageRoute(builder: (_)=>  FriendsScreen());
      case Routes.sentFriendRequestsScreen:
        return MaterialPageRoute(builder: (_)=> const SentFriendRequestsScreen());
      case Routes.notificationScreen:
        return MaterialPageRoute(builder: (_)=> const NotificationScreen());
      case Routes.sharedSongsScreen:
        return MaterialPageRoute(builder: (_)=>const  AppWithPlayer(child:  SharedSongsScreen()));
      case Routes.forgotPasswordScreen:
        return MaterialPageRoute(builder: (_)=> const ForgotPasswordScreen());
      case Routes.downloadedSongsScreen:
        return MaterialPageRoute(builder: (_)=> const DownloadedSongsScreen());
      case Routes.signUpScreen:
        return MaterialPageRoute(builder: (_)=> const SignUpScreen());
      case Routes.loginScreen:
        return MaterialPageRoute(builder: (_)=> const LoginScreen());
      case Routes.resetPasswordSuccessScreen:
        return MaterialPageRoute(builder: (_)=> const ResetPasswordSuccessScreen());
      case Routes.emailChangeScreen:
        return MaterialPageRoute(builder: (_)=> const ChangeEmailScreen());
      case Routes.emailChangeSuccessScreen:
        return MaterialPageRoute(builder:(_)=> const EmailChangeSuccessScreen());
        default:
        return null;
    }
  }
}