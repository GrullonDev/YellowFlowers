import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:yellow_flowers/features/Flowers/models/personalization.dart';

class ThemedFlowerPainter extends CustomPainter {
  ThemedFlowerPainter(this.theme);
  final FlowerTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    switch (theme) {
      case FlowerTheme.sunflower:
        _drawSunflower(canvas, size);
      case FlowerTheme.rose:
        _drawRose(canvas, size);
      case FlowerTheme.daisy:
        _drawDaisy(canvas, size);
    }
  }

  void _drawStem(Canvas canvas, Size size, {Color color = const Color(0xFF5A8F5D)}) {
    final center = Offset(size.width / 2, size.height / 2);
    final stemPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, Offset(center.dx, size.height), stemPaint);
  }

  void _drawSunflower(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final petal = Paint()..color = const Color(0xFFFFD166); // sunflower yellow
    final disk = Paint()..color = const Color(0xFF7F5539); // brown
    for (var i = 0; i < 16; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * (math.pi * 2 / 16));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: const Offset(0, -24), width: 14, height: 38),
          const Radius.circular(7),
        ),
        petal,
      );
      canvas.restore();
    }
    canvas.drawCircle(center, 18, disk);
    _drawStem(canvas, size);
  }

  void _drawDaisy(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final petal = Paint()..color = const Color(0xFFFFF8E1);
    final outline = Paint()
      ..color = const Color(0xFFFFE07D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final disk = Paint()..color = const Color(0xFFFFB347);
    for (var i = 0; i < 12; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * (math.pi * 2 / 12));
      final rect = Rect.fromCenter(center: const Offset(0, -22), width: 16, height: 36);
      canvas.drawOval(rect, petal);
      canvas.drawOval(rect, outline);
      canvas.restore();
    }
    canvas.drawCircle(center, 16, disk);
    _drawStem(canvas, size);
  }

  void _drawRose(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rose = Paint()..color = const Color(0xFFE57373); // soft rose red
    final layers = [18.0, 14.0, 10.0, 6.0];
    for (var i = 0; i < layers.length; i++) {
      final r = layers[i];
      canvas.drawCircle(center, r, rose..color = rose.color.withValues(alpha: 0.8 - i * 0.12));
    }
    _drawStem(canvas, size);
  }

  @override
  bool shouldRepaint(covariant ThemedFlowerPainter oldDelegate) => oldDelegate.theme != theme;
}
