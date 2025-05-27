import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/friend_request_bloc/friend_request_bloc.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/search_users_bloc/search_users_bloc.dart';
import 'package:lottie/lottie.dart';

class UserSearchScreen extends StatefulWidget {
  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  @override
  void initState() {
   context.read<FriendRequestBloc>().add(GetAllRequestsEvent());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: GestureDetector(
                onTap: (){
                  Navigator.pop(context);

                },
                child: Icon(Icons.arrow_back_ios_new_outlined,color: Colors.white,),
              ),
              backgroundColor: AppColors.primaryBackgroundColor,
              pinned: true,
              expandedHeight: 120.0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('Search Users', style: TextStyle(color: Colors.black)),
                background: Container(color: AppColors.primaryBackgroundColor),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    onChanged: (query) => context.read<SearchUsersBloc>().add(SearchQueryChanged(query)),
                  ),
                ),
              ),
            ),
            // Use BlocBuilder directly as a sliver
            BlocBuilder<SearchUsersBloc, SearchUsersState>(
              builder: (context, state) {
                if (state is SearchUsersLoading) {
                  return SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white,)
                    ),
                  );
                } else if (state is SearchUsersLoading) {
                  return SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white,)
                    ),
                  );
                } else if (state is SearchUsersSuccess) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final user = state.users[index];
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBackgroundColor,
                            borderRadius: BorderRadius.circular(12),

                          ),
                          child: ListTile(
                            leading: Hero(

                              tag: 'user_avatar_${user.id}',
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage: user.profilePictureUrl != null
                                    ? NetworkImage(user.profilePictureUrl!)
                                    : null,
                                child: user.profilePictureUrl == null
                                    ? Text(user.name[0].toUpperCase())
                                    : null,
                              ),
                            ),
                            title: Text(user.name, style: TextStyle(color: Colors.white)),


                            trailing: BlocBuilder<FriendRequestBloc, FriendRequestState>(
                              builder: (context, friendRequestState) {
                                // Debug print should be removed in production code


                                if (friendRequestState is AllFriendRequestsLoaded) {
                                  final requests = friendRequestState.requests;
                                  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

                                  // Logic error: If requests is empty, this loop won't execute and no UI will be returned
                                  if (requests.isEmpty) {
                                    return ElevatedButton(
                                     style: ElevatedButton.styleFrom(
                                       backgroundColor: Colors.white
                                     ),
                                      onPressed: () {
                                        context.read<FriendRequestBloc>().add(SendFriendRequestEvent(user.id));
                                      },
                                      child: const Text("Send Request",style: TextStyle(color: Colors.black),),
                                    );
                                  }

                                  // Check for existing relationship
                                  for (var request in requests) {
                                    // Case 1: Current user sent a pending request to this user
                                    if (request.senderId == currentUserId &&
                                        request.receiverId == user.id &&
                                        request.status == "pending") {
                                      return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),),
                                        ),
                                        onPressed: () {
                                          // Add cancel request functionality
                                         context.read<FriendRequestBloc>().add(CancelSentFriendRequestEvent(request.id));
                                        },
                                        child: const Text("Cancel Request",style: TextStyle(color: Colors.black),),
                                      );
                                    }
                                    // Case 2: This user sent a pending request to current user
                                    else if (request.senderId == user.id &&
                                        request.receiverId == currentUserId &&
                                        request.status == "pending") {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),),
                                            ),
                                            onPressed: () {
                                              // Add confirm request functionality
                                              context.read<FriendRequestBloc>().add(AcceptFriendRequestEvent(request.id));
                                            },
                                            child: const Text("Confirm",style: TextStyle(color: Colors.black),),
                                          ),
                                          const SizedBox(width: 8), // Add spacing between buttons
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),),
                                            ),
                                            onPressed: () {
                                              // Add reject request functionality
                                              context.read<FriendRequestBloc>().add(RejectFriendRequestEvent(request.id));
                                            },
                                            child: const Text("Reject",style: TextStyle(color: Colors.black),),
                                          ),
                                        ],
                                      );
                                    }
                                    // Case 3: Users are already friends
                                    else if (((request.senderId == user.id && request.receiverId == currentUserId) ||
                                        (request.senderId == currentUserId && request.receiverId == user.id)) &&
                                        request.status == "accepted") {
                                      return const Text("Friend",style: TextStyle(color: Colors.white),);
                                    }
                                    // Case 4: Request was rejected
                                    else if (
                                        (request.senderId == currentUserId && request.receiverId == user.id) &&
                                        request.status == "rejected") { // Fixed typo: "reject" -> "rejected"
                                      return const SizedBox();

                                    }
                                  }

                                  // If no relationship found after checking all requests
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),),
                                      ),
                                      onPressed: () {
                                    
                                        context.read<FriendRequestBloc>().add(SendFriendRequestEvent(user.id));
                                      },
                                      child: const Text("Send Request",style: TextStyle(color: Colors.black),),
                                    ),
                                  );
                                }else if(friendRequestState is FriendRequestError
                                ){
                                  print(friendRequestState.message);
                                }

                                // Default state when friend requests aren't loaded yet
                                return const SizedBox();
                              },
                            )

                          ),
                        );
                      },
                      childCount: state.users.length,
                    ),
                  );
                } else if (state is SearchFailure) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.network(
                            'https://assets9.lottiefiles.com/packages/lf20_kcsr6fcp.json',
                            width: 200,
                            height: 200,
                          ),
                          SizedBox(height: 16),
                          Text('Error: ${state.error}', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  );
                }
                return SliverToBoxAdapter(child: Container());
              },
            ),
          ],
        ),
      ),
    );
  }
}
