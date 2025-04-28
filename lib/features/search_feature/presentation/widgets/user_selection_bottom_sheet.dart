import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/features/auth_feature/domain/entities/user.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/song_share_feature/domain/entities/shared_song.dart';
import 'package:jazz/features/song_share_feature/presentation/bloc/shared_song_bloc/shared_song_bloc.dart';


class UserSelectionBottomSheet extends StatefulWidget {
  final Song song;
  final Function(List<AppUser> selectedUsers)? onUsersSelected;

  const UserSelectionBottomSheet({
    Key? key,
    this.onUsersSelected,

    required this.song

  }) : super(key: key);

  @override
  _UserSelectionBottomSheetState createState() => _UserSelectionBottomSheetState();
}

class _UserSelectionBottomSheetState extends State<UserSelectionBottomSheet> {
  final Set<String> _selectedUserIds = {};
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  List<AppUser> _filteredUsers = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(GetFriendsEvent());
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
    });
  }

  List<AppUser> _getFilteredUsers(List<AppUser> users) {
    if (!_isSearching) return users;

    final query = _searchController.text.toLowerCase();
    return users.where((user) =>
    user.name.toLowerCase().contains(query) ||
        user.email.toLowerCase().contains(query)
    ).toList();
  }

  void _handleUserSelection(AppUser user, bool? isSelected) {
    setState(() {
      if (isSelected == true) {
        _selectedUserIds.add(user.id);
      } else {
        _selectedUserIds.remove(user.id);
      }
    });
  }

  void _confirmSelection(List<AppUser> allUsers) {
    final selectedUsers = allUsers
        .where((user) => _selectedUserIds.contains(user.id))
        .toList();

    if (widget.onUsersSelected != null) {
      widget.onUsersSelected!(selectedUsers);
    }
    for (var user in selectedUsers) {
      context.read<SharedSongBloc>().add(ShareSongEvent(SharedSong
        (id: "",
          senderId
          : FirebaseAuth.instance.currentUser!.uid,
          receiverId: user.id,
          songId: widget.song.id,
          songName: widget.song.title,
          artistName: widget.song.artists,
          albumArt: widget.song.thumbnails.highThumbnail.url,
          type: widget.song.category,
          message: _messageController.text,
          isViewed: false,
          createdAt: DateTime.now())));
      Navigator.pop(context, selectedUsers);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHandleBar(),
            _buildHeader(),
            _buildSearchBar(),
            _buildUserList(),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      height: 4,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
  Widget _buildMessageBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        maxLines: 3,
        controller: _messageController ,
        decoration: InputDecoration(
          hintText: 'Add a message (optional)...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.all(12),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text(
            'Select Users',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedUserIds.clear();
              });
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search users...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _isSearching
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is FriendsLoaded) {
          _filteredUsers = _getFilteredUsers(state.friends);

          if (_filteredUsers.isEmpty) {
            return Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_search, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      _isSearching
                          ? 'No users match your search'
                          : 'No friends found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                return _buildUserTile(_filteredUsers[index]);
              },
            ),
          );
        } else if (state is AuthFailure) {
          return Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load users',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(GetFriendsEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        return const Expanded(
          child: Center(
            child: Text('No users available'),
          ),
        );
      },
    );
  }

  Widget _buildUserTile(AppUser user) {
    return CheckboxListTile(
      title: Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(user.email),
      secondary: Hero(
        tag: 'user_avatar_${user.id}',
        child: CircleAvatar(
          backgroundImage: user.profilePictureUrl != null
              ? NetworkImage(user.profilePictureUrl!)
              : null,
          child: user.profilePictureUrl == null
              ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?')
              : null,
        ),
      ),
      value: _selectedUserIds.contains(user.id),
      onChanged: (bool? value) => _handleUserSelection(user, value),
      activeColor: Theme.of(context).primaryColor,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final bool isLoading = state is AuthLoading;
          final List<AppUser> allUsers = state is FriendsLoaded ? state.friends : [];

          return ElevatedButton(
            onPressed: isLoading || _selectedUserIds.isEmpty
                ? null
                : () => _confirmSelection(allUsers),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(
              'Confirm Selection (${_selectedUserIds.length})',
              style: const TextStyle(fontSize: 16),
            ),
          );
        },
      ),
    );
  }
}
