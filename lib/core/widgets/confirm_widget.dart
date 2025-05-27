import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/notification_bloc/notification_bloc.dart';

/// Usage:
/// showDialog(
///   context: context,
///   builder: (_) => confirmWidget(
///     context: context,
///     title: 'Log out',
///     text: 'Are you sure you want to log out?',
///     onConfirmed: () {
///       // your logout logic here
///     },
///   ),
/// );

Widget confirmWidget({
  required BuildContext context,

  required String title,
  required String text,
  required ElevatedButton confirmButton,
}) {
  return Dialog(
    backgroundColor: Color.fromRGBO(36,35,41, 1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min
        ,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(title,style: TextStyle(color: Colors.white,fontSize: 20.sp),),
          ),
          Text(text,style: TextStyle(color: Colors.white.withOpacity(0.5)),),
          SizedBox(height: 10.h,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Text("Cancel",style: TextStyle(color: Colors.white.withOpacity(0.7)),)),
            SizedBox(width: 20.w,),
            confirmButton
          ],)


        ],
      ),
    )
  );
}
