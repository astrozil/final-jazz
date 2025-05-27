import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/core/widgets/confirm_widget.dart';
import 'package:jazz/core/widgets/song_widget.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/notification_bloc/notification_bloc.dart';
import 'package:jazz/features/playlist_feature/presentation/bloc/playlist_bloc/playlist_bloc.dart';

import '../../../../core/routes.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import '../../../download_feature/domain/entities/download_request.dart';
import '../../../download_feature/presentation/bloc/DownloadedOrNotBloc/downloaded_or_not_bloc.dart';
import '../../../download_feature/presentation/bloc/download/download_bloc.dart';
import '../../../search_feature/presentation/bloc/artist_bloc/artist_bloc.dart';
import '../../../search_feature/presentation/widgets/share_user_selection.dart';
import '../../../search_feature/presentation/widgets/user_selection_bottom_sheet.dart';
import '../../../stream_feature/presentation/bloc/playerBloc/player_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));

    context.read<PlaylistBloc>().add(FetchTrendingSongsPlaylistEvent());
    context.read<AuthBloc>().add(FetchUserDataEvent());
    context.read<PlaylistBloc>().add(FetchBillboardSongsPlaylistEvent());
    context.read<PlaylistBloc>().add(FetchRecommendedSongsPlaylist());
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is UserDataFetched) {
          final artistIds = state.user.favouriteArtists.join(",");
          context.read<PlaylistBloc>().add(
              FetchSuggestedSongsOfFavouriteArtists(artistIds: artistIds));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryBackgroundColor,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.primaryBackgroundColor,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Home",
                      style: TextStyle(color: Colors.white, fontSize: 25.sp),
                    ),
                    GestureDetector(
                      onTap: () {
                        context
                            .read<NotificationBloc>()
                            .add(GetUserNotificationsEvent());
                        Navigator.pushNamed(context, Routes.notificationScreen);
                      },
                      child: const Icon(
                        Icons.notifications_none_outlined,
                        size: 30,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
              _buildSectionHeaderWithViewAll(context, "Trending songs for you",
                      () {
                    Navigator.pushNamed(context, Routes.trendingSongsPlaylistScreen);
                  }),
              Container(
                child: BlocBuilder<PlaylistBloc, PlaylistLoaded>(
                  builder: (context, state) {
                    if (state.isLoading && state.trendingSongsPlaylist.isEmpty) {
                      return _buildSongListSkeleton();
                    } else {
                      return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            final songs = state.trendingSongsPlaylist;
                            final song = state.trendingSongsPlaylist[index];
                            return songWidget(context: context, song: song.song,songs: songs);
                          });
                    }
                  },
                ),
              ),
              SizedBox(height: 16.h),
              _buildSectionHeaderWithViewAll(
                  context, "Songs of your favourite artists", () {
                Navigator.pushNamed(context, Routes.suggestedSongsPlaylistScreen);
              }),
              Container(
                height: 270.h,
                child: BlocBuilder<PlaylistBloc, PlaylistLoaded>(
                  builder: (context, state) {
                    if (state.isLoading &&
                        state.suggestedSongsOfFavouriteArtists.isEmpty) {
                      return _buildHorizontalCardsSkeleton();
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: 10,
                            itemBuilder: (context, index) {
                              final songs = state.suggestedSongsOfFavouriteArtists;
                              final song = songs[index];
                              return GestureDetector(
                                onTap: () {
                                  context.read<PlayerBloc>().add(PlaySongEvent(
                                      song: dartz.left(song.song),
                                      albumTracks: songs));
                                },
                                child: Container(
                                  width: 170.w,
                                  margin: const EdgeInsets.only(right: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 160,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(8),
                                          image: DecorationImage(
                                            image: NetworkImage(song
                                                .song
                                                .thumbnails
                                                .highThumbnail
                                                .url),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        song.song.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        song.song.artists
                                            .map((artist) => artist['name'])
                                            .join(","),
                                        style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      );
                    }
                  },
                ),
              ),
              _buildSectionHeaderWithViewAll(context, "Billboard songs", () {
                Navigator.pushNamed(context, Routes.billboardSongsPlaylistScreen);
              }),
              Container(
                child: BlocBuilder<PlaylistBloc, PlaylistLoaded>(
                  builder: (context, state) {
                    if (state.isLoading &&
                        state.billboardSongsPlaylist.isEmpty) {
                      return _buildSongListSkeleton();
                    } else {
                      return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            final songs = state.billboardSongsPlaylist;
                            final song = state.billboardSongsPlaylist[index];
                            return songWidget(context: context, song: song.song,songs: songs);
                          });
                    }
                  },
                ),
              ),
              SizedBox(height: 16.h),
              _buildSectionHeaderWithViewAll(context,
                  "Recommendation from \n your recent songs", () {
                    Navigator.pushNamed(context, Routes.recommendedSongsPlaylistScreen);
                  }),
              Container(
                child: BlocBuilder<PlaylistBloc, PlaylistLoaded>(
                  builder: (context, state) {
                    if (state.isLoading &&
                        state.recommendedSongsPlaylist.isEmpty) {
                      return _buildSongListSkeleton();
                    } else {
                      return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            final songs = state.recommendedSongsPlaylist;
                            final song = state.recommendedSongsPlaylist[index];
                            return songWidget(context: context, song: song.song,songs: songs);
                          });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Shimmer effect widget
  Widget _buildShimmerEffect({required Widget child}) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Colors.transparent,
                Colors.white24,
                Colors.transparent,
              ],
              stops: [
                _shimmerController.value - 0.3,
                _shimmerController.value,
                _shimmerController.value + 0.3,
              ],
              transform: const GradientRotation(0),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }

  // Skeleton loading widget for song list items with shimmer
  Widget _buildSongListSkeleton() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              // Image skeleton with shimmer
              _buildShimmerEffect(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title skeleton with shimmer
                    _buildShimmerEffect(
                      child: Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Artist skeleton with shimmer
                    _buildShimmerEffect(
                      child: Container(
                        height: 14,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // More options skeleton with shimmer
              _buildShimmerEffect(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Skeleton loading widget for horizontal scrolling cards with shimmer
  Widget _buildHorizontalCardsSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 170.w,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image skeleton with shimmer
                _buildShimmerEffect(
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Title skeleton with shimmer
                _buildShimmerEffect(
                  child: Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Artist skeleton with shimmer
                _buildShimmerEffect(
                  child: Container(
                    height: 13,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeaderWithViewAll(
      BuildContext context, String title, VoidCallback onViewAllTapped) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: onViewAllTapped,
            child: Text(
              "View all",
              style: TextStyle(
                color: Colors.grey.withOpacity(0.8),
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
