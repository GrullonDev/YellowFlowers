import 'package:flutter/material.dart';
import 'package:yellow_flowers/features/widgets/flower_painter.dart';

class Flor extends StatelessWidget {
  const Flor({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return CustomPaint(
      size: Size(
        size.width / 8,
        size.height,
      ),
      painter: FlorPainter(),
    );
  }
}
