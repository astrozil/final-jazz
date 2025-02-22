import 'package:flutter/material.dart';
import 'package:jazz/features/download_feature/domain/entities/download_request.dart';

class DownloadWidget extends StatelessWidget {
  final DownloadRequest downloadRequest;
  final String status;
  const DownloadWidget({super.key,required this.downloadRequest,required this.status});

  @override
  Widget build(BuildContext context) {
     return ListTile(
       leading: ClipRRect(
           child: Image(image: NetworkImage(downloadRequest.thumbnail)),
         borderRadius: BorderRadius.circular(5),
       ),
       title: Text(downloadRequest.title),
       subtitle: Text(status,),
     );
  }
}
