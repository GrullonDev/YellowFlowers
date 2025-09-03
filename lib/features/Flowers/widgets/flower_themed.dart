import 'package:flutter/material.dart';

import 'package:yellow_flowers/features/flowers/models/personalization.dart';
import 'package:yellow_flowers/features/flowers/widgets/flower_theme_painter.dart';

class FlowerThemed extends StatelessWidget {
  const FlowerThemed({super.key, required this.theme, this.width, this.height});
  final FlowerTheme theme;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return CustomPaint(
      size: Size(width ?? size.width / 8, height ?? size.height),
      painter: ThemedFlowerPainter(theme),
    );
  }
}
