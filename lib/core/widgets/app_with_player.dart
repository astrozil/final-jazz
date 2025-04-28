import 'package:flutter/material.dart';
import 'package:jazz/core/widgets/global_player_widget.dart';

class AppWithPlayer extends StatelessWidget {
  final Widget child;
  final bool showPlayer;
  const AppWithPlayer({super.key, required this.child, this.showPlayer = true,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          child,

          // Player widget positioned at the bottom
          if (showPlayer)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlobalPlayerWidget(),
          ),
        ],
      ),
    );
  }
}
