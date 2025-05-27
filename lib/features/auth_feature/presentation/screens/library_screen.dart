// presentation/pages/profile_screen.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/core/widgets/confirm_widget.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/friend_request_bloc/friend_request_bloc.dart';
import 'package:jazz/features/download_feature/presentation/bloc/DownloadedOrNotBloc/downloaded_or_not_bloc.dart';
import 'package:jazz/features/download_feature/presentation/bloc/download/download_bloc.dart';
import 'package:jazz/features/download_feature/presentation/bloc/downloadedSongsBloc/downloaded_songs_bloc.dart';
import 'package:jazz/features/playlist_feature/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackgroundColor,
        body: Center(
          child: Text(
            "User not logged in",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ),
      );
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is IsLoggedIn) {
          if (!state.isLoggedIn) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.authScreen,
                  (Route<dynamic> route) => false,
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryBackgroundColor,
        extendBodyBehindAppBar: true,

        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(firebaseUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }
            if (!snapshot.hasData || !(snapshot.data?.exists ?? false)) {
              return const Center(
                child: Text(
                  "Profile data not available",
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final name = data['name'] ?? 'No Name';
            final profilePictureUrl = data['profilePictureUrl'] ?? '';
            final List<dynamic> favouriteArtistsDynamic =
                data['favouriteArtists'] ?? [];
            final favouriteArtists = favouriteArtistsDynamic.cast<String>();

            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 100),

                  // Profile picture and name section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,


                          ),
                          child: ClipOval(
                            child: profilePictureUrl.isNotEmpty
                                ? Image.network(
                              profilePictureUrl,
                              fit: BoxFit.cover,
                            )
                                : Container(
                              color: Colors.grey[800],
                              child: Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Collection Menu Items
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Collection",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.playlist_play,
                    "Playlists",
                    onTap: () {
                      context.read<PlaylistBloc>().add(FetchPlaylists());
                        Navigator.pushNamed(context, Routes.userPlaylistScreen);
                    },
                  ),

                  _buildMenuItem(
                    context,
                    Icons.music_note,
                    "Tracks",
                    onTap: () {
                      context.read<PlaylistBloc>().add(FetchFavouriteSongsPlaylistEvent());
                      Navigator.pushNamed(context, Routes.favouriteSongsPlaylistScreen);
                    },
                  ),

                  _buildMenuItem(
                    context,
                    Icons.person_outline,
                    "Artists",
                    onTap: () {
                      // Navigate to Artists
                    },
                  ),
                  _buildMenuItem(
                    context,
                    Icons.download,
                    "Downloads",
                    onTap: () {
                      context.read<DownloadedSongsBloc>().add(GetDownloadedSongsEvent());
                      Navigator.pushNamed(context, Routes.downloadedSongsScreen);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Profile Management Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Social",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  _buildMenuItem(
                    context,
                    Icons.search,
                    "Search friends",
                    onTap: () {

                      Navigator.pushNamed(context, Routes.userSearchScreen);
                    },
                  ),

                  _buildMenuItem(
                    context,
                    Icons.people_outline,
                    "Friends",
                    onTap: () {
                     context.read<AuthBloc>().add(GetFriendsEvent());
                      Navigator.pushNamed(context, Routes.friendsScreen);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    Icons.person_add_outlined,
                    "Friend Requests",
                    onTap: () {
                      context.read<FriendRequestBloc>().add(GetReceivedFriendRequestsEvent());
                      Navigator.pushNamed(context, Routes.friendRequestsScreen);
                    },
                  ),

                  _buildMenuItem(
                    context,
                    Icons.person_add_alt_sharp,
                    "Sent Friend Requests",
                    onTap: () {
                      context.read<FriendRequestBloc>().add(GetSentFriendRequestsEvent());
                      Navigator.pushNamed(context, Routes.sentFriendRequestsScreen);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    Icons.share_outlined,
                    "Shared Songs",
                    onTap: () {
                      Navigator.pushNamed(context, Routes.sharedSongsScreen);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Account Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Account",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  _buildMenuItem(
                    context,
                    Icons.edit_outlined,
                    "Edit Profile",
                    onTap: () {
                      Navigator.pushNamed(context, Routes.profileEditScreen);
                    },
                  ),

                  if (!data['signInWithGoogle']) ...[
                    _buildMenuItem(
                      context,
                      Icons.lock_outline,
                      "Change Password",
                      onTap: () {
                        Navigator.pushNamed(context, Routes.passwordChangeScreen);
                      },
                    ),
                    _buildMenuItem(
                      context,
                      Icons.email_outlined,
                      "Update Email",
                      onTap: () {
                        Navigator.pushNamed(context, Routes.emailChangeScreen);
                      },
                    ),
                  ],

                  _buildMenuItem(
                    context,
                    Icons.logout,
                    "Logout",
                    onTap: () {
                      showDialog(context: context, builder: (context){
                        return confirmWidget(context: context, title: "Logout", text: "Are you sure to logout?", confirmButton: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red
                            ),
                            onPressed: (){
                          context.read<AuthBloc>().add(LogoutEvent());
                        }, child: Text("Logout",style: TextStyle(color: Colors.white),)));
                      });

                    },
                    isDestructive: true,
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),

      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context,
      IconData icon,
      String title, {
        required VoidCallback onTap,
        bool isDestructive = false,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.white,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDestructive ? Colors.red : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
