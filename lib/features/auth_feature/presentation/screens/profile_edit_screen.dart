// presentation/pages/edit_profile_screen.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for profile fields.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _profilePictureUrlController = TextEditingController();

  // Flag to ensure initialization happens only once.
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _profilePictureUrlController.dispose();
    super.dispose();
  }

  // Initialize the controllers with data from Firestore.
  void _initializeFields(Map<String, dynamic> data) {
    _nameController.text = data['name'] ?? '';
    _emailController.text = data['email'] ?? '';
    _profilePictureUrlController.text = data['profilePictureUrl'] ?? '';
    _isInitialized = true;
  }

  // Function to pick an image from the gallery and upload it to Supabase Storage.
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return;

      String fileName;
      bool fileExists = _profilePictureUrlController.text.isNotEmpty;

      if (fileExists) {
        try {
          // Assuming URL is like: https://<project-id>.supabase.co/storage/v1/object/public/users_photo/<fileName>?token=...
          final uri = Uri.parse(_profilePictureUrlController.text);
          fileName = uri.pathSegments.last;
        } catch (e) {
          // If parsing fails, fall back to generating a new file name.
          fileName = '${firebaseUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          fileExists = false;
        }
      } else {
        fileName = '${firebaseUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      }

      late final response;
      if (fileExists) {
        // Use update() to replace the existing file.
        response = await Supabase.instance.client.storage
            .from('users_photo')
            .update(fileName, file, fileOptions: const FileOptions(cacheControl: '3600'));
      } else {
        // No existing file, use upload().
        response = await Supabase.instance.client.storage
            .from('users_photo')
            .upload(fileName, file, fileOptions: const FileOptions(cacheControl: '3600'));
      }

      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: ${response.error!.message}")),
        );
      } else {
        // Create a signed URL (or use getPublicUrl() if you want a public URL)
        final publicUrl = await Supabase.instance.client.storage
            .from('users_photo')
            .createSignedUrl(fileName, 31536000);
        setState(() {
          _profilePictureUrlController.text = publicUrl;
        });
      }
    }
  }

  // Save changes by dispatching the update event.
  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(UpdateUserProfileEvent(
        name: _nameController.text,
        email: _emailController.text,
        profilePictureUrl: _profilePictureUrlController.text,
      ));

      // Navigate back to the Profile Screen.
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      return Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
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

          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (!_isInitialized) {
            _initializeFields(data);
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Name"),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Name cannot be empty" : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Email cannot be empty" : null,
                  ),
                  const SizedBox(height: 10),
                  // Read-only field to display the uploaded image URL.
                  TextFormField(
                    controller: _profilePictureUrlController,
                    decoration: const InputDecoration(labelText: "Profile Picture URL"),
                    readOnly: true,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickAndUploadImage,
                    child: const Text("Upload Profile Photo"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    child: const Text("Save Changes"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
