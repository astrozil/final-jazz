import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  _ChangeEmailScreenState createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // Added password controller
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode; // Added password focus node

  bool _isEmailValid = false;
  bool _isPasswordValid = false; // Added password validation flag
  bool _hasAttemptedChange = false;
  String? _emailError;
  String? _passwordError; // Added password error
  bool _isPasswordVisible = false; // For password visibility toggle

  @override
  void initState() {
    super.initState();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode(); // Initialize password focus node
    _newEmailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword); // Add password listener
  }

  @override
  void dispose() {
    _newEmailController.removeListener(_validateEmail);
    _passwordController.removeListener(_validatePassword); // Remove password listener
    _newEmailController.dispose();
    _passwordController.dispose(); // Dispose password controller
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose(); // Dispose password focus node
    super.dispose();
  }

  // Email validation using regex
  bool _isValidEmail(String email) {
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  void _validateEmail() {
    final email = _newEmailController.text.trim();
    setState(() {
      _isEmailValid = email.isNotEmpty && _isValidEmail(email);

      // Update error message if user has attempted change
      if (_hasAttemptedChange) {
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

  // Password validation
  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _isPasswordValid = password.isNotEmpty;

      // Update error message if user has attempted change
      if (_hasAttemptedChange) {
        if (password.isEmpty) {
          _passwordError = "Password is required";
        } else {
          _passwordError = null;
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
            builder: (context) => Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
          _emailFocusNode.unfocus();
          _passwordFocusNode.unfocus(); // Unfocus password field
        } else if (state is EmailUpdated) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Dismiss loading dialog
          }
          // Navigate to success screen
          Navigator.pushReplacementNamed(context, '/emailChangeSuccessScreen');
        } else if (state is AuthFailure) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Dismiss loading dialog
          }

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? "Failed to change email"),
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
                              Icons.email_outlined,
                              color: Colors.white,
                              size: 52.r,
                            ),

                            SizedBox(height: 16.h),

                            // Title
                            Text(
                              "Change Email",
                              style: GoogleFonts.poppins(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: 8.h),

                            // Subtitle
                            Text(
                              "Enter your new email address and current password below",
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: 40.h),

                            // Email field with validation
                            TextField(
                              focusNode: _emailFocusNode,
                              controller: _newEmailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(color: Colors.white, fontSize: 16.sp),
                              decoration: InputDecoration(
                                hintText: "Enter your new email",
                                hintStyle: TextStyle(fontSize: 16.sp, color: Colors.white60),
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
                                errorText: _emailError,
                                errorStyle: TextStyle(color: Colors.red, fontSize: 14.sp),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),

                              ),
                            ),

                            SizedBox(height: 16.h),

                            // Password field with validation - ADDED
                            TextField(
                              focusNode: _passwordFocusNode,
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              style: TextStyle(color: Colors.white, fontSize: 16.sp),
                              decoration: InputDecoration(
                                hintText: "Enter your current password",
                                hintStyle: TextStyle(fontSize: 16.sp, color: Colors.white60),
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
                                errorText: _passwordError,
                                errorStyle: TextStyle(color: Colors.red, fontSize: 14.sp),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),

                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // Note about verification
                            Container(
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryBackgroundColor,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.white70,
                                    size: 24.r,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      "A verification email will be sent to your new address. You'll need to verify before the change takes effect.",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 24.h),

                            // Change Email button
                            ElevatedButton(
                              onPressed: (_isEmailValid && _isPasswordValid)
                                  ? () {
                                setState(() {
                                  _hasAttemptedChange = true;
                                  // Validate email one more time
                                  if (_newEmailController.text.trim().isEmpty) {
                                    _emailError = "Email is required";
                                  } else if (!_isValidEmail(_newEmailController.text.trim())) {
                                    _emailError = "Please enter a valid email address";
                                  } else {
                                    _emailError = null;
                                  }

                                  // Validate password
                                  if (_passwordController.text.isEmpty) {
                                    _passwordError = "Password is required";
                                  } else {
                                    _passwordError = null;
                                  }
                                });

                                if (_isEmailValid && _isPasswordValid) {
                                  context.read<AuthBloc>().add(
                                    UpdateEmailEvent(
                                      newEmail: _newEmailController.text.trim(),
                                      password: _passwordController.text,
                                    ),
                                  );
                                }
                              }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                disabledBackgroundColor: AppColors.disabledButtonBackgroundColor,
                                disabledForegroundColor: AppColors.disabledButtonForegroundColor,
                                backgroundColor:  Colors.white ,
                                foregroundColor:  Colors.black ,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                minimumSize: Size(double.infinity, 50.h),
                              ),
                              child: Text(
                                "Change Email",
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // Cancel button
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.poppins(
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

// Success screen for email change
class EmailChangeSuccessScreen extends StatelessWidget {
  const EmailChangeSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [



          // Content
          SafeArea(
            child: Column(
              children: [
                // Close button (X) at top right
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 24.r),
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/profileScreen',
                            (route) => false
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Success icon
                        Icon(
                          Icons.mark_email_read,
                          color: Colors.white,
                          size: 80.r,
                        ),

                        SizedBox(height: 24.h),

                        // Title
                        Text(
                          "Verification Email Sent!",
                          style: GoogleFonts.poppins(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 16.h),

                        // Description
                        Text(
                          "We've sent a verification link to your new email address. Please check your inbox and click the link to complete the email change.",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 16.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 16.h),

                        // Note about spam folder
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBackgroundColor,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white70,
                                size: 24.r,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  "If you don't see the email in your inbox, please check your spam or junk folder.",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Spacer(),

                        // Back to account button
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/profileScreen',
                                  (route) => false
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            minimumSize: Size(double.infinity, 50.h),
                          ),
                          child: Text(
                            "Back to Account",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                            ),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Resend email button
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Go back to change email screen
                          },
                          child: Text(
                            "Didn't receive the email? Try again",
                            style: GoogleFonts.poppins(
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
    );
  }
}
