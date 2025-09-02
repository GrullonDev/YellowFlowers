import 'package:flutter/material.dart';
import 'package:yellow_flowers/features/Flowers/widgets/flower_painter.dart';

/// Simple sized illustration of the yellow flower for onboarding/hero.
class FlowerIllustration extends StatelessWidget {
  const FlowerIllustration({super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: FlorPainter(),
    );
  }
}
