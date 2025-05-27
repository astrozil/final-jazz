import 'package:flutter/material.dart';

class RectangularSliderThumbShape extends SliderComponentShape {
  final double width;
  final double height;
  final double borderRadius;

  const RectangularSliderThumbShape({
    this.width = 16.0,
    this.height = 24.0,
    this.borderRadius = 2.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(width, height);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required Size sizeWithOverflow,
        required double textScaleFactor,
      }) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: width,
          height: height,
        ),
        Radius.circular(borderRadius),
      ),
      paint,
    );
  }
}
