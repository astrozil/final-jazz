// presentation/pages/profile_screen.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/friend_request_bloc/friend_request_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    // If there's no authenticated user, show a message.
    if (firebaseUser == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A1128),
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
        backgroundColor: const Color(0xFF0A1128),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            "Profile",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                // Search functionality
              },
            ),
          ],
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(firebaseUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF8A3D),
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

            // Parse the fetched document.
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final name = data['name'] ?? 'No Name';
            final email = data['email'] ?? 'No Email';
            final profilePictureUrl = data['profilePictureUrl'] ?? '';
            final List<dynamic> favouriteArtistsDynamic =
                data['favouriteArtists'] ?? [];
            final favouriteArtists = favouriteArtistsDynamic.cast<String>();

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 100),

                  // Profile picture
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0A1128),
                        width: 2,
                      ),
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
                          size: 50,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Profile info card
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101C45),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        // User name
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn("13", "Songs"),
                            _buildStatColumn(
                                "${favouriteArtists.length}M", "Auditions"),
                            _buildStatColumn("2020", "Year"),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.play_arrow, size: 20),
                                label: const Text(
                                  "Play",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF7F2D),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.shuffle, size: 20),
                                label: const Text(
                                  "Shuffle",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white38),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tracks list
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        ...favouriteArtists.asMap().entries.map((entry) {
                          final index = entry.key + 1;
                          final artist = entry.value;
                          return _buildTrackItem(
                            context,
                            index.toString().padLeft(2, '0'),
                            "Locked up pt. ${index}",
                            artist,
                            "3:23",
                            index == 2, // Make the second one favorited
                          );
                        }).toList(),

                        const SizedBox(height: 20),

                        // Additional buttons
                        Visibility(
                          visible: !data['signInWithGoogle'],
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, Routes.passwordChangeScreen);
                            },
                            icon: const Icon(Icons.lock_outline, color: Colors.white70),
                            label: const Text(
                              "Change Password",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: !data['signInWithGoogle'],
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, Routes.emailChangeScreen);
                            },
                            icon: const Icon(Icons.lock_outline, color: Colors.white70),
                            label: const Text(
                              "Update Email",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),

                        TextButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.profileEditScreen);
                          },
                          icon: const Icon(Icons.edit, color: Colors.white70),
                          label: const Text(
                            "Edit Profile",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        ElevatedButton(onPressed: (){
                          Navigator.pushNamed(context, Routes.sharedSongsScreen);
                        }, child: Text("Shared Songs")),
                        ElevatedButton(onPressed: (){

                          Navigator.pushNamed(context, Routes.notificationScreen);
                        }, child: Text("Notifications") ),
                         ElevatedButton(onPressed: (){

                           Navigator.pushNamed(context, Routes.friendRequestsScreen);
                         }, child: Text("Friend Requests")),
                        ElevatedButton(onPressed: (){

                          Navigator.pushNamed(context, Routes.sentFriendRequestsScreen);
                        }, child: Text("Sent Friend Requests")),
                        ElevatedButton(onPressed: (){

                          Navigator.pushNamed(context, Routes.friendsScreen);
                        }, child: Text("Friends") ),
                        TextButton.icon(
                          onPressed: () {
                            context.read<AuthBloc>().add(LogoutEvent());
                          },
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text(
                            "Logout",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
           
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFF0A1128),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFFF7F2D),
          unselectedItemColor: Colors.white54,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_music_outlined),
              activeIcon: Icon(Icons.library_music),
              label: 'Library',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Hotlist',
            ),
          ],
          currentIndex: 2, // Library selected
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTrackItem(
      BuildContext context,
      String number,
      String title,
      String artist,
      String duration,
      bool isFavorite,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              number,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Mr. $artist • $duration",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? const Color(0xFF1ED760) : Colors.white38,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      
    );
  }
}
