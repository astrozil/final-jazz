import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/features/internet_connection_checker/presentation/bloc/internet_connection_checker_bloc.dart';
import 'package:jazz/features/internet_connection_checker/presentation/bloc/internet_connection_checker_event.dart';
import 'package:jazz/features/internet_connection_checker/presentation/bloc/internet_connection_checker_state.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class InternetConnectionWrapper extends StatelessWidget {
  final Widget child;
  const InternetConnectionWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InternetConnectionBloc, InternetConnectionState>(
      builder: (context, state) {
        if (state is InternetConnectionLoading) {
          return Scaffold(
            backgroundColor: AppColors.primaryBackgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Checking connection...",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFB3B3B3),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is InternetConnectionAvailable) {
          return child;
        } else if (state is InternetConnectionUnavailable) {
          return Scaffold(
            backgroundColor: AppColors.primaryBackgroundColor,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2A2A2A),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.wifi_off_outlined,
                        color: Color(0xFF666666),
                        size: 32,
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      "No Internet Connection",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFFFFF),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Please check your connection and try again",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF888888),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Try Again Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<InternetConnectionBloc>().add(RetryInternetConnection());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF000000),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Try Again",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Go to Downloads Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.downloadedSongsScreen);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF2A2A2A),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          foregroundColor: const Color(0xFFFFFFFF),
                          backgroundColor: Colors.transparent,
                        ),
                        child: Text(
                          "View Downloads",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2A2A2A),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.signal_wifi_off_outlined,
                    size: 24,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Connection Error",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
