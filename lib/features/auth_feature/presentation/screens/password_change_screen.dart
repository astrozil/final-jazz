import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';

class PasswordChangeScreen extends StatefulWidget {
  @override
  _PasswordChangeScreenState createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                value!.isEmpty ? "Please enter your email" : null,
              ),
              const SizedBox(height: 12),

              // Old Password Field
              TextFormField(
                controller: _oldPasswordController,
                decoration: const InputDecoration(labelText: "Old Password"),
                obscureText: true,
                validator: (value) =>
                value!.isEmpty ? "Please enter your old password" : null,
              ),
              const SizedBox(height: 12),

              // New Password Field
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(labelText: "New Password"),
                obscureText: true,
                validator: (value) =>
                value!.length < 6 ? "Password must be at least 6 characters" : null,
              ),
              const SizedBox(height: 20),

              // Submit Button with Bloc
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is PasswordChanged) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Password changed successfully!")),
                    );
                    Navigator.pop(context); // Navigate back after success
                  } else if (state is AuthFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  return state is AuthLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                          ChangePasswordEvent(
                            email: _emailController.text.trim(),
                            oldPassword: _oldPasswordController.text.trim(),
                            newPassword: _newPasswordController.text.trim(),
                          ),
                        );
                      }
                    },
                    child: const Text("Change Password"),
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
