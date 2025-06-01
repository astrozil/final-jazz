import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/core/dependency_injection.dart';
import 'package:jazz/features/auth_feature/domain/entities/user.dart';
import 'package:jazz/features/song_share_feature/domain/entities/shared_song.dart';
import 'package:jazz/features/song_share_feature/presentation/bloc/shared_song_bloc/shared_song_bloc.dart';

import '../../../auth_feature/domain/repo/auth_repository.dart';
import '../../../search_feature/domain/entities/song.dart';
import '../../../search_feature/domain/entities/thumbnails.dart';
import '../../../stream_feature/presentation/bloc/playerBloc/player_bloc.dart';

class SharedSongsScreen extends StatefulWidget {
  const SharedSongsScreen({super.key});

  @override
  _SharedSongsScreenState createState() => _SharedSongsScreenState();
}

class _SharedSongsScreenState extends State<SharedSongsScreen> {
  final List<String> _tabs = ['Received', 'Sent'];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<SharedSongBloc>().add(GetReceivedSharedSongsEvent());
  }

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      context.read<SharedSongBloc>().add(GetReceivedSharedSongsEvent());
    } else {
      context.read<SharedSongBloc>().add(GetSentSharedSongsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.primaryBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.primaryBackgroundColor,
        middle: const Text(
          'Shared Songs',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildSegmentedControl(context),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CupertinoSlidingSegmentedControl<int>(
        groupValue: _selectedIndex,
        thumbColor: Colors.white,
        backgroundColor: Colors.grey.withOpacity(0.2),
        padding: const EdgeInsets.all(4),
        children: {
          0: _buildSegment('Received', 0),
          1: _buildSegment('Sent', 1),
        },
        onValueChanged: (value) => _onTabSelected(value!),
      ),
    );
  }

  Widget _buildSegment(String text, int index) {
    return Text(
      text,
      style: TextStyle(
        color: _selectedIndex == index ? Colors.black : Colors.white,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildContent() {
    return IndexedStack(
      index: _selectedIndex,
      children: const [
        ReceivedSongsTab(),
        SentSongsTab(),
      ],
    );
  }
}

class ReceivedSongsTab extends StatefulWidget {
  const ReceivedSongsTab({super.key});

  @override
  _ReceivedSongsTabState createState() => _ReceivedSongsTabState();
}

class _ReceivedSongsTabState extends State<ReceivedSongsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<SharedSongBloc, SharedSongState>(
      builder: (context, state) {
        if (state is SharedSongLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ReceivedSharedSongsLoaded) {
          return _buildSongList(state.sharedSongs);
        }
        return _buildEmptyState('No songs shared with you yet');
      },
    );
  }

  Widget _buildSongList(List<SharedSong> songs) {
    if (songs.isEmpty) {
      return _buildEmptyState('No songs shared with you yet');
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: songs.length,
      itemBuilder: (context, index) => SharedSongCard(
        sharedSong: songs[index],
        showSender: true,
        onTap: () {
          var sharedSong = songs[index];
          context.read<SharedSongBloc>().add(
            MarkSharedSongAsViewedEvent(songs[index].id),
          );
          final isFromAlbum = context.read<PlayerBloc>().state.isFromAlbum;
          if (isFromAlbum) {
            context.read<PlayerBloc>().add(
                UpdateStateEvent(state: context
                    .read<PlayerBloc>()
                    .state
                    .copyWith(isFromAlbum: false)));
          }
          context.read<PlayerBloc>().add(
              PlaySongEvent(song: dartz.left(Song(
                  url: "",
                  title: sharedSong.songName,
                  artists: sharedSong.artistName.split(","),
                  id: sharedSong.songId,
                  category: sharedSong.type,
                  browseId: "",
                  thumbnails: YtThumbnails(
                      defaultThumbnail: YtThumbnail(
                          url: sharedSong.albumArt,
                          width: 60,
                          height: 60),
                      mediumThumbnail: YtThumbnail(
                          url: sharedSong.albumArt,
                          width: 120,
                          height: 120),
                      highThumbnail: YtThumbnail(
                          url: sharedSong.albumArt,
                          width: 226,
                          height: 26)),
                  resultType: sharedSong.type,
                  duration: "",
                  album: null))));
        },
      ),
    );
  }
}

class SentSongsTab extends StatefulWidget {
  const SentSongsTab({super.key});

  @override
  _SentSongsTabState createState() => _SentSongsTabState();
}

class _SentSongsTabState extends State<SentSongsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<SharedSongBloc, SharedSongState>(
      builder: (context, state) {
        if (state is SharedSongLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SentSharedSongsLoaded) {
          return _buildSongList(state.sharedSongs);
        }
        return _buildEmptyState('You haven\'t shared any songs yet');
      },
    );
  }

  Widget _buildSongList(List<SharedSong> songs) {
    if (songs.isEmpty) {
      return _buildEmptyState('You haven\'t shared any songs yet');
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: songs.length,
      itemBuilder: (context, index) => SharedSongCard(
        sharedSong: songs[index],
        showReceiver: true,
        onTap: () {
          var sharedSong = songs[index];
          context.read<SharedSongBloc>().add(
            MarkSharedSongAsViewedEvent(songs[index].id),
          );
          final isFromAlbum = context.read<PlayerBloc>().state.isFromAlbum;
          if (isFromAlbum) {
            context.read<PlayerBloc>().add(
                UpdateStateEvent(state: context
                    .read<PlayerBloc>()
                    .state
                    .copyWith(isFromAlbum: false)));
          }
          context.read<PlayerBloc>().add(
              PlaySongEvent(song: dartz.left(Song(
                  url: "",
                  title: sharedSong.songName,
                  artists: sharedSong.artistName.split(","),
                  id: sharedSong.songId,
                  category: sharedSong.type,
                  browseId: "",
                  thumbnails: YtThumbnails(
                      defaultThumbnail: YtThumbnail(
                          url: sharedSong.albumArt,
                          width: 60,
                          height: 60),
                      mediumThumbnail: YtThumbnail(
                          url: sharedSong.albumArt,
                          width: 120,
                          height: 120),
                      highThumbnail: YtThumbnail(
                          url: sharedSong.albumArt,
                          width: 226,
                          height: 26)),
                  resultType: sharedSong.type,
                  duration: "",
                  album: null))));
        },
      ),
    );
  }
}

