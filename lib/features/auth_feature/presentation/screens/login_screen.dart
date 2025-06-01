import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';

import '../../../../core/widgets/custom_snack_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
   late FocusNode emailFocusNode;
   late FocusNode passwordFocusNode;

  // Track if fields are valid
  bool _areFieldsValid = false;

  // Track if login button has been clicked
  bool hasAttemptedLogin = false;

  // Track field errors
  String? emailError;
  String? passwordError;

  @override
  void initState() {
    super.initState();
    // Add listeners to controllers to check validation when text changes
    emailController.addListener(_validateFields);
    passwordController.addListener(_validateFields);
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up controllers and listeners
    emailController.removeListener(_validateFields);
    passwordController.removeListener(_validateFields);
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  // Method to validate all fields
  void _validateFields() {
    setState(() {
      _areFieldsValid = emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty;

      // Update field errors if user has attempted login
      if (hasAttemptedLogin) {
        emailError = emailController.text.isEmpty ? "Email is required" : null;
        passwordError = passwordController.text.isEmpty ? "Password is required" : null;
      }
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
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
      emailFocusNode.unfocus();
      passwordFocusNode.unfocus();

    }else if(state is AuthSuccess){
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      Navigator.pushNamedAndRemoveUntil(context, Routes.homeScreen, (Route<dynamic> route)=> false);
    }else if (state is AuthFailure) {
      // Handle authentication failure

      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Dismiss loading dialog if present
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.error(
              message: state.message ?? "Failed to change password"
          )
      );
    }

    else  {
      // Hide loading overlay when authentication is complete
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

          // Dark overlay with gradient - darker at bottom
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
                // Back button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white, size: 24.r),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 20.h),
                        Icon(
                          Icons.diamond,
                          color: Colors.white,
                          size: 52.r,
                        ),
                        // Title
                        Text(
                          "Welcome back",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 30.h),

                        // Email field
                        TextField(
                          focusNode: emailFocusNode,
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,

                          style: TextStyle(color: Colors.white, fontSize: 16.sp),
                          decoration: InputDecoration(

                            hintText: "Enter your email",
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
                            errorText: emailError,
                            errorStyle: TextStyle(color: Colors.red, fontSize: 14.sp),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Password field
                        TextField(
                          focusNode: passwordFocusNode,
                          controller: passwordController,
                          obscureText: true,
                          style: TextStyle(color: Colors.white, fontSize: 16.sp),
                          decoration: InputDecoration(
                            hintText: "Enter your password",
                            hintStyle: TextStyle(fontSize: 16.sp),
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
                            errorText: passwordError,
                            errorStyle: TextStyle(color: Colors.red, fontSize: 14.sp),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          ),
                        ),

                        // Forgot password button
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Navigate to forgot password screen
                              Navigator.pushNamed(context, Routes.forgotPasswordScreen);
                            },
                            child: Text(
                              "Forgot password?",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // Login button
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              hasAttemptedLogin = true;

                              // Set error messages for empty fields
                              emailError = emailController.text.isEmpty ? "Email is required" : null;
                              passwordError = passwordController.text.isEmpty ? "Password is required" : null;
                            });

                            if (_areFieldsValid) {
                              context.read<AuthBloc>().add(SignInEvent(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim()
                              ));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _areFieldsValid ? Colors.white : const Color.fromRGBO(49, 47, 52, 0.5),
                            foregroundColor: _areFieldsValid ? Colors.black : Colors.white.withOpacity(0.3),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            minimumSize: Size(double.infinity, 50.h),
                          ),
                          child: Text(
                            "Log in",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Or divider
                        Text(
                          "or",
                          style: TextStyle(color: Colors.white60, fontSize: 15.sp),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 16.h),

                        // Google sign in button
                        ElevatedButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(GoogleSignInEvent());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            minimumSize: Size(double.infinity, 50.h),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(image: const AssetImage("assets/images/google.png"), width: 16.r, height: 16.r),
                              SizedBox(width: 8.w),
                              Text(
                                "Continue with Google",
                                style: TextStyle(fontSize: 16.sp),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),


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
