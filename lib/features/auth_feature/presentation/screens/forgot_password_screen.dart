import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/dependency_injection.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late FocusNode _emailFocusNode;

  // Track if email is valid
  bool _isEmailValid = false;
  bool _hasAttemptedReset = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _emailFocusNode = FocusNode();
    _emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  // Email validation using regex
  bool _isValidEmail(String email) {
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    setState(() {
      _isEmailValid = email.isNotEmpty && _isValidEmail(email);

      // Update error message if user has attempted reset
      if (_hasAttemptedReset) {
        if (email.isEmpty) {
          _emailError = "Email is required";
        } else if (!_isValidEmail(email)) {
          _emailError = "Please enter a valid email address";
        } else {
          _emailError = null;
        }
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
          _emailFocusNode.unfocus();
        } else if (state is ResetPasswordSuccess) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Dismiss loading dialog
          }
           Navigator.pushNamed(context, Routes.resetPasswordSuccessScreen);
        } else if (state is ResetPasswordFail) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Dismiss loading dialog
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
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
                  stops: const [0.0, 0.1, 0.7],
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 20.h),

                            // Icon
                            Icon(
                              Icons.lock_reset,
                              color: Colors.white,
                              size: 52.r,
                            ),

                            SizedBox(height: 16.h),

                            // Title
                            Text(
                              "Forgot Password",
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
                              "Enter your email address and we'll send you instructions to reset your password",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: 40.h),

                            // Email field with validation
                            TextField(
                              focusNode: _emailFocusNode,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(color: Colors.white, fontSize: 16.sp),
                              decoration: InputDecoration(
                                hintText: "Enter your email",
                                hintStyle: TextStyle(fontSize: 16.sp, color: Colors.white60),
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
                                errorText: _emailError,
                                errorStyle: TextStyle(color: Colors.red, fontSize: 14.sp),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: Colors.white70,
                                ),
                              ),
                            ),

                            SizedBox(height: 24.h),

                            // Reset Password button
                            ElevatedButton(
                              onPressed:  () {
                                setState(() {
                                  _hasAttemptedReset = true;

                                  // Validate email one more time
                                  if (_emailController.text.trim().isEmpty) {
                                    _emailError = "Email is required";
                                  } else if (!_isValidEmail(_emailController.text.trim())) {
                                    _emailError = "Please enter a valid email address";
                                  } else {
                                    _emailError = null;
                                  }
                                });

                                if (_isEmailValid) {
                                  context.read<AuthBloc>().add(
                                      ResetPasswordEvent(email: _emailController.text.trim())
                                  );
                                }
                              }
                                  ,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isEmailValid ? Colors.white : const Color.fromRGBO(49, 47, 52, 0.5),
                                foregroundColor: _isEmailValid ? Colors.black : Colors.white.withOpacity(0.3),
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                minimumSize: Size(double.infinity, 50.h),
                              ),
                              child: Text(
                                "Send Reset Link",
                                style: TextStyle(fontSize: 16.sp),
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // Back to login option
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "Back to Login",
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