Widget _buildEmptyState(String message) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(CupertinoIcons.music_note, size: 60, color: Colors.grey),
        const SizedBox(height: 16),
        Text(
          message,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    ),
  );
}

class SharedSongCard extends StatelessWidget {
  final SharedSong sharedSong;
  final bool showSender;
  final bool showReceiver;
  final VoidCallback onTap;

  const SharedSongCard({
    super.key,
    required this.sharedSong,
    this.showSender = false,
    this.showReceiver = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              _buildAlbumArt(),
              const SizedBox(width: 16),
              Expanded(child: _buildSongDetails()),
              _buildPlayButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArt() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 60,
        height: 60,
        color: Colors.grey.shade800,
        child: sharedSong.albumArt.isNotEmpty
            ? Image.network(sharedSong.albumArt, fit: BoxFit.cover)
            : const Icon(CupertinoIcons.music_note, color: Colors.grey),
      ),
    );
  }

  Widget _buildSongDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                sharedSong.songName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!sharedSong.isViewed && showSender)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8),
                decoration: const BoxDecoration(
                  color: CupertinoColors.activeBlue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        _buildMetadata(),
      ],
    );
  }

  Widget _buildMetadata() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSender) _buildUserInfo(sharedSong.senderId, 'From: '),
        if (showReceiver) _buildUserInfo(sharedSong.receiverId, 'To: '),
        if (sharedSong.message.isNotEmpty) _buildMessage(),
        const SizedBox(height: 4),
        Text(
          _formatTime(sharedSong.createdAt),
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildUserInfo(String userId, String prefix) {
    return FutureBuilder<AppUser>(
      future: di<AuthRepository>().getUserById(userId),
      builder: (context, snapshot) {
        return Text(
          '${prefix}${snapshot.data?.name ?? '...'}',
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        );
      },
    );
  }

  Widget _buildMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '"${sharedSong.message}"',
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildPlayButton() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        CupertinoIcons.play_fill,
        size: 20,
        color: CupertinoColors.white,
      ),
    );
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d, y').format(date);
  }
}
