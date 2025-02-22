import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/core/dependency_injection.dart';
import 'package:jazz/features/download_feature/presentation/bloc/download/download_bloc.dart';
import 'package:jazz/features/download_feature/presentation/widgets/current_download_widget.dart';
import 'package:jazz/features/download_feature/presentation/widgets/download_widget.dart';

class DownloadScreen extends StatelessWidget {
  const DownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Download Screen'),
        ),
        body: BlocBuilder<DownloadBloc,DownloadState>(

                builder:(context,state){
                  if(state is DownloadOnProgress){
                return Column(
                  children: [

                      CurrentDownloadWidget(downloadRequest: state.downloadRequest,
                          status: "Downloading : ${state.progress.toStringAsFixed(2)}% ",
                         pauseDownload: (downloadRequest){
                        print(downloadRequest.alreadyDownloadedBytes);
                        context.read<DownloadBloc>().add(PauseDownloadEvent(downloadRequest));
                         },
                        resumeDownload: (downloadRequest){

                          context.read<DownloadBloc>().add(ResumeDownloadEvent(downloadRequest));
                        },
                        deleteDownload: (videoID){
                          context.read<DownloadBloc>().add(DeleteDownloadEvent(videoID));
                        },
                      ),

                     Expanded(
                       child: ListView.builder(
                           itemCount: state.downloadRequestList.length,
                           itemBuilder: (context,index){
                            final downloadRequest = state.downloadRequestList[index];
                            return DownloadWidget(downloadRequest: downloadRequest, status: "In Queue");
                       }),
                     )

                  ],
                );  }
                  else if (state is DownloadPaused){
                    print("Paused");
                    return Column(
                      children: [

                        CurrentDownloadWidget(downloadRequest: state.downloadRequest,
                          status: "Downloading paused ",
                          pauseDownload: (downloadRequest){
                            context.read<DownloadBloc>().add(PauseDownloadEvent(downloadRequest));
                          },
                          resumeDownload: (downloadRequest){
                            context.read<DownloadBloc>().add(ResumeDownloadEvent(downloadRequest));
                          },
                          deleteDownload: (videoID){
                            context.read<DownloadBloc>().add(DeleteDownloadEvent(videoID));
                          },
                        ),

                        Expanded(
                          child: ListView.builder(
                              itemCount: state.downloadRequestList.length,
                              itemBuilder: (context,index){
                                final downloadRequest = state.downloadRequestList[index];
                                return DownloadWidget(downloadRequest: downloadRequest, status: "In Queue");
                              }),
                        )

                      ],
                    );
                  }
                  else if (state is DownloadFinished){
                  return  ListView.builder(
                        itemCount: state.downloadRequestList.length,
                        itemBuilder: (context,index){
                          final downloadRequest = state.downloadRequestList[index];
                          return DownloadWidget(downloadRequest: downloadRequest, status: "In Queue");
                        });
                  }
                  return SizedBox();
                }),
      );
  }
}
