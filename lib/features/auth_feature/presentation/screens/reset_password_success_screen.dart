import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/routes.dart';

class ResetPasswordSuccessScreen extends StatelessWidget {
  const ResetPasswordSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                // Close button (X) at top right
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 24.r),
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        Routes.authScreen,
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
                          "Email Sent!",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 16.h),

                        // Description
                        Text(
                          "We've sent a password reset link to your email address. Please check your inbox and follow the instructions to reset your password.",
                          style: TextStyle(
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
                            color: Colors.white.withOpacity(0.1),
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
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Spacer(),

                        // Back to login button
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(
                              context,
                              Routes.authScreen,
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
                            "Back to Login",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Resend email button
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Go back to forgot password screen
                          },
                          child: Text(
                            "Didn't receive the email? Try again",
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
    );
  }
}
