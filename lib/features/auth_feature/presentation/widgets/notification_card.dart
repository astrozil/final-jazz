import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/core/dependency_injection.dart';
import 'package:jazz/core/widgets/build_handle_bar.dart';
import 'package:jazz/core/widgets/confirm_widget.dart';
import 'package:jazz/core/widgets/custom_snack_bar.dart';
import 'package:jazz/features/auth_feature/domain/entities/notification.dart' as noti;
import 'package:jazz/features/auth_feature/presentation/bloc/notification_bloc/notification_bloc.dart';
import 'package:jazz/features/auth_feature/presentation/screens/email_change_screen.dart';

class NotificationCard extends StatelessWidget {
  final noti.Notification notification;
  final VoidCallback onTap;

  const NotificationCard({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondaryBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unread indicator
                  if (!notification.isRead)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, right: 12.0),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: (){

                              showModalBottomSheet(
                                  context: context,
                                  backgroundColor: AppColors.modalBackgroundColor,
                                  builder: (context){
                                return SizedBox(

                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                     Center(child: buildHandleBar()),
                                     SizedBox(height: 16.h,),
                                     Padding(
                                       padding: const EdgeInsets.all(16.0),
                                       child: GestureDetector(
                                         onTap:(){
                                           Navigator.pop(context);
                                       showDialog(context: context, builder: (context){
                                         return confirmWidget(
                                             context: context,
                                             confirmButton: ElevatedButton(
                                                 style: ElevatedButton.styleFrom(
                                                   backgroundColor: Colors.red
                                                 ),
                                                 onPressed: (){
                                               context.read<NotificationBloc>().add(DeleteNotification(notificationId: notification.id));
                                               Navigator.pop(context);
                                               ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar.show(message: "Notification has been deleted."));
                                             }, child: Text("Delete",style: TextStyle(color: Colors.white),)),
                                            title: "Delete notification?", text: "This notification will be permanently deleted.");
                                       })     ;
                                    },
                                         child: Row(
                                           children: [
                                             Image.asset("assets/icons/delete.png",height: 30.h,width: 30.w,color: Colors.red,  ),
                                              SizedBox(width: 10.w,),
                                             Text("Delete this notification", style: TextStyle(color: Colors.white),),
                                           ],
                                         ),
                                       ),
                                     ),

                                      SizedBox(height: 30.h,)
                                    ],
                                  ),
                                );
                              });
                              },
                              child: Icon(Icons.more_horiz_outlined,color: Colors.white,),
                            )
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          notification.body,
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 14,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatDate(notification.createdAt),
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
