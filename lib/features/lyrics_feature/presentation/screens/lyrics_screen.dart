import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  final double _lyricItemHeight = 50.0;

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
    // Detect user scrolling to temporarily disable auto-scroll
    if (_scrollController.position.userScrollDirection != ScrollDirection.idle) {
      setState(() {
        _userScrolling = true;
      });

      // Re-enable auto-scroll after a delay
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

    // Check if the song has started playing
    if (currentPositionMs > 500) {
      _hasStartedPlaying = true;
    } else if (currentPositionMs == 0) {
      // Reset if the song has been restarted
      _hasStartedPlaying = false;
      setState(() {
        _currentLyricIndex = 0;
      });

      // Jump to the beginning of lyrics when song restarts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });

      return;
    }

    // Don't update if the song hasn't started playing yet
    if (!_hasStartedPlaying) return;

    int newIndex = 0;
    // Find the current lyric based on timestamp
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

      // Only scroll if user is not manually scrolling
      if (!_userScrolling) {
        _scrollToCurrentLyric(newIndex);
      }
    }
  }

  void _scrollToCurrentLyric(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // Calculate position to center the current lyric in the viewport
        final viewportHeight = _scrollController.position.viewportDimension;
        final estimatedPosition = index * _lyricItemHeight;

        // Center the current lyric in the viewport
        final scrollPosition = estimatedPosition - (viewportHeight / 2) + (_lyricItemHeight / 2);

        // Clamp the scroll position to valid range
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
      body: Container(
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
        child: BlocBuilder<PlayerBloc, Player>(
          builder: (context, state) {
            if (state is PlayerState) {
              // Check if there's an error message
              if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
                return _buildErrorState(state.errorMessage!);
              }

              // Parse the synced lyrics if they exist
              List<Map<String, dynamic>> syncedLyrics = [];
              if (state.lyrics != null && state.lyrics!.isNotEmpty) {
                syncedLyrics = state.lyrics!;

                // Schedule the update after the frame is rendered to avoid setState during build
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
                    // For the first lyric item at the start of the song
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
                        padding: EdgeInsets.symmetric(
                            vertical: isCurrentLyric ? 2.r : 0,
                            horizontal: isCurrentLyric ? 8.r : 0
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(isCurrentLyric ? 8.r : 0),
                          color: isCurrentLyric ? Colors.white.withOpacity(0.1) : Colors.transparent,
                        ),
                        child: Text(
                          syncedLyrics[index]['text'],
                          style: GoogleFonts.montserrat(
                            fontSize: isCurrentLyric ? 20.sp : 18.sp,
                            height: 1.5,
                            fontWeight: isCurrentLyric ? FontWeight.bold : FontWeight.normal,
                            color: isCurrentLyric
                                ? Colors.white
                                : Colors.white.withOpacity(0.7),
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

  Widget _buildPlainLyricsContent(String lyrics) {
    final lines = lyrics.split('\n');

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
          child: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            itemCount: lines.length,
            itemBuilder: (context, index) {
              // Check if this line is a timestamp or empty
              bool isTimestamp = lines[index].trim().contains(RegExp(r'^\[\d{2}:\d{2}\.\d{2}\]'));
              bool isEmpty = lines[index].trim().isEmpty;

              if (isTimestamp || isEmpty) {
                return SizedBox(height: 8.h);
              }

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.r),
                child: Text(
                  lines[index],
                  style: GoogleFonts.montserrat(
                    fontSize: 18.sp,
                    height: 1.5,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
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
          Lottie.network(
            'https://assets9.lottiefiles.com/packages/lf20_szlepvdh.json',
            width: 200.r,
            height: 200.r,
          ),
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
              Lottie.network(
                'https://assets2.lottiefiles.com/packages/lf20_qpwbiyxf.json',
                width: 200.r,
                height: 200.r,
              ),
              SizedBox(height: 20.h),
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
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  errorMessage,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: Colors.white70,
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
              Lottie.network(
                'https://assets4.lottiefiles.com/packages/lf20_jmejybvu.json',
                width: 220.r,
                height: 220.r,
              ),
              SizedBox(height: 20.h),
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'No lyrics available',
                    textStyle: GoogleFonts.poppins(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
              ),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 16.r),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  "Lyrics for this track haven't been added yet",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: Colors.white70,
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
