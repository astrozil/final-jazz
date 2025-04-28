import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';

import '../../../../core/widgets/custom_snack_bar.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<ProfileEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _profilePictureUrlController = TextEditingController();

  // Add these variables to track original values
  String _originalName = '';
  String _originalProfilePictureUrl = '';

  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _profilePictureUrlController.dispose();
    super.dispose();
  }

  // Helper method to get first letter of name
  String _getFirstLetter() {
    if (_nameController.text.isEmpty) return "?";
    return _nameController.text[0].toUpperCase();
  }

  // Modified to store original values
  void _initializeFields(Map<String, dynamic> data) {
    _nameController.text = data['name'] ?? 'Username';
    _profilePictureUrlController.text = data['profilePictureUrl'] ?? '';
    _originalName = _nameController.text;
    _originalProfilePictureUrl = _profilePictureUrlController.text;
    _isInitialized = true;
  }

  // Add this method to check if there are changes
  bool _hasChanges() {
    return _nameController.text != _originalName ||
        _profilePictureUrlController.text != _originalProfilePictureUrl;
  }

  Future<void> _pickAndUploadImage() async {
    setState(() => _isLoading = true);

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        File file = File(pickedFile.path);
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser == null) return;

        String fileName;
        bool fileExists = _profilePictureUrlController.text.isNotEmpty;

        if (fileExists) {
          try {
            final uri = Uri.parse(_profilePictureUrlController.text);
            fileName = uri.pathSegments.last;
          } catch (e) {
            fileName = '${firebaseUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
            fileExists = false;
          }
        } else {
          fileName = '${firebaseUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        }

        late final response;
        if (fileExists) {
          response = await Supabase.instance.client.storage
              .from('users_photo')
              .update(fileName, file, fileOptions: const FileOptions(cacheControl: '3600'));
        } else {
          response = await Supabase.instance.client.storage
              .from('users_photo')
              .upload(fileName, file, fileOptions: const FileOptions(cacheControl: '3600'));
        }

        if (response == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                CustomSnackBar.error(
                    message:"Upload Failed. Please try again."
                )
            );
          }
        } else {
          final publicUrl = await Supabase.instance.client.storage
              .from('users_photo')
              .createSignedUrl(fileName, 31536000);

          setState(() {
            _profilePictureUrlController.text = publicUrl;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.error(
                message: e.toString()
            )
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _saveChanges() {
    // Only proceed if there are changes
    if (!_hasChanges()) return;

    setState(() => _isLoading = true);

    try {
      context.read<AuthBloc>().add(UpdateUserProfileEvent(
        name: _nameController.text,
        profilePictureUrl: _profilePictureUrlController.text,
      ));

      ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.success(
              message: "Profile updated successfully."
          )
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.error(message: e.toString()),
      );
      setState(() => _isLoading = false);
    }
  }

  void _updateNameInUI(String newName) {
    setState(() {
      _nameController.text = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(25, 25, 27, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(37,36,42, 1),
        centerTitle: true,
        title: const Text(
          "Edit profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined,color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(firebaseUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (!snapshot.hasData || !(snapshot.data?.exists ?? false)) {
            return const Center(
              child: Text(
                  "Profile data not available",
                  style: TextStyle(color: Colors.white)
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (!_isInitialized) {
            _initializeFields(data);
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture Section
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          margin: const EdgeInsets.only(top: 24),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: _profilePictureUrlController.text.isNotEmpty
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.network(
                              _profilePictureUrlController.text,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    _getFirstLetter(),
                                    style: const TextStyle(
                                      fontSize: 48,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                              : Center(
                            child: Text(
                              _getFirstLetter(),
                              style: const TextStyle(
                                fontSize: 48,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _isLoading ? null : _pickAndUploadImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // BASIC INFO Section
                  const Text(
                    "BASIC INFO",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Your profile picture and name will be public.",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // Profile Name Field
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(37,36,42,1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: const Text(
                        "Profile name",
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _nameController.text,
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                      onTap: _isLoading
                          ? null
                          : () {
                        final TextEditingController tempNameController =
                        TextEditingController(text: _nameController.text);

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => StatefulBuilder(
                            builder: (context, setModalState) {
                              // Local variables for validation
                              bool isNameEmpty = tempNameController.text.trim().isEmpty;
                              bool isNameTooLong = tempNameController.text.length > 30;
                              bool hasNameChanged = tempNameController.text != _nameController.text;
                              bool isNameValid = !isNameEmpty && !isNameTooLong;
                              bool isSaveEnabled = isNameValid && hasNameChanged;

                              // Validation message based on conditions
                              String? validationMessage;
                              if (isNameEmpty) {
                                validationMessage = "Name cannot be empty";
                              } else if (isNameTooLong) {
                                validationMessage = "Name cannot exceed 30 characters";
                              }

                              return Container(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).viewInsets.bottom,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Edit Profile Name",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      TextField(
                                        controller: tempNameController,
                                        style: const TextStyle(color: Colors.white),
                                        autofocus: true,
                                        onChanged: (value) {
                                          // Update state when text changes to re-evaluate validations
                                          setModalState(() {});
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Enter your name",
                                          hintStyle: TextStyle(fontSize: 16.sp),
                                          labelStyle: TextStyle(color: Colors.white70, fontSize: 16.sp),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16.r),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16.r),
                                            borderSide: const BorderSide(color: Colors.white30),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16.r),
                                            borderSide: const BorderSide(color: Colors.white),
                                          ),
                                          errorText: validationMessage,
                                          errorStyle: TextStyle(color: Colors.red, fontSize: 14.sp),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                          counterText: "${tempNameController.text.length}/30",
                                          counterStyle: TextStyle(
                                            color: isNameTooLong ? Colors.red : Colors.grey[400],
                                          ),
                                        ),
                                        maxLength: 30,
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.grey,
                                            ),
                                            child: const Text("Cancel"),
                                          ),
                                          const SizedBox(width: 16),
                                          ElevatedButton(
                                            onPressed: isSaveEnabled
                                                ? () {
                                              _updateNameInUI(tempNameController.text);
                                              Navigator.pop(context);
                                            }
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: Colors.black,
                                              disabledBackgroundColor: const Color.fromRGBO(102,102,102, 1),
                                              disabledForegroundColor:const Color.fromRGBO(30, 30, 30, 1) ,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 24,
                                                vertical: 12,
                                              ),
                                            ),
                                            child: const Text(
                                              "Save",
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Save Button - Modified to check for changes
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      // This is the key change - disable button when no changes
                      onPressed: (_isLoading || !_hasChanges()) ? (){} : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_isLoading || !_hasChanges()) ?const Color.fromRGBO(102,102,102, 1) : Colors.white,
                        foregroundColor:(_isLoading || !_hasChanges()) ? const Color.fromRGBO(30, 30, 30, 1) : Colors.black,
                        disabledBackgroundColor: const Color.fromRGBO(102,102,102, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        "SAVE CHANGES",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
