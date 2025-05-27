import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/features/download_feature/domain/entities/downloadedSong.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';

class RelatedSongScreen extends StatefulWidget {
  const RelatedSongScreen({super.key});

  @override
  State<RelatedSongScreen> createState() => _RelatedSongScreenState();
}

class _RelatedSongScreenState extends State<RelatedSongScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _upNextHeaderKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Scroll to Up Next section after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToUpNextSection();
    });
  }

  void _scrollToUpNextSection() {
    if (_upNextHeaderKey.currentContext != null) {
      Scrollable.ensureVisible(
        _upNextHeaderKey.currentContext!,
        alignment: 0.3, // Position near middle of screen
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24.r),
          onPressed: () => Navigator.pop(context),
        ),

        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background gradient


          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
              child: BlocBuilder<PlayerBloc, Player>(
                builder: (context, state) {
                  if (state is PlayerState && state.currentSong != null) {
                    return state.currentSong!.fold(
                            (song) {
                          return state.relatedSongs.history.fold(
                                  (relatedSongs) {
                                return _buildOnlineContent(context, relatedSongs, song);
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
                                return _buildDownloadedContent(context, downloadedSongs, downloadedSong);
                              }
                          );
                        }
                    );
                  }
                  return _buildEmptyState();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineContent(BuildContext context, List<RelatedSong> relatedSongs, Song currentSong) {
    if (relatedSongs.isEmpty) {
      return _buildEmptyState();
    }

    // Find current song index
    int currentIndex = relatedSongs.indexWhere((relatedSong) => relatedSong.song.id == currentSong.id);
    if (currentIndex == -1) currentIndex = 0;

    // Split into previous and upcoming songs (previous songs in chronological order)
    List<RelatedSong> previousSongs = currentIndex > 0
        ? relatedSongs.sublist(0, currentIndex).toList()
        : [];

    RelatedSong currentRelatedSong = relatedSongs[currentIndex];

    List<RelatedSong> upcomingSongs = currentIndex < relatedSongs.length - 1
        ? relatedSongs.sublist(currentIndex + 1)
        : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current song - fixed at top, not scrollable
        _buildCurrentSongTile(context, currentRelatedSong.song, true),

        // Scrollable area for previous and upcoming songs
        Expanded(
          child: ListView(
            controller: _scrollController,
            // Improved physics for smoother scrolling
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            // Larger cache for smooth scrolling
            cacheExtent: 500,
            children: [
              // Previously played songs
              if (previousSongs.isNotEmpty) ...[
                SizedBox(height: 20.r),
                Text(
                  "Previously Played",
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.r),
                // Using List.generate instead of nested ListView.builder
                ...List.generate(
                  previousSongs.length,
                      (index) {
                    Song song = previousSongs[index].song;
                    return _buildSongTile(
                      context,
                      song,
                      true,
                      false,
                          () => context.read<PlayerBloc>().add(
                          PlayChosenSongEvent(chosenIndex: index)
                      ),
                      true,
                    );
                  },
                ),
              ],

              // Upcoming songs
              if (upcomingSongs.isNotEmpty) ...[
                SizedBox(height: 20.r),
                Text(
                  "Up Next",
                  key: _upNextHeaderKey, // Key for scrolling
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.r),
                ...List.generate(
                  upcomingSongs.length,
                      (index) {
                    Song song = upcomingSongs[index].song;
                    int originalIndex = currentIndex + 1 + index;
                    return _buildSongTile(
                      context,
                      song,
                      false,
                      false,
                          () => context.read<PlayerBloc>().add(
                          PlayChosenSongEvent(chosenIndex: originalIndex)
                      ),
                      true,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadedContent(BuildContext context, List<DownloadedSong> downloadedSongs, DownloadedSong currentSong) {
    if (downloadedSongs.isEmpty) {
      return _buildEmptyState();
    }

    // Find current song index
    int currentIndex = downloadedSongs.indexWhere((song) => song.songFile == currentSong.songFile);
    if (currentIndex == -1) currentIndex = 0;

    // Split into previous and upcoming songs
    List<DownloadedSong> previousSongs = currentIndex > 0
        ? downloadedSongs.sublist(0, currentIndex).toList()
        : [];

    List<DownloadedSong> upcomingSongs = currentIndex < downloadedSongs.length - 1
        ? downloadedSongs.sublist(currentIndex + 1)
        : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current song - fixed at top, not scrollable
        _buildCurrentSongTile(context, currentSong, false),

        // Scrollable area for previous and upcoming songs
        Expanded(
          child: ListView(
            controller: _scrollController,
            // Improved physics for smoother scrolling
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            // Larger cache for smooth scrolling
            cacheExtent: 500,
            children: [
              // Previously played songs
              if (previousSongs.isNotEmpty) ...[
                SizedBox(height: 20.r),
                Text(
                  "Previously Played",
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.r),
                ...List.generate(
                  previousSongs.length,
                      (index) {
                    DownloadedSong song = previousSongs[index];
                    return _buildSongTile(
                      context,
                      song,
                      true,
                      false,
                          () => context.read<PlayerBloc>().add(
                          PlayChosenSongEvent(chosenIndex: index)
                      ),
                      false,
                    );
                  },
                ),
              ],

              // Upcoming songs
              if (upcomingSongs.isNotEmpty) ...[
                SizedBox(height: 20.r),
                Text(
                  "Up Next",
                  key: _upNextHeaderKey, // Key for scrolling
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.r),
                ...List.generate(
                  upcomingSongs.length,
                      (index) {
                    DownloadedSong song = upcomingSongs[index];
                    int originalIndex = currentIndex + 1 + index;
                    return _buildSongTile(
                      context,
                      song,
                      false,
                      false,
                          () => context.read<PlayerBloc>().add(
                          PlayChosenSongEvent(chosenIndex: originalIndex)
                      ),
                      false,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentSongTile(BuildContext context, dynamic song, bool isOnline) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: AppColors.secondaryBackgroundColor,
      ),
      child: Padding(
        padding: EdgeInsets.all(8.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: isOnline
                      ? Image.network(
                    (song as Song).thumbnails.defaultThumbnail.url,
                    width: 80.r,
                    height: 80.r,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80.r,
                        height: 80.r,
                        color: Colors.grey[800],
                        child: Icon(Icons.music_note, color: Colors.white, size: 40.r),
                      );
                    },
                  )
                      : ((song as DownloadedSong).image != null
                      ? Image.memory(
                    song.image!,
                    width: 80.r,
                    height: 80.r,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    width: 80.r,
                    height: 80.r,
                    color: Colors.grey[800],
                    child: Icon(Icons.music_note, color: Colors.white, size: 40.r),
                  )),
                ),
                SizedBox(width: 16.r),
                // Song info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOnline
                            ? (song as Song).title
                            : ((song as DownloadedSong).songName ?? "Unknown Song"),
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.r),
                      Text(
                        isOnline
                            ? (song as Song).artists.map((a) => a['name']).join(", ")
                            : ((song as DownloadedSong).artist ?? "Unknown Artist"),
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongTile(
      BuildContext context,
      dynamic song,
      bool isPreviousSong,
      bool isCurrentSong,
      VoidCallback onTap,
      bool isOnline,
      ) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: InkWell(

        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.r),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: isOnline
                  ? Opacity(
                opacity: isPreviousSong? 0.5: 1,
                    child: Image.network(
                                    (song as Song).thumbnails.defaultThumbnail.url,
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
                  )
                  : ((song as DownloadedSong).image != null
                  ? Opacity(
                opacity: isPreviousSong?0.5: 1.0,
                    child: Image.memory(
                                    song.image!,
                                    width: 56.r,
                                    height: 56.r,
                                    fit: BoxFit.cover,
                                  ),
                  )
                  : Container(
                width: 56.r,
                height: 56.r,
                color: Colors.white,
                child: Icon(Icons.music_note, color: Colors.white, size: 30.r),
              )),
            ),
            title: Opacity(
              opacity: isPreviousSong? 0.5: 1.0,
              child: Text(
                isOnline
                    ? (song as Song).title
                    : ((song as DownloadedSong).songName ?? "Unknown Song"),
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            subtitle: Opacity(
              opacity: isPreviousSong?0.5:1.0,
              child: Text(
                isOnline
                    ? (song as Song).artists.map((a) => a['name']).join(", ")
                    : ((song as DownloadedSong).artist ?? "Unknown Artist"),
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
      ),
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
