import 'package:flutter/material.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/core/widgets/app_with_player.dart';
import 'package:jazz/core/widgets/global_player_widget.dart';

import 'package:jazz/features/auth_feature/presentation/screens/auth_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/email_change_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/forgot_password_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/friend_requests_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/friends_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/library_screen.dart';
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
import 'package:jazz/features/playlist_feature/presentation/screens/billboard_songs_playlist_screen.dart';
import 'package:jazz/features/playlist_feature/presentation/screens/favourite_songs_playlist_screen.dart';
import 'package:jazz/features/playlist_feature/presentation/screens/home_screen.dart';
import 'package:jazz/features/playlist_feature/presentation/screens/recommended_songs_playlist_screen.dart';
import 'package:jazz/features/playlist_feature/presentation/screens/specified_user_playlist_screen.dart';
import 'package:jazz/features/playlist_feature/presentation/screens/suggested_songs_of_favourite_artists_playlist_screen.dart';
import 'package:jazz/features/playlist_feature/presentation/screens/trending_songs_playlist_screen.dart';
import 'package:jazz/features/playlist_feature/presentation/screens/user_playlist_screen.dart';
import 'package:jazz/features/playlist_feature/presentation/screens/user_playlist_title_update_screen.dart';
import 'package:jazz/features/search_feature/presentation/screens/album_Screen.dart';
import 'package:jazz/features/search_feature/presentation/screens/albums_result_screen.dart';
import 'package:jazz/features/search_feature/presentation/screens/artist_detail_screen.dart';
import 'package:jazz/features/search_feature/presentation/screens/artists_result_screen.dart';
import 'package:jazz/features/search_feature/presentation/screens/new_playlist_screen.dart';
import 'package:jazz/features/search_feature/presentation/screens/search_screen.dart';
import 'package:jazz/features/search_feature/presentation/screens/songs_result_screen.dart';
import 'package:jazz/features/song_share_feature/presentation/screens/shared_songs_screen.dart';

// Custom route without animation
class NoAnimationRoute<T> extends MaterialPageRoute<T> {
  NoAnimationRoute({required WidgetBuilder builder, RouteSettings? settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}

class AppRouter {
  int _currentNavIndex = 0;

  // Build bottom navigation bar
  Widget _buildBottomNavBar(BuildContext context, String currentRoute) {
    // Determine current index based on route
    switch (currentRoute) {
      case Routes.homeScreen:
        _currentNavIndex = 0;
        break;
      case Routes.searchScreen:
        _currentNavIndex = 1;
        break;
      case Routes.libraryScreen:
        _currentNavIndex = 2;
        break;

      default:
        break;
    }

    return Theme(
        data: Theme.of(context).copyWith(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: AppColors.primaryBackgroundColor,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentNavIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),

        ],
        onTap: (index) => _handleNavigation(context, index),
      ),
    );
  }

