import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/features/download_feature/domain/entities/downloadedSong.dart';
import 'package:jazz/features/download_feature/presentation/bloc/download/download_bloc.dart';
import 'package:jazz/features/download_feature/presentation/bloc/downloadedSongsBloc/downloaded_songs_bloc.dart';
import 'package:jazz/features/download_feature/presentation/screens/download_screen.dart';
import 'package:jazz/features/stream_feature/domain/entities/songHistory.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/widgets/custom_snack_bar.dart';
import '../bloc/DownloadedOrNotBloc/downloaded_or_not_bloc.dart';

class DownloadedSongsScreen extends StatelessWidget {
  const DownloadedSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackgroundColor,
        title: Text("Downloaded tracks",style: TextStyle(color: Colors.white),),automaticallyImplyLeading: false,leading: GestureDetector(
        onTap: (){
          Navigator.pop(context);
        },
        child: Icon(Icons.arrow_back_ios_new_outlined,color: Colors.white,),
      ),),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16,vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBackgroundColor,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: ListTile(
                      title: Text("Download Queue",style: TextStyle(color: Colors.white),),
                      trailing: GestureDetector(
                        onTap: (){
                         Navigator.pushNamed(context, Routes.downloadQueueScreen);
                        },
                        child: Icon(Icons.arrow_forward_ios_outlined,color: Colors.grey,),
                      ),
                    ),
                  ),
            BlocBuilder<DownloadedSongsBloc,DownloadedSongsState>(
                builder: (context,state){
                  if(state is GettingDownloadedSongsState){
                    return Center (child: CircularProgressIndicator(color: Colors.white,),);
                  }
              else if(state is GotDownloadedSongsState){
                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                    itemCount: state.downloadedSongs.length,
                    itemBuilder: (context,index){
                    DownloadedSong downloadedSong = state.downloadedSongs[index];
                    Uint8List? image = downloadedSong.image;
                    return GestureDetector(
                      onTap: ()async{
                        context.read<PlayerBloc>() .add(PlaySongEvent(song:right(downloadedSong)));
        
                    await Future.delayed(const Duration(seconds: 1),(){
                     if(context.mounted) context.read<PlayerBloc>().add(UpdateStateEvent(state: context.read<PlayerBloc>().state.copyWith(relatedSongs: SongHistory(history: right(state.downloadedSongs)),currentSongIndex: index)));
                    });
        
                      },
                      child: ListTile(
                        title: Text(downloadedSong.album,style: TextStyle(color: Colors.white),),
        
                      subtitle: Text(downloadedSong.artist,style: TextStyle(color: Colors.white.withOpacity(0.7)),),
                      leading: image != null ?  Container(
                        width: 60.w,
                        height: 60.h,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
        
                        ),
                        child: OverflowBox(
                          alignment: Alignment.center,
                          maxWidth: 120
                              .w, // 20% wider than container (adjust for crop amount)
                          maxHeight: 120.h, // 20% taller than container
                          child: Image.memory(
                            scale: 0.1,
                            downloadedSong.image!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ) : const Icon(Icons.music_note) ,
                        trailing: GestureDetector(
                          onTap: (){
                           showModalBottomSheet(
                               context: context,
        
                               enableDrag: true,
        
                               backgroundColor: Color.fromRGBO(
                                   37, 39, 40, 1),
                               shape: RoundedRectangleBorder(
                                   borderRadius:
                                   BorderRadius.vertical(
                                       top:
                                       Radius.circular(
                                           20))),
                               builder: (context){
                                 return Column(
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     Padding(
                                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                       child: Row(
        
                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                         children: [
                                           SizedBox(width: 80.w,),
                                           Container(
                                             margin: const EdgeInsets.only(top: 8),
                                             height: 4,
                                             width: 40,
                                             decoration: BoxDecoration(
                                               color: Colors.grey[300],
                                               borderRadius: BorderRadius.circular(2),
                                             ),
                                           ),
                                           TextButton(
                                             onPressed: () {
                                               Navigator.pop(context);
                                             },
                                             child:  Text('Cancel',style: TextStyle(color: Colors.white.withOpacity(0.8)),),
                                           ),
                                         ],
                                       ),
                                     ),
                                     SizedBox(height: 30.h,),
                                     Padding(
                                       padding: const EdgeInsets.all(16.0),
                                       child: GestureDetector(
                                         onTap: (){
                                           Navigator.pop(context);

                                           context.read<DownloadedOrNotBloc>().add(DeleteDownloadedSongEvent(downloadedSong.id, downloadedSong.songName,downloadedSong.artist,path: downloadedSong.songSavedPath));
                                            context.read<DownloadedSongsBloc>().add(GetDownloadedSongsEvent());
                                           ScaffoldMessenger.of(context)
                                               .hideCurrentSnackBar();
                                           ScaffoldMessenger.of(context)
                                               .showSnackBar(CustomSnackBar.show(
                                               message:
                                               "Removed from downloaded content",
                                               backgroundColor: AppColors
                                                   .snackBarBackgroundColor));
                                         },
                                         child: Row(
                                           children: [
                                             Image.asset("assets/icons/delete.png",height: 30,width: 30,color: Colors.red,),
                                             SizedBox(width: 20.w,),
                                             Text("Remove from downloaded content", style: TextStyle(color: Colors.white, fontSize: 18.sp ),)
                                           ],
                                         ),
                                       ),
                                     ),
                                     SizedBox(height: 30.h,)
                                   ],
                                 );
                               });
                          },
                          child: Icon(Icons.more_horiz_outlined,color: Colors.white,),
                        ),
                      ),
                    );
                });
              }
              return Container(
                   width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center ,
                    children: [ Text("No Downloaded Song",style: TextStyle(color: Colors.white,fontSize: 22.sp),)]),
              );
            }),
          ],
        ),
      ),
    );
  }
}
