import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({super.key});

  @override
  _PasswordChangeScreenState createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordConfirmController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  late FocusNode emailFocusNode;
  late FocusNode oldPasswordFocusNode;
  late FocusNode newPasswordFocusNode;

  bool _areFieldsValid = false;

  // Password validation criteria
  bool isPasswordAtLeast8Characters = false;
  bool doesPasswordContainsOneUppercaseLetter = false;
  bool doesPasswordContainsOneLowercaseLetter = false;
  bool doesPasswordContainsOneDigit = false;
  bool doesPasswordContainsOneSpecialCharacter = false;
  bool doesPasswordContainsSpace = false;

  bool hasAttemptedChange = false;

  String? oldPasswordError;
  String? newPasswordError;
  String? confirmPasswordError; // For confirm password

  @override
  void initState() {
    super.initState();
    emailFocusNode = FocusNode();
    oldPasswordFocusNode = FocusNode();
    newPasswordFocusNode = FocusNode();

    _newPasswordConfirmController.addListener(_validateFields);
    _oldPasswordController.addListener(_validateFields);
    _newPasswordController.addListener(_validateFields);
  }

  @override
  void dispose() {
    _newPasswordConfirmController.removeListener(_validateFields);
    _oldPasswordController.removeListener(_validateFields);
    _newPasswordController.removeListener(_validateFields);
    _newPasswordConfirmController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    emailFocusNode.dispose();
    oldPasswordFocusNode.dispose();
    newPasswordFocusNode.dispose();
    super.dispose();
  }

  void _validateFields() {
    setState(() {
      _areFieldsValid = _newPasswordConfirmController.text.isNotEmpty &&
          _oldPasswordController.text.isNotEmpty &&
          _newPasswordController.text.isNotEmpty;

      isPasswordAtLeast8Characters = _newPasswordController.text.length >= 8;
      doesPasswordContainsOneUppercaseLetter = _newPasswordController.text.contains(RegExp(r"[A-Z]"));
      doesPasswordContainsOneLowercaseLetter = _newPasswordController.text.contains(RegExp(r"[a-z]"));
      doesPasswordContainsOneDigit = _newPasswordController.text.contains(RegExp(r"[0-9]"));
      doesPasswordContainsOneSpecialCharacter = _newPasswordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      doesPasswordContainsSpace = !_newPasswordController.text.contains(" ");

      if (hasAttemptedChange) {
        oldPasswordError = _oldPasswordController.text.isEmpty ? "Old password is required" : null;
        newPasswordError = _newPasswordController.text.isEmpty ? "New password is required" : null;
        if (_newPasswordConfirmController.text.isEmpty) {
          confirmPasswordError = "Confirm password is required";
        } else if (_newPasswordController.text != _newPasswordConfirmController.text) {
          confirmPasswordError = "Passwords do not match";
        } else {
          confirmPasswordError = null;
        }
      } else {
        confirmPasswordError = null;
      }
    });
  }

  bool _isPasswordValid() {
    return isPasswordAtLeast8Characters &&
        doesPasswordContainsOneUppercaseLetter &&
        doesPasswordContainsOneLowercaseLetter &&
        doesPasswordContainsOneDigit &&
        doesPasswordContainsOneSpecialCharacter &&
        doesPasswordContainsSpace;
  }

  Widget _buildPasswordStrengthIndicator() {
    if (!hasAttemptedChange || _newPasswordController.text.isEmpty) {
      return const SizedBox.shrink();
    }
    if (!_isPasswordValid()) {
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
              isPasswordAtLeast8Characters, "At least 8 characters"),
          _buildRequirementRow(doesPasswordContainsOneUppercaseLetter,
              "Contains uppercase letter"),
          _buildRequirementRow(doesPasswordContainsOneLowercaseLetter,
              "Contains lowercase letter"),
          _buildRequirementRow(
              doesPasswordContainsOneDigit, "Contains a number"),
          _buildRequirementRow(doesPasswordContainsOneSpecialCharacter,
              "Contains special character"),
          _buildRequirementRow(doesPasswordContainsSpace, "No spaces"),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildRequirementRow(bool isMet, String requirement) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: isMet ? Colors.green : Colors.red,
            size: 20.r,
          ),
          SizedBox(width: 8.w),
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
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
          oldPasswordFocusNode.unfocus();
          newPasswordFocusNode.unfocus();
        } else if (state is PasswordChanged) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.greenAccent, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Password changed successfully!",
                      style: TextStyle(
                        color: Colors.white, // Ensures contrast on dark backgrounds
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF222831), // Deep dark shade for music app
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 3),
              elevation: 6,
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          );

          Navigator.pop(context);
        } else if (state is AuthFailure) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
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

        } else {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryBackgroundColor,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [

            SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white, size: 24.r),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView( // <-- Make the screen scrollable[2][3][4][5]
                      child: Padding(
                        padding: EdgeInsets.all(24.r),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 20.h),
                              Icon(
                                Icons.lock_reset,
                                color: Colors.white,
                                size: 52.r,
                              ),
                              Text(
                                "Change Password",
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "Update your password to keep your account secure",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 30.h),
                              SizedBox(height: 16.h),
                              TextField(
                                focusNode: oldPasswordFocusNode,
                                controller: _oldPasswordController,
                                obscureText: true,
                                style: TextStyle(color: Colors.white, fontSize: 16.sp),
                                decoration: InputDecoration(
                                  hintText: "Enter your current password",
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
                                  errorText: oldPasswordError,
                                  errorStyle: TextStyle(color: Colors.red, fontSize: 14.sp),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              TextField(
                                focusNode: newPasswordFocusNode,
                                controller: _newPasswordController,
                                obscureText: true,
                                style: TextStyle(color: Colors.white, fontSize: 16.sp),
                                decoration: InputDecoration(
                                  hintText: "Enter your new password",
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
                                  errorText: newPasswordError,
                                  errorStyle: TextStyle(color: Colors.red, fontSize: 14.sp),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              _buildPasswordStrengthIndicator(),
                              TextField(
                                focusNode: emailFocusNode,
                                controller: _newPasswordConfirmController,
                                obscureText: true,
                                style: TextStyle(color: Colors.white, fontSize: 16.sp),
                                decoration: InputDecoration(
                                  hintText: "Confirm Password",
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
                                  errorText: confirmPasswordError, // <-- Show error for confirm password
                                  errorStyle: TextStyle(color: Colors.red, fontSize: 14.sp),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                ),
                              ),
                              SizedBox(height: 24.h),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    if(_areFieldsValid && ( !_isPasswordValid() || confirmPasswordError != null) ){
                                      hasAttemptedChange = true;
                                    }
                                    oldPasswordError = _oldPasswordController.text.isEmpty ? "Current password is required" : null;
                                    newPasswordError = _newPasswordController.text.isEmpty ? "New password is required" : null;
                                    if (_newPasswordConfirmController.text.isEmpty) {
                                      confirmPasswordError = "Confirm Password is required";
                                    } else if (_newPasswordController.text != _newPasswordConfirmController.text) {
                                      confirmPasswordError = "Passwords do not match";
                                    } else {
                                      confirmPasswordError = null;
                                    }
                                  });

                                  if (_areFieldsValid && _isPasswordValid() && confirmPasswordError == null) {
                                    context.read<AuthBloc>().add(
                                      ChangePasswordEvent(
                                        email: FirebaseAuth.instance.currentUser!.email!,
                                        oldPassword: _oldPasswordController.text.trim(),
                                        newPassword: _newPasswordController.text.trim(),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _areFieldsValid ? Colors.white : AppColors.disabledButtonBackgroundColor,
                                  foregroundColor: _areFieldsValid ? Colors.black : AppColors.disabledButtonForegroundColor,
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  minimumSize: Size(double.infinity, 50.h),
                                ),
                                child: Text(
                                  "Change Password",
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  "Cancel",
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
