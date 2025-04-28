import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoginMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {

        if (state is AuthSuccess) {
            if(state.isNewUser){
              Navigator.pushReplacementNamed(context, Routes.setNameScreen);
            }else {
              Navigator.pushReplacementNamed(context, Routes.searchScreen);
            }
          }else if(state is IsLoggedIn){
            bool isLoggedIn = state.isLoggedIn;
            if(isLoggedIn){
              Navigator.pushReplacementNamed(context, Routes.searchScreen);
            }
          }
        },
        child: Stack(
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
                    Colors.black.withOpacity(1),
                  ],
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 150),
                      // Logo
                      // Diamond logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.diamond,
                            color: Colors.white,
                            size: 32,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "JAZZ",
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "For your music.",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Experience music the way it was meant to sound, and support your favorite artists directly.",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      // Auth buttons

                      const SizedBox(height: 200),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(GoogleSignInEvent());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                           Image(image: AssetImage("assets/images/google.png"),width: 16,height: 16,),
                            const SizedBox(width: 8),
                            Text("Continue with Google"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.signUpScreen);
                          // Handle email sign up
                          setState(() {
                            isLoginMode = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          side: BorderSide.none,
                          foregroundColor: Colors.white,
                          backgroundColor: Color.fromRGBO(46, 47, 52, 1),

                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(

                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text("Sign up"),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          // Handle login
                          setState(() {
                            isLoginMode = true;
                          });
                          Navigator.pushNamed(context, Routes.loginScreen);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: Text("Log in"),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
