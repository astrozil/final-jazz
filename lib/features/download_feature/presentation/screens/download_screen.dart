import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/core/dependency_injection.dart';
import 'package:jazz/features/download_feature/domain/entities/download_request.dart';
import 'package:jazz/features/download_feature/presentation/bloc/download/download_bloc.dart';
import 'package:jazz/features/download_feature/presentation/widgets/current_download_widget.dart';
import 'package:jazz/features/download_feature/presentation/widgets/download_widget.dart';

class DownloadScreen extends StatelessWidget {
  const DownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Download queue',
          style: TextStyle(
            color: Colors.white,

            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<DownloadBloc, DownloadState>(
        builder: (context, state) {
          if (state is DownloadOnProgress) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with item count
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '${state.downloadRequestList.length + 1} items',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Current downloading item with progress
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildDownloadItemWithProgress(
                    state.downloadRequest,
                    state.progress,
                    true,
                    context,
                  ),
                ),

                // Queue list
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.downloadRequestList.length,
                    itemBuilder: (context, index) {
                      final downloadRequest = state.downloadRequestList[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        child: _buildDownloadItemWithProgress(
                          downloadRequest,
                          0.0,
                          false,
                          context,
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          } else if (state is DownloadPaused) {

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with item count
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '${state.downloadRequestList.length + 1} items',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Current paused item
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildDownloadItemWithProgress(
                    state.downloadRequest,
                    0.0,
                    false,
                    context,
                    isPaused: true,
                  ),
                ),

                // Queue list
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.downloadRequestList.length,
                    itemBuilder: (context, index) {
                      final downloadRequest = state.downloadRequestList[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        child: _buildDownloadItemWithProgress(
                          downloadRequest,
                          0.0,
                          false,
                          context,
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          } else if (state is DownloadFinished) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with item count
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '${state.downloadRequestList.length} items',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Queue list
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.downloadRequestList.length,
                    itemBuilder: (context, index) {
                      final downloadRequest = state.downloadRequestList[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        child: _buildDownloadItemWithProgress(
                          downloadRequest,
                          0.0,
                          false,
                          context,
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          }
          return Container(
            color: AppColors.primaryBackgroundColor,
            child: Center(
              child: Text(
                'No downloads',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDownloadItemWithProgress(
      DownloadRequest downloadRequest,
      double progress,
      bool isDownloading,
      BuildContext context, {
        bool isPaused = false,
      }) {
    return GestureDetector(
      onTap: () {
        // Delete download when tapped
        context.read<DownloadBloc>().add(DeleteDownloadEvent(downloadRequest.videoID));
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Album artwork placeholder
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  downloadRequest.thumbnail ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: Icon(
                        Icons.music_note,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(width: 12),

            // Song details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    downloadRequest.title ?? 'Unknown Title',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    downloadRequest.artist ?? 'Unknown Artist',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Circular progress or status icon
            Container(
              width: 32,
              height: 32,
              child: _getStatusWidget(isDownloading, isPaused, progress),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getStatusWidget(bool isDownloading, bool isPaused, double progress) {
    if (isDownloading) {
      return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey[700],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.stop,
              color: Colors.white,
              size: 12,
            ),
          ),
        ],
      );
    } else {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey[700],
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.download,
          color: Colors.grey[400],
          size: 16,
        ),
      );
    }
  }
}