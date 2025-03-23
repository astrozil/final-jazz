// presentation/pages/profile_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    // If there's no authenticated user, show a message.
    if (firebaseUser == null) {
      return Scaffold(
        body: Center(child: Text("User not logged in")),
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
        appBar: AppBar(
          title: const Text("Profile"),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(firebaseUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !(snapshot.data?.exists ?? false)) {
              return const Center(child: Text("Profile data not available"));
            }

            // Parse the fetched document.
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final name = data['name'] ?? 'No Name';
            final email = data['email'] ?? 'No Email';
            final profilePictureUrl = data['profilePictureUrl'] ?? '';
            final List<dynamic> favouriteArtistsDynamic =
                data['favouriteArtists'] ?? [];
            final favouriteArtists = favouriteArtistsDynamic.cast<String>();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Display profile picture if available.
                  if (profilePictureUrl.isNotEmpty)
                    CircleAvatar(
                      backgroundImage: NetworkImage(profilePictureUrl),
                      radius: 40,
                    )
                  else
                    const CircleAvatar(
                      child: Icon(Icons.person, size: 40),
                      radius: 40,
                    ),
                  const SizedBox(height: 20),
                  Text(
                    "Name: $name",
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Email: $email",
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Favourite Artists: ${favouriteArtists.join(', ')}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(LogoutEvent());
                    },
                    child: const Text("Logout"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to an edit profile screen if you have one.
                      Navigator.pushNamed(context, Routes.profileEditScreen);
                    },
                    child: const Text("Edit Profile"),
                  ),
                  Visibility(
                    visible: !data['signInWithGoogle'],
                    child: ElevatedButton(onPressed: (){
                      Navigator.pushNamed(context, Routes.passwordChangeScreen);
                                }, child: const Text("Change Password")),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
