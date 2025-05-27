import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';

import '../../../playlist_feature/presentation/bloc/playlist_bloc/playlist_bloc.dart';

class UserPlaylistTitleUpdateScreen extends StatefulWidget {
  final String playlistTitle;
  final String playlistId;
  const UserPlaylistTitleUpdateScreen({super.key,required this.playlistTitle,required this.playlistId});

  @override
  State<UserPlaylistTitleUpdateScreen> createState() => _UserPlaylistTitleUpdateScreenState();
}

class _UserPlaylistTitleUpdateScreenState extends State<UserPlaylistTitleUpdateScreen> {
  final TextEditingController playlistNameController = TextEditingController();
  late FocusNode playlistNameFocusNode;
  bool isPlaylistNameValid = false;
  String? playlistNameError;

  @override
  void initState() {
    super.initState();
    playlistNameController.text = widget.playlistTitle;
    playlistNameFocusNode = FocusNode();
    playlistNameController.addListener(_validateName);
  }

  @override
  void dispose() {
    playlistNameController.removeListener(_validateName);
    playlistNameController.dispose();
    playlistNameFocusNode.dispose();
    super.dispose();
  }

  void _validateName() {
    setState(() {
      isPlaylistNameValid = playlistNameController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          // Show loading overlay
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
          playlistNameFocusNode.unfocus();
        } else if (state is UserDataUpdated) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Dismiss loading dialog
          }
          Navigator.pushNamed(context, Routes.setFavouriteArtistsScreen);
        } else if (state is AuthFailure) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Dismiss loading dialog
          }
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? "Failed to update profile"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(

        backgroundColor: AppColors.primaryBackgroundColor,

        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBackgroundColor,
          automaticallyImplyLeading: false,
          leadingWidth: 100.w,
          leading: TextButton(onPressed: (){

            Navigator.pop(context);
          }, child: Text("Cancel",style: TextStyle(color: Colors.white,fontSize: 20.sp),)),
          title: Text("Edit playlist title",style: TextStyle(color: Colors.white, fontSize: 20.sp),),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            // Album artwork grid background




            // Content
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(24.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [


                          SizedBox(height: 40.h),

                          // Name field
                          TextField(
                            focusNode: playlistNameFocusNode,
                            controller: playlistNameController,
                            style: TextStyle(color: Colors.white, fontSize: 16.sp),
                            decoration: InputDecoration(
                              hintText: "Enter your new playlist title",
                              hintStyle: TextStyle(fontSize: 16.sp),
                              labelStyle: TextStyle(color: Colors.white70, fontSize: 16.sp),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: BorderSide(color: Colors.white30),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              errorText: playlistNameError,
                              errorStyle: TextStyle(color: Colors.red, fontSize: 14.sp),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // Continue button
                          ElevatedButton(
                            onPressed: isPlaylistNameValid
                                ? () {
                              final name = playlistNameController.text.trim();
                              if (name.isEmpty) {
                                setState(() {
                                  playlistNameError = "Please enter your playlist title";
                                });
                              }else if(name == widget.playlistTitle){
                                null;
                              }
                              else {
                                Navigator.of(context).pop();
                                context.read<PlaylistBloc>().add(ChangePlaylistTitle(title: name, playlistId: widget.playlistId));
                                context.read<PlaylistBloc>().add(FetchPlaylist(playlistId: widget.playlistId));
                                context.read<PlaylistBloc>().add(FetchPlaylists());

                              }
                            }
                                : (){

                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPlaylistNameValid && playlistNameController.text != widget.playlistTitle ? Colors.white : Color.fromRGBO(49, 47, 52, 0.5),
                              foregroundColor: isPlaylistNameValid && playlistNameController.text != widget.playlistTitle  ? Colors.black : Colors.white.withOpacity(0.3),
                              splashFactory: NoSplash.splashFactory,
                              overlayColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              minimumSize: Size(double.infinity, 50.h),
                            ),
                            child: Text(
                              "Confirm",
                              style: TextStyle(fontSize: 16.sp),
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Skip option
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
