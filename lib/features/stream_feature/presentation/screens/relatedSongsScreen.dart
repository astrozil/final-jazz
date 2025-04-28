import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jazz/features/download_feature/domain/entities/downloadedSong.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';

class RelatedSongScreen extends StatelessWidget {
  const RelatedSongScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24.r),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Up Next",
          style: GoogleFonts.poppins(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.9),
                  Colors.black,
                ],
                stops: const [0.0, 0.3, 0.7],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header text


                  // Song list
                  Expanded(
                    child: BlocBuilder<PlayerBloc, Player>(
                        builder: (context, state) {
                          if (state is PlayerState) {
                            if (state.currentSong != null) {
                              return state.currentSong!.fold(
                                      (song) {
                                    return state.relatedSongs.history.fold(
                                            (relatedSongs) {
                                          return _buildOnlineSongsList(context, relatedSongs, song);
                                        },
                                            (downloadedSongs) {
                                          return _buildEmptyState();
                                        }
                                    );
                                  },
                                      (downloadedSong) {
                                    return state.relatedSongs.history.fold(
                                            (relatedSongs) {
                                          return _buildEmptyState();
                                        },
                                            (downloadedSongs) {
                                          return _buildDownloadedSongsList(context, downloadedSongs, downloadedSong);
                                        }
                                    );
                                  }
                              );
                            }
                          }
                          return _buildEmptyState();
                        }
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineSongsList(BuildContext context, List<RelatedSong> relatedSongs, Song currentSong) {
    if (relatedSongs.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: relatedSongs.length,
        itemBuilder: (context, index) {
          Song relatedSong = relatedSongs[index].song;
          bool isCurrentSong = relatedSong.id == currentSong.id;

          return Container(
            margin: EdgeInsets.symmetric(vertical: 6.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: isCurrentSong
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
            ),
            child: InkWell(
              onTap: () {
                context.read<PlayerBloc>().add(
                    PlayChosenSongEvent(chosenIndex: index)
                );
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.r),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      relatedSong.thumbnails.defaultThumbnail.url,
                      width: 56.r,
                      height: 56.r,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 56.r,
                          height: 56.r,
                          color: Colors.grey[800],
                          child: Icon(Icons.music_note, color: Colors.white, size: 30.r),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    relatedSong.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    relatedSong.artists.map((a) => a['name']).join(", "),
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                ),
              ),
            ),
          );
        }
    );
  }

  Widget _buildDownloadedSongsList(BuildContext context, List<DownloadedSong> downloadedSongs, DownloadedSong currentSong) {
    if (downloadedSongs.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: downloadedSongs.length,
        itemBuilder: (context, index) {
          DownloadedSong songDownloaded = downloadedSongs[index];
          bool isCurrentSong = songDownloaded.songFile == currentSong.songFile;

          return Container(
            margin: EdgeInsets.symmetric(vertical: 6.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: isCurrentSong
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
            ),
            child: InkWell(
              onTap: () {
                context.read<PlayerBloc>().add(
                    PlayChosenSongEvent(chosenIndex: index)
                );
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.r),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: songDownloaded.image != null
                        ? Image.memory(
                      songDownloaded.image!,
                      width: 56.r,
                      height: 56.r,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      width: 56.r,
                      height: 56.r,
                      color: Colors.grey[800],
                      child: Icon(Icons.music_note, color: Colors.white, size: 30.r),
                    ),
                  ),
                  title: Text(
                    songDownloaded.songName ?? "Unknown Song",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    songDownloaded.artist ?? "Unknown Artist",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                ),
              ),
            ),
          );
        }
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.queue_music,
            size: 80.r,
            color: Colors.white.withOpacity(0.3),
          ),
          SizedBox(height: 16.r),
          Text(
            "No upcoming songs",
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.r),
          Text(
            "Add songs to your queue to see them here",
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
