import 'package:flutter/material.dart';
import 'package:jazz/features/download_feature/domain/entities/download_request.dart';
import 'package:jazz/features/download_feature/presentation/bloc/download/download_bloc.dart';

class CurrentDownloadWidget extends StatelessWidget {
  final DownloadRequest downloadRequest;
  final String status;
  final Function(DownloadRequest) pauseDownload;
  final Function(DownloadRequest) resumeDownload;
  final Function(String) deleteDownload;
  const CurrentDownloadWidget({super.key,required this.downloadRequest,required this.status,required this.pauseDownload,required this.resumeDownload,required this.deleteDownload});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        child: Image(image: NetworkImage(downloadRequest.thumbnail)),
        borderRadius: BorderRadius.circular(5),
      ),
      title: Text(downloadRequest.title),
      subtitle: Row(children: [
        Text(status,),
        ElevatedButton(onPressed: (){
         pauseDownload(downloadRequest);
        }, child: Text("P")),
        ElevatedButton(onPressed: (){
   resumeDownload(downloadRequest);
        }, child: Text("R")),
        ElevatedButton(onPressed: (){
   deleteDownload(downloadRequest.videoID);
        }, child: Text("D")),
      ],),
    );
  }
}
