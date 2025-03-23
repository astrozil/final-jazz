import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';

class SetNameScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();

  SetNameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
     if(state is UserDataUpdated){
       Navigator.pushNamed(context, Routes.setFavouriteArtistsScreen);
     }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Enter Your Name")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String name = nameController.text;
                  // Dispatch event to update the user's name
                  context.read<AuthBloc>().add(
                      UpdateUserProfileEvent(name: name));
                  // After update, navigate to the Favourite Artists Screen

                },
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
