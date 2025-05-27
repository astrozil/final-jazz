import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class LyricsScreen extends StatefulWidget {
  const LyricsScreen({super.key});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late ScrollController _scrollController;
  int _currentLyricIndex = 0;
  bool _hasStartedPlaying = false;
  bool _userScrolling = false;
  final double _lyricItemHeight = 70.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_onUserScroll);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.removeListener(_onUserScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onUserScroll() {
    if (_scrollController.position.userScrollDirection != ScrollDirection.idle) {
      setState(() {
        _userScrolling = true;
      });
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _userScrolling = false;
          });
        }
      });
    }
  }

  void _updateCurrentLyric(int currentPositionMs, List<Map<String, dynamic>> syncedLyrics) {
    if (syncedLyrics.isEmpty) return;
    if (currentPositionMs > 500) {
      _hasStartedPlaying = true;
    } else if (currentPositionMs == 0) {
      _hasStartedPlaying = false;
      setState(() {
        _currentLyricIndex = 0;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
      return;
    }
    if (!_hasStartedPlaying) return;
    int newIndex = 0;
    for (int i = 0; i < syncedLyrics.length; i++) {
      if (i == syncedLyrics.length - 1 ||
          (currentPositionMs >= syncedLyrics[i]['startTime'] &&
              currentPositionMs < syncedLyrics[i + 1]['startTime'])) {
        newIndex = i;
        break;
      }
    }
    if (_currentLyricIndex != newIndex) {
      setState(() {
        _currentLyricIndex = newIndex;
      });
      if (!_userScrolling) {
        _scrollToCurrentLyric(newIndex);
      }
    }
  }

  void _scrollToCurrentLyric(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final viewportHeight = _scrollController.position.viewportDimension;
        double position = 0;
        for (int i = 0; i < index; i++) {
          // Add padding between items
          position += _lyricItemHeight + 20.r; // 12.r padding top + 12.r padding bottom
        }
        final scrollPosition = position - (viewportHeight / 2) + (_lyricItemHeight / 2);
        final clampedPosition = scrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent);
        _scrollController.animateTo(
          clampedPosition,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24.r),
          onPressed: () => Navigator.pop(context),
        ),
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            "Lyrics",
            style: GoogleFonts.poppins(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<PlayerBloc, Player>(
        builder: (context, state) {
          if (state is PlayerState) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              return _buildErrorState(state.errorMessage!);
            }
            List<Map<String, dynamic>> syncedLyrics = [];
            if (state.lyrics != null && state.lyrics!.isNotEmpty) {
              syncedLyrics = state.lyrics!;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _updateCurrentLyric(state.songPosition.inMilliseconds, syncedLyrics);
              });
              return _buildSyncedLyricsContent(syncedLyrics);
            } else {
              return _buildNoLyricsState();
            }
          } else {
            return _buildLoadingState();
          }
        },
      ),
    );
  }

  Widget _buildSyncedLyricsContent(List<Map<String, dynamic>> syncedLyrics) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.r),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _controller,
                curve: Curves.easeOutQuart,
              )),
              child: child,
            );
          },
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: syncedLyrics.length,
                  itemBuilder: (context, index) {
                    if (index == 0 && !_hasStartedPlaying) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(0);
                        }
                      });
                    }
                    final bool isCurrentLyric = index == _currentLyricIndex;
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(isCurrentLyric ? 8.r : 0),
                          color:  Colors.transparent,
                        ),
                        child: Text(
                          syncedLyrics[index]['text'],
                          style: GoogleFonts.montserrat(
                            fontSize: isCurrentLyric ? 26.sp : 26.sp,
                            height: 1.5,
                            fontWeight: isCurrentLyric ? FontWeight.bold : FontWeight.bold,
                            color: isCurrentLyric
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          SizedBox(height: 20.h),
          Text(
            "Loading lyrics...",
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                "Oops! Something went wrong",
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 16.r),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackgroundColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  errorMessage,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoLyricsState() {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [


              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 16.r),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackgroundColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  "Lyrics for this track haven't been added yet",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
