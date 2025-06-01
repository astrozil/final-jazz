import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';

class SetNameScreen extends StatefulWidget {
  const SetNameScreen({super.key});

  @override
  State<SetNameScreen> createState() => _SetNameScreenState();
}

class _SetNameScreenState extends State<SetNameScreen> {
  final TextEditingController nameController = TextEditingController();
  late FocusNode nameFocusNode;
  bool isNameValid = false;
  String? nameError;

  @override
  void initState() {
    super.initState();
    nameFocusNode = FocusNode();
    nameController.addListener(_validateName);
  }

  @override
  void dispose() {
    nameController.removeListener(_validateName);
    nameController.dispose();
    nameFocusNode.dispose();
    super.dispose();
  }

  void _validateName() {
    setState(() {
      isNameValid = nameController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          // Show loading overlay
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
          nameFocusNode.unfocus();
        } else if (state is UserDataUpdated) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Dismiss loading dialog
          }
          Navigator.pushNamed(context, Routes.setFavouriteArtistsScreen);
        } else if (state is AuthFailure) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Dismiss loading dialog
          }
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? "Failed to update profile"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryBackgroundColor,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Album artwork grid background
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/auth_background.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Dark overlay with gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.9),
                    Colors.black,
                  ],
                  stops: [0.0, 0.1, 0.7],
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(24.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 40.h),
                          Icon(
                            Icons.person_outline,
                            color: Colors.white,
                            size: 52.r,
                          ),

                          SizedBox(height: 16.h),

                          // Title
                          Text(
                            "What's your name?",
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 8.h),

                          // Subtitle
                          Text(
                            "Let us know what to call you",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 40.h),

                          // Name field
                          TextField(
                            focusNode: nameFocusNode,
                            controller: nameController,
                            style: TextStyle(color: Colors.white, fontSize: 16.sp),
                            decoration: InputDecoration(
                              hintText: "Enter your name",
                              hintStyle: TextStyle(fontSize: 16.sp),
                              labelStyle: TextStyle(color: Colors.white70, fontSize: 16.sp),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: BorderSide(color: Colors.white30),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              errorText: nameError,
                              errorStyle: TextStyle(color: Colors.red, fontSize: 14.sp),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // Continue button
                          ElevatedButton(
                            onPressed: isNameValid
                                ? () {
                              final name = nameController.text.trim();
                              if (name.isEmpty) {
                                setState(() {
                                  nameError = "Please enter your name";
                                });
                              } else {
                                context.read<AuthBloc>().add(
                                    UpdateUserProfileEvent(name: name));
                              }
                            }
                                : (){

                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isNameValid ? Colors.white : Color.fromRGBO(49, 47, 52, 0.5),
                              foregroundColor: isNameValid ? Colors.black : Colors.white.withOpacity(0.3),
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              minimumSize: Size(double.infinity, 50.h),
                            ),
                            child: Text(
                              "Continue",
                              style: TextStyle(fontSize: 16.sp),
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Skip option
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, Routes.setFavouriteArtistsScreen);
                            },
                            child: Text(
                              "Skip for now",
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 16.sp,
                                decoration: TextDecoration.underline,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
