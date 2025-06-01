import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';

class CollapsedCurrentSong extends StatelessWidget {
  const CollapsedCurrentSong({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<PlayerBloc, Player>(
        builder: (context, state) {
          if (state is PlayerState && state.currentSong != null) {
            return Container(


              decoration: BoxDecoration(
                color: AppColors.primaryBackgroundColor,
                border: Border(bottom: BorderSide(color: Colors.grey,width: 0.1)),


              ),
              child: state.currentSong!.fold(
                    (song) => _buildSongTile(context, song, state),
                    (downloadedSong) => _buildDownloadedSongTile(context, downloadedSong, state),
              ),
            );
          }
          return const SizedBox();
        }
    );
  }

  Widget _buildSongTile(BuildContext context, Song song, PlayerState state) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          // Thumbnail with rounded corners
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              song.thumbnails.defaultThumbnail.url,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 50,
                height: 50,
                color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                child: Icon(Icons.music_note,
                    color: isDarkMode ? Colors.grey[600] : Colors.grey[400]),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Song title and artist with ellipsis for overflow
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (song.artists.isNotEmpty)
                  Text(
                    song.artists.map((artist) => artist['name']).join(', '),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Playback controls
          Row(
            children: [
              _buildControlButton(
                context,
                CupertinoIcons.backward_end,
                    () => context.read<PlayerBloc>().add(PlayPreviousEvent()),
              ),
              const SizedBox(width: 8),
              _buildPlayPauseButton(context, state),
              const SizedBox(width: 8),
              _buildControlButton(
                context,
                CupertinoIcons.forward_end,
                    () => context.read<PlayerBloc>().add(PlayNextSongEvent()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadedSongTile(BuildContext context, downloadedSong, PlayerState state) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          // Thumbnail with rounded corners
          Container(
            width: 50.w,
            height: 50.h,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: OverflowBox(
              alignment: Alignment.center,
              maxWidth: 100
                  .w, // 20% wider than container (adjust for crop amount)
              maxHeight: 100.h, // 20% taller than container
              child: Image.memory(
                scale: 0.1,
                downloadedSong.image!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Song title and artist
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  downloadedSong.songName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  downloadedSong.artist,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7)
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Playback controls
          Row(
            children: [
              _buildControlButton(
                context,
                CupertinoIcons.backward_end,
                    () => context.read<PlayerBloc>().add(PlayPreviousEvent()),
              ),
              const SizedBox(width: 8),
              _buildPlayPauseButton(context, state),
              const SizedBox(width: 8),
              _buildControlButton(
                context,
                CupertinoIcons.forward_end,
                    () => context.read<PlayerBloc>().add(PlayNextSongEvent()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(BuildContext context, IconData icon, VoidCallback onPressed) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 18,
            color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildPlayPauseButton(BuildContext context, PlayerState state) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:  Colors.white,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          state.isPlaying
              ? CupertinoIcons.pause_fill
              : CupertinoIcons.play_fill,
          size: 20,
          color: Colors.black,
        ),
        onPressed: () {
          if (state.isPlaying) {
            context.read<PlayerBloc>().add(PausePlayerEvent());
          } else {
            context.read<PlayerBloc>().add(ResumePlayerEvent());
          }
        },
      ),
    );
  }
}
