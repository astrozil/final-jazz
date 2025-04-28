import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/friend_request_bloc/friend_request_bloc.dart';
import 'package:jazz/features/auth_feature/presentation/widgets/friend_request_card.dart';
import 'package:jazz/features/auth_feature/presentation/widgets/sent_friend_request_card.dart';

class SentFriendRequestsScreen extends StatefulWidget {
  const SentFriendRequestsScreen({super.key});

  @override
  State<SentFriendRequestsScreen> createState() => _SentFriendRequestsScreenState();
}

class _SentFriendRequestsScreenState extends State<SentFriendRequestsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FriendRequestBloc>().add(GetSentFriendRequestsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Sent Requests',
          style: TextStyle(
            color: Colors.white,

            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<FriendRequestBloc, FriendRequestState>(
        builder: (context, state) {
          if (state is FriendRequestLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          } else if (state is SentFriendRequestsLoaded) {
            if (state.requests.isEmpty) {
              return _buildEmptyState();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: ListView.builder(
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  final request = state.requests[index];
                  return SentFriendRequestCard(
                      request: request,
                      onDelete: () {
                        context.read<FriendRequestBloc>().add(
                          CancelSentFriendRequestEvent(request.id),
                        );
                      }
                  );
                },
              ),
            );
          } else if (state is FriendRequestError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          return _buildEmptyState();
        },
      ),

    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.5), width: 2),
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.person_add_disabled_outlined,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'No pending friend requests sent\nThey\'ll appear here when you add friends',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
