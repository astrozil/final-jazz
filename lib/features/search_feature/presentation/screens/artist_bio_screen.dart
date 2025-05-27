import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/app_color.dart';

class ArtistBioScreen extends StatelessWidget {
  final String bio;
  const ArtistBioScreen({super.key,required this.bio});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackgroundColor,
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_new_outlined,color: Colors.white,),

        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Biography",style: TextStyle(color: Colors.white,fontSize: 25.sp),),
            SizedBox(height: 16.h,),
            bio != ""?
            Text(bio,style: TextStyle(color: Colors.white.withOpacity(0.6),fontSize: 18.sp),):
                Text("Artist Biography not found.",style: TextStyle(color: Colors.white.withOpacity(0.6),fontSize: 18.sp))
          ],
        ),
      ),
    );
  }
}
