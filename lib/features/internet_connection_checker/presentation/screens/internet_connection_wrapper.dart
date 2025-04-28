import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Custom loading animation using Lottie

                  const SizedBox(height: 20),
                  Text(
                    "Checking connection...",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.5, end: 0),
                ],
              ),
            ),
          );
        } else if (state is InternetConnectionAvailable) {
          return child;
        } else if (state is InternetConnectionUnavailable) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.indigo.shade900,
                    Colors.indigo.shade700,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // No internet animation


                    const SizedBox(height: 20),

                    Text(
                      "No Internet Connection",
                      style: GoogleFonts.raleway(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate()
                        .fadeIn(delay: 300.ms, duration: 500.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 10),

                    Text(
                      "Please check your connection and try again",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ).animate()
                        .fadeIn(delay: 500.ms, duration: 500.ms),

                    const SizedBox(height: 40),

                    // Try Again Button
                    Container(
                      width: 200,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<InternetConnectionBloc>().add(RetryInternetConnection());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.indigo.shade900,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.refresh),
                            const SizedBox(width: 8),
                            Text(
                              "Try Again",
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate()
                        .fadeIn(delay: 700.ms, duration: 500.ms)
                        .slideY(begin: 0.5, end: 0),

                    const SizedBox(height: 20),

                    // Go to Downloads Button
                    Container(
                      width: 200,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: OutlinedButton(


                        onPressed: () {
                          Navigator.pushNamed(context, Routes.downloadedSongsScreen);
                        },
                        style: OutlinedButton.styleFrom(

                          side: const BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          foregroundColor: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.download_done),
                            const SizedBox(width: 8),
                            Text(
                              "TO Downloads",
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate()
                        .fadeIn(delay: 900.ms, duration: 500.ms)
                        .slideY(begin: 0.5, end: 0),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.signal_wifi_off,
                  size: 80,
                  color: Colors.grey,
                ).animate()
                    .fadeIn(duration: 500.ms)
                    .scale(),
                const SizedBox(height: 20),
                Text(
                  "Connection Error",
                  style: GoogleFonts.raleway(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