  // Handle navigation bar taps
  void _handleNavigation(BuildContext context, int index) {
    String route;
    switch (index) {
      case 0:
        route = Routes.homeScreen;
        break;
      case 1:
        route = Routes.searchScreen;
        break;
      case 2:
        route = Routes.libraryScreen;
        break;

      default:
        return;
    }

    // Navigate only if not already on the same route
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushNamed(context, route);
    }
  }

  // Check if route should have bottom navigation bar
  bool _shouldShowBottomNav(String? routeName) {
    const routesWithBottomNav = [
      Routes.searchScreen,
      Routes.sharedSongsScreen,
      Routes.userPlaylistScreen,
      Routes.downloadedSongsScreen,
      Routes.favouriteSongsPlaylistScreen,
      Routes.recommendedSongsPlaylistScreen,
      Routes.homeScreen,
      Routes.libraryScreen
    ];
    return routesWithBottomNav.contains(routeName);
  }

  Route? onGenerateRoute(RouteSettings routeSettings) {
    final routeName = routeSettings.name;
    final shouldShowBottomNav = _shouldShowBottomNav(routeName);

    switch (routeName) {
    // Main app screens with bottom navigation
      case Routes.searchScreen:
        return NoAnimationRoute(
          builder: (context) => AppWithPlayer(
            child: SearchScreen(),
            bottomNavigationBar: shouldShowBottomNav
                ? _buildBottomNavBar(context, routeName!)
                : null,
          ),
          settings: routeSettings,
        );
      case Routes.albumScreen:
        return NoAnimationRoute(
          builder: (context) => AppWithPlayer(
            child: AlbumScreen(),
            bottomNavigationBar: shouldShowBottomNav
                ? _buildBottomNavBar(context, routeName!)
                : null,
          ),
          settings: routeSettings,
        );
      case Routes.homeScreen:
        return NoAnimationRoute(
          builder: (context) => AppWithPlayer(
            child: HomeScreen(),
            bottomNavigationBar: shouldShowBottomNav
                ? _buildBottomNavBar(context, routeName!)
                : null,
          ),
          settings: routeSettings,
        );
      case Routes.trendingSongsPlaylistScreen:
        return MaterialPageRoute(
          builder: (context) => AppWithPlayer(
            child: TrendingSongsPlaylistScreen(),
            bottomNavigationBar: shouldShowBottomNav
                ? _buildBottomNavBar(context, routeName!)
                : null,
          ),
          settings: routeSettings,
        );
      case Routes.suggestedSongsPlaylistScreen:
        return NoAnimationRoute(
          builder: (context) => AppWithPlayer(
            child: SuggestedSongsOfFavouriteArtistsPlaylistScreen(),
            bottomNavigationBar: shouldShowBottomNav
                ? _buildBottomNavBar(context, routeName!)
                : null,
          ),
          settings: routeSettings,
        );
      case Routes.billboardSongsPlaylistScreen:
        return NoAnimationRoute(
          builder: (context) => AppWithPlayer(
            child: BillboardSongsPlaylistScreen(),
            bottomNavigationBar: shouldShowBottomNav
                ? _buildBottomNavBar(context, routeName!)
                : null,
          ),
          settings: routeSettings,
        );
      case Routes.songsResultScreen:
        return NoAnimationRoute(
          builder: (context) => AppWithPlayer(
            child: SongsResultScreen(),
            bottomNavigationBar: shouldShowBottomNav
                ? _buildBottomNavBar(context, routeName!)
                : null,
          ),
          settings: routeSettings,
        );
      case Routes.albumsResultScreen:
        return NoAnimationRoute(
          builder: (context) => AppWithPlayer(
            child: AlbumsResultScreen(),
            bottomNavigationBar: shouldShowBottomNav
                ? _buildBottomNavBar(context, routeName!)
                : null,
          ),
          settings: routeSettings,
        );
      case Routes.artistsResultScreen:
        return NoAnimationRoute(
          builder: (context) => AppWithPlayer(
            child: ArtistsResultScreen(),
            bottomNavigationBar: shouldShowBottomNav
                ? _buildBottomNavBar(context, routeName!)
                : null,
          ),
          settings: routeSettings,
        );
      case Routes.libraryScreen:
        return NoAnimationRoute(
          builder: (context) => AppWithPlayer(
            child: LibraryScreen(),
            bottomNavigationBar: shouldShowBottomNav
                ? _buildBottomNavBar(context, routeName!)
                : null,
          ),
          settings: routeSettings,
        );
      case Routes.sharedSongsScreen:
        return NoAnimationRoute(
          builder: (context) => AppWithPlayer(
            child: const SharedSongsScreen(),
            bottomNavigationBar: shouldShowBottomNav
                ? _buildBottomNavBar(context, routeName!)
                : null,
          ),
          settings: routeSettings,
        );

      case Routes.userPlaylistScreen:
        return NoAnimationRoute(
          builder: (context) => AppWithPlayer(
            child: UserPlaylistScreen(),
            bottomNavigationBar: shouldShowBottomNav
                ? _buildBottomNavBar(context, routeName!)
                : null,
          ),
          settings: routeSettings,
        );

      case Routes.downloadedSongsScreen:
        return NoAnimationRoute(
          builder: (context) => AppWithPlayer(
            child: const DownloadedSongsScreen(),
            bottomNavigationBar: shouldShowBottomNav
                ? _buildBottomNavBar(context, routeName!)
                : null,
          ),
          settings: routeSettings,
        );

      case Routes.favouriteSongsPlaylistScreen:
        return NoAnimationRoute(
          builder: (context) => AppWithPlayer(
            child: const FavouriteSongsPlaylistScreen(),
            bottomNavigationBar: shouldShowBottomNav
                ? _buildBottomNavBar(context, routeName!)
                : null,
          ),
          settings: routeSettings,
        );

      case Routes.recommendedSongsPlaylistScreen:
        return NoAnimationRoute(
          builder: (context) => AppWithPlayer(
            child: const RecommendedSongsPlaylistScreen(),
            bottomNavigationBar: shouldShowBottomNav
                ? _buildBottomNavBar(context, routeName!)
                : null,
          ),
          settings: routeSettings,
        );

    // Screens with player but no bottom navigation
      case Routes.specifiedUserPlaylist:
        return NoAnimationRoute(
          builder: (context) => AppWithPlayer(
            child: SpecifiedUserPlaylistScreen(),
          ),
          settings: routeSettings,
        );

      case Routes.artistDetailScreen:
        final Map args = routeSettings.arguments as Map;
        return NoAnimationRoute(
          builder: (context) => AppWithPlayer(
            child: ArtistDetailScreen(artistId: args["artistId"]),
          ),
          settings: routeSettings,
        );

    // Profile and settings screens (no player, no bottom nav)
      case Routes.profileScreen:
        return NoAnimationRoute(
          builder: (_) => const ProfileScreen(),
          settings: routeSettings,
        );

      case Routes.profileEditScreen:
        return NoAnimationRoute(
          builder: (_) => const ProfileEditScreen(),
          settings: routeSettings,
        );

      case Routes.passwordChangeScreen:
        return NoAnimationRoute(
          builder: (_) => PasswordChangeScreen(),
          settings: routeSettings,
        );

      case Routes.emailChangeScreen:
        return NoAnimationRoute(
          builder: (_) => const ChangeEmailScreen(),
          settings: routeSettings,
        );

      case Routes.emailChangeSuccessScreen:
        return NoAnimationRoute(
          builder: (_) => const EmailChangeSuccessScreen(),
          settings: routeSettings,
        );

    // Social features (no player, no bottom nav)
      case Routes.userSearchScreen:
        return NoAnimationRoute(
          builder: (_) => UserSearchScreen(),
          settings: routeSettings,
        );

      case Routes.friendRequestsScreen:
        return NoAnimationRoute(
          builder: (_) => const FriendRequestsScreen(),
          settings: routeSettings,
        );

      case Routes.friendsScreen:
        return NoAnimationRoute(
          builder: (_) => FriendsScreen(),
          settings: routeSettings,
        );

      case Routes.sentFriendRequestsScreen:
        return NoAnimationRoute(
          builder: (_) => const SentFriendRequestsScreen(),
          settings: routeSettings,
        );

      case Routes.notificationScreen:
        return NoAnimationRoute(
          builder: (_) => const NotificationScreen(),
          settings: routeSettings,
        );

    // Playlist management (no bottom nav)
      case Routes.newPlaylistScreen:
        return NoAnimationRoute(
          builder: (_) => const NewPlaylistScreen(),
          settings: routeSettings,
        );

      case Routes.userPlaylistTitleUpdateScreen:
        final Map args = routeSettings.arguments as Map;
        return NoAnimationRoute(
          builder: (_) => UserPlaylistTitleUpdateScreen(
            playlistTitle: args["playlistTitle"],
            playlistId: args["playlistId"],
          ),
          settings: routeSettings,
        );

    // Authentication screens (no player, no bottom nav)
      case Routes.authScreen:
        return NoAnimationRoute(
          builder: (_) => AuthScreen(),
          settings: routeSettings,
        );

      case Routes.loginScreen:
        return NoAnimationRoute(
          builder: (_) => const LoginScreen(),
          settings: routeSettings,
        );

      case Routes.signUpScreen:
        return NoAnimationRoute(
          builder: (_) => const SignUpScreen(),
          settings: routeSettings,
        );

      case Routes.forgotPasswordScreen:
        return NoAnimationRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: routeSettings,
        );

      case Routes.resetPasswordSuccessScreen:
        return NoAnimationRoute(
          builder: (_) => const ResetPasswordSuccessScreen(),
          settings: routeSettings,
        );

      case Routes.setNameScreen:
        return NoAnimationRoute(
          builder: (_) => SetNameScreen(),
          settings: routeSettings,
        );

      case Routes.setFavouriteArtistsScreen:
        return NoAnimationRoute(
          builder: (_) => SetFavouriteArtistsScreen(),
          settings: routeSettings,
        );

      default:
        return null;
    }
  }
}
