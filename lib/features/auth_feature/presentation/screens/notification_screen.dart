import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/notification_bloc/notification_bloc.dart';
import 'package:jazz/features/auth_feature/presentation/widgets/notification_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final Set<int> _selectedNotifications = {};

  @override
  void initState() {
    context.read<NotificationBloc>().add(GetUserNotificationsEvent());
    super.initState();
  }



  void _deleteNotification(dynamic id) {
    final intId = id is String ? int.parse(id) : id as int;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<NotificationBloc>().add(DeleteNotification(notificationId: id));
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Notifications',
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
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                // Convert to int for comparison if needed

                final isSelected = _selectedNotifications.contains(notification.id);

                return GestureDetector(

                  onTap: () {


                      context.read<NotificationBloc>().add(
                        MarkNotificationAsReadEvent(notification.id),
                      );

                      if (notification.type == 'friend_request') {
                        Navigator.pushNamed(context, Routes.friendRequestsScreen);
                      } else if (notification.type == 'request_accepted') {
                        // Navigate to user profile or friends list
                      }

                  },
                  child: Container(
                    color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
                    child: NotificationCard(
                      notification: notification,
                      onTap: () {

                      },
                    ),
                  ),
                );
              },
            );
          } else if (state is NotificationError) {
            return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.white),
                )
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
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.notifications_none_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'No notifications yet',
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
