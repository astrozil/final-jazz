import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/core/widgets/global_player_widget.dart';
import 'package:jazz/features/search_feature/presentation/screens/collapsed_current_song.dart';
import 'package:jazz/features/search_feature/presentation/screens/expanded_current_song.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';

class AppWithPlayer extends StatefulWidget {
  final Widget child;
  final bool showPlayer;
  final Widget? bottomNavigationBar;

  const AppWithPlayer({
    super.key,
    required this.child,
    this.showPlayer = true,
    this.bottomNavigationBar,
  });

  @override
  State<AppWithPlayer> createState() => _AppWithPlayerState();
}

class _AppWithPlayerState extends State<AppWithPlayer> {
  bool _isPlayerExpanded = false;

  void _onPlayerExpansionChanged(bool isExpanded) {
    setState(() {
      _isPlayerExpanded = isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    const collapsedPlayerHeight = 0.0;

    return Scaffold(
      backgroundColor: AppColors.primaryBackgroundColor,
      body: BlocBuilder<PlayerBloc, Player>(
        builder: (context, state) {
          // Check if there's a current song playing
          final hasCurrentSong = state is PlayerState && state.currentSong != null;

          return Stack(
            children: [
              // Main content with bottom padding to account for player and nav bar
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: widget.showPlayer && hasCurrentSong && !_isPlayerExpanded
                        ? collapsedPlayerHeight + (widget.bottomNavigationBar != null ? kBottomNavigationBarHeight : 0)
                        : widget.bottomNavigationBar != null && !_isPlayerExpanded ? kBottomNavigationBarHeight : 0,
                  ),
                  child: widget.child,
                ),
              ),

              // Player widget positioned at the bottom - only show if there's a current song
              if (widget.showPlayer && hasCurrentSong)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  top: _isPlayerExpanded ? 0 : null,
                  child: SwipeablePlayerContainer(
                    collapsedChild: CollapsedCurrentSong(),
                    expandedChild: ExpandedCurrentSong(),
                    onExpansionChanged: _onPlayerExpansionChanged,
                    isExpanded: _isPlayerExpanded,
                  ),
                ),
            ],
          );
        },
      ),

      // Fixed bottom navigation bar logic
      bottomNavigationBar: widget.bottomNavigationBar != null && !_isPlayerExpanded
          ? AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 70,
        child: widget.bottomNavigationBar!,
      )
          : null,
    );
  }
}

class SwipeablePlayerContainer extends StatefulWidget {
  final Widget collapsedChild;
  final Widget expandedChild;
  final Function(bool)? onExpansionChanged;
  final bool isExpanded;

  const SwipeablePlayerContainer({
    Key? key,
    required this.collapsedChild,
    required this.expandedChild,
    this.onExpansionChanged,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  _SwipeablePlayerContainerState createState() => _SwipeablePlayerContainerState();
}

class _SwipeablePlayerContainerState extends State<SwipeablePlayerContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpanded = false;

  // Drag threshold to determine when to expand/collapse
  final double _dragThreshold = 50.0;
  // Keep track of drag position
  double _dragDistance = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }

      // Notify parent about expansion state change
      widget.onExpansionChanged?.call(_isExpanded);
    });
  }

  // Handle tap - only expand, never collapse
  void _handleTap() {
    if (!_isExpanded) {
      _toggleExpanded();
    }
    // Do nothing if already expanded
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const collapsedHeight = 80.0;

    return GestureDetector(
      onTap: _handleTap,
      onVerticalDragUpdate: (details) {
        if (_isExpanded) {
          // When expanded, track downward drags
          if (details.primaryDelta! > 0) {
            _dragDistance += details.primaryDelta!;
            // If dragged enough, collapse
            if (_dragDistance > _dragThreshold) {
              _toggleExpanded();
              _dragDistance = 0;
            }
          }
        } else {
          // When collapsed, track upward drags
          if (details.primaryDelta! < 0) {
            _dragDistance -= details.primaryDelta!;
            // If dragged enough, expand
            if (_dragDistance > _dragThreshold) {
              _toggleExpanded();
              _dragDistance = 0;
            }
          }
        }
      },
      onVerticalDragEnd: (details) {
        // Reset drag distance when drag is complete
        _dragDistance = 0;

        // If a significant velocity, expand or collapse based on direction
        if (details.primaryVelocity != null && details.primaryVelocity!.abs() > 500) {
          if (details.primaryVelocity! < 0 && !_isExpanded) {
            // Swiped up while collapsed
            _toggleExpanded();
          } else if (details.primaryVelocity! > 0 && _isExpanded) {
            // Swiped down while expanded
            _toggleExpanded();
          }
        }
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent, // Remove any background color
              boxShadow: _isExpanded || _animation.value > 0.1
                  ? []
                  : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Expanded view with opacity animation
                if (_animation.value > 0.1)
                  Positioned.fill(
                    child: Opacity(
                      opacity: _animation.value,
                      child: widget.expandedChild,
                    ),
                  ),

                // Collapsed view with reverse opacity animation
                if (_animation.value < 0.9)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: 1 - _animation.value,
                      child: Container(
                        height: collapsedHeight,
                        child: widget.collapsedChild,
                      ),
                    ),
                  ),

                // Drag indicator for expanded view
                if (_isExpanded)
                  Positioned(
                    top: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
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
}
