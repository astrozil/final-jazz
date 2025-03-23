// presentation/pages/auth_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';


class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Authentication")),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AuthSuccess) {
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              const SizedBox(height: 20),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const CircularProgressIndicator();
                  }
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(SignInEvent(
                                  email: emailController.text,
                                  password: passwordController.text));
                            },
                            child: const Text("Login"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(SignUpEvent(
                                  email: emailController.text,
                                  password: passwordController.text));
                            },
                            child: const Text("Sign Up"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(GoogleSignInEvent());
                        },
                        child: const Text("Sign In with Google"),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
