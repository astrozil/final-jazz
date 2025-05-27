import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class ConditionalScrollText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double width;

  const ConditionalScrollText({
    Key? key,
    required this.text,
    this.style,
    required this.width,
  }) : super(key: key);

  @override
  State<ConditionalScrollText> createState() => _ConditionalScrollTextState();
}

class _ConditionalScrollTextState extends State<ConditionalScrollText> {
  late bool _needsScrolling;

  @override
  void initState() {
    super.initState();
    _checkTextWidth();
  }

  @override
  void didUpdateWidget(ConditionalScrollText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.width != widget.width) {
      _checkTextWidth();
    }
  }

  void _checkTextWidth() {
    // Measure text width
    final textSpan = TextSpan(text: widget.text, style: widget.style);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    // Check if text exceeds container width
    _needsScrolling = textPainter.width > widget.width;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width, // Explicitly constrain width
      height: (widget.style?.fontSize ?? 14) * 1.5, // Reasonable height based on font size
      child: _needsScrolling
          ? Marquee(
        text: widget.text,
        style: widget.style,
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        blankSpace: 30.0,
        velocity: 30.0,
        pauseAfterRound: Duration(seconds: 1),
        startAfter: Duration(seconds: 1),
      )
          : Text(
        widget.text,
        style: widget.style,
        maxLines: 1,
        overflow: TextOverflow.clip,
      ),
    );
  }
}
