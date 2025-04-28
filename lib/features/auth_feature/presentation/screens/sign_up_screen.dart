import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  late FocusNode emailFocusNode;
  late FocusNode passwordFocusNode;
  late FocusNode confirmFocusNode;

  // Track if fields are valid
  bool _areFieldsValid = false;
  bool hasPasswordError = false;
  bool isPasswordsSame = false;

  // Password validation criteria
  bool isPasswordAtLeast8Characters = false;
  bool doesPasswordContainsOneUppercaseLetter = false;
  bool doesPasswordContainsOneLowercaseLetter = false;
  bool doesPasswordContainsOneDigit = false;
  bool doesPasswordContainsOneSpecialCharacter = false;
  bool doesPasswordContainsSpace = false;

  // Track if sign up button has been clicked
  bool hasAttemptedSignUp = false;

  // Track field errors
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  @override
  void initState() {
    super.initState();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    confirmFocusNode = FocusNode();

    // Add listeners to all controllers to check validation when text changes
    emailController.addListener(_validateFields);
    passwordController.addListener(_validateFields);
    confirmPasswordController.addListener(_validateFields);
  }

  @override
  void dispose() {
    // Clean up controllers and listeners
    emailController.removeListener(_validateFields);
    passwordController.removeListener(_validateFields);
    confirmPasswordController.removeListener(_validateFields);
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Method to validate all fields
  void _validateFields() {
    setState(() {
      _areFieldsValid = emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty;
      isPasswordsSame = passwordController.text == confirmPasswordController.text;

      // Fix the password validation logic
      isPasswordAtLeast8Characters = passwordController.text.length >= 8;
      doesPasswordContainsOneUppercaseLetter = passwordController.text.contains(RegExp(r"[A-Z]"));
      doesPasswordContainsOneLowercaseLetter = passwordController.text.contains(RegExp(r"[a-z]"));
      doesPasswordContainsOneDigit = passwordController.text.contains(RegExp(r"[0-9]"));
      doesPasswordContainsOneSpecialCharacter = passwordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      doesPasswordContainsSpace = !passwordController.text.contains(" ");

      // Update field errors if user has attempted sign up
      if (hasAttemptedSignUp) {
        emailError = emailController.text.isEmpty ? "Email is required" : null;
        passwordError = passwordController.text.isEmpty ? "Password is required" : null;
        confirmPasswordError = confirmPasswordController.text.isEmpty ? "Confirm password is required" : null;
      }
    });
  }

  // Method to check if all password requirements are met
  bool _isPasswordValid() {
    return isPasswordAtLeast8Characters &&
        doesPasswordContainsOneUppercaseLetter &&
        doesPasswordContainsOneLowercaseLetter &&
        doesPasswordContainsOneDigit &&
        doesPasswordContainsOneSpecialCharacter &&
        doesPasswordContainsSpace;
  }

  // Widget to display password strength indicators - only shown after sign up attempt
  Widget _buildPasswordStrengthIndicator() {
    // Only show when user has attempted sign up and password is not empty
    if (!hasAttemptedSignUp || passwordController.text.isEmpty ) {
      return const SizedBox.shrink();
    }
  if(!_isPasswordValid()){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password Requirements:",
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 8.h),
        _buildRequirementRow(
            isPasswordAtLeast8Characters,
            "At least 8 characters"
        ),
        _buildRequirementRow(
            doesPasswordContainsOneUppercaseLetter,
            "Contains uppercase letter"
        ),
        _buildRequirementRow(
            doesPasswordContainsOneLowercaseLetter,
            "Contains lowercase letter"
        ),
        _buildRequirementRow(
            doesPasswordContainsOneDigit,
            "Contains a number"
        ),
        _buildRequirementRow(
            doesPasswordContainsOneSpecialCharacter,
            "Contains special character"
        ),
        _buildRequirementRow(
            doesPasswordContainsSpace,
            "No spaces"
        ),
      ],
    );}
  return const SizedBox();
  }

  // Widget to build each requirement row with icon and text
  Widget _buildRequirementRow(bool isMet, String requirement) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          // Icon - checkmark or cross
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: isMet ? Colors.green : Colors.red,
            size: 20.r,
          ),
          SizedBox(width: 8.w),
          // Requirement text
          Text(
            requirement,
            style: TextStyle(
              color: isMet ? Colors.green : Colors.red,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  // Widget to show if passwords match
  Widget _buildPasswordMatchIndicator() {
    // Only show when user has attempted sign up and both password fields have content
    if (!hasAttemptedSignUp ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Row(
        children: [
          Icon(
            isPasswordsSame ? Icons.check_circle : Icons.cancel,
            color: isPasswordsSame ? Colors.green : Colors.red,
            size: 20.r,
          ),
          SizedBox(width: 8.w),
          Text(
            isPasswordsSame ? "Passwords match" : "Passwords don't match",
            style: TextStyle(
              color: isPasswordsSame ? Colors.green : Colors.red,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
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
      confirmFocusNode.unfocus();
    }else if(state is AuthSuccess){
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      Navigator.pushNamedAndRemoveUntil(context, Routes.setNameScreen, (Route<dynamic> route)=> false);
    }else if (state is AuthFailure) {
      // Handle authentication failure
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Dismiss loading dialog if present
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 22),
              const SizedBox(width: 12),
              // Use Expanded to allow the text to wrap and use multiple lines
              Expanded(
                child: Text(
                  state.message ?? "Failed to change password",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF23272A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
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
                          "Create account",
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

                        SizedBox(height: 16.h),

                        // Password requirements (between password and confirm password)
                        _buildPasswordStrengthIndicator(),

                        SizedBox(height: 16.h),

                        // Confirm Password field
                        TextField(
                          focusNode: confirmFocusNode,
                          controller: confirmPasswordController,
                          obscureText: true,
                          style: TextStyle(color: Colors.white, fontSize: 16.sp),
                          decoration: InputDecoration(
                            hintText: "Confirm your password",
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
                            errorText: confirmPasswordError,
                            errorStyle: TextStyle(color: Colors.red, fontSize: 14.sp),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          ),
                        ),

                        // Password match indicator (below confirm password)
                        _buildPasswordMatchIndicator(),

                        SizedBox(height: 24.h),

                        // Sign Up button
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if(_areFieldsValid && (!_isPasswordValid() || !isPasswordsSame)){
                                hasAttemptedSignUp = true;
                              }


                              // Set error messages for empty fields
                              emailError = emailController.text.isEmpty ? "Email is required" : null;
                              passwordError = passwordController.text.isEmpty ? "Password is required" : null;
                              confirmPasswordError = confirmPasswordController.text.isEmpty ? "Confirm password is required" : null;
                            });

                            if (_areFieldsValid && isPasswordsSame && _isPasswordValid()) {
                              context.read<AuthBloc>().add(SignUpEvent(
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
                            "Sign up",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Terms text
                        Text(
                          "or",
                          style: TextStyle(color: Colors.white60, fontSize: 15.sp),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
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
