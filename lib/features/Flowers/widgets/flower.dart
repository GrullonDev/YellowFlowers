import 'package:flutter/material.dart';
import 'package:yellow_flowers/features/Flowers/widgets/flower_painter.dart';

class Flor extends StatelessWidget {
  const Flor({super.key, this.width, this.height});

  // Allow callers to control size (useful for onboarding illustration), while
  // keeping backward-compatibility with previous behavior when null.
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final w = width ?? size.width / 8;
    final h = height ?? size.height;

    return CustomPaint(
      size: Size(w, h),
      painter: FlorPainter(),
    );
  }
}
