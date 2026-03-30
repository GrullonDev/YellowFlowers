import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:yellow_flowers/features/flowers/models/personalization.dart';

class ThemedFlowerPainter extends CustomPainter {
  ThemedFlowerPainter(this.theme);
  final FlowerTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // 1. Tallo Premium Universal
    _drawPremiumStem(canvas, size, center);

    switch (theme) {
      case FlowerTheme.sunflower:
        _drawEliteSunflower(canvas, center);
        break;
      case FlowerTheme.rose:
        _drawEliteRose(canvas, center);
        break;
      case FlowerTheme.daisy:
        _drawEliteDaisy(canvas, center);
        break;
    }
  }

  void _drawPremiumStem(Canvas canvas, Size size, Offset center) {
    final talloPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF1B5E20), const Color(0xFF4CAF50)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(center.dx - 2, center.dy, 4, size.height - center.dy))
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(center.dx, center.dy + 10);
    path.quadraticBezierTo(center.dx + 8, center.dy + size.height * 0.2, center.dx, size.height);
    canvas.drawPath(path, talloPaint);
  }

  void _drawEliteSunflower(Canvas canvas, Offset center) {
    final petalPaint = Paint();
    const count = 24;

    for (var i = 0; i < count; i++) {
      final angle = i * (2 * math.pi / count);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final rect = Rect.fromLTWH(-8, -45, 16, 45);
      petalPaint.shader = RadialGradient(
        colors: [const Color(0xFFFFD54F), const Color(0xFFFFA000), const Color(0xFFE65100)],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(rect);

      final path = Path();
      path.moveTo(0, 0);
      path.quadraticBezierTo(-10, -22, 0, -45);
      path.quadraticBezierTo(10, -22, 0, 0);
      path.close();

      canvas.drawPath(path, petalPaint);
      canvas.restore();
    }

    // Centro 3D
    final diskPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF3E2723), const Color(0xFF5D4037)],
      ).createShader(Rect.fromCircle(center: center, radius: 18));
    
    canvas.drawCircle(center, 18, diskPaint);
    
    // Mini puntos de polen
    final pPaint = Paint()..color = const Color(0xFFFFA000).withAlpha(150);
    for (int j = 0; j < 12; j++) {
      final a = j * (math.pi / 6);
      canvas.drawCircle(Offset(center.dx + math.cos(a) * 10, center.dy + math.sin(a) * 10), 1.5, pPaint);
    }
  }

  void _drawEliteDaisy(Canvas canvas, Offset center) {
    final petalPaint = Paint();
    const count = 18;

    for (var i = 0; i < count; i++) {
      final angle = i * (2 * math.pi / count);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      petalPaint.shader = LinearGradient(
        colors: [Colors.white, const Color(0xFFF5F5F5), const Color(0xFFE0E0E0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(-6, -40, 12, 40));

      final path = Path();
      path.moveTo(0, 0);
      path.quadraticBezierTo(-8, -20, 0, -40);
      path.quadraticBezierTo(8, -20, 0, 0);
      path.close();

      canvas.drawPath(path, petalPaint);
      canvas.restore();
    }

    canvas.drawCircle(center, 14, Paint()..color = const Color(0xFFFFD54F));
    canvas.drawCircle(center, 9, Paint()..color = const Color(0xFFFFC107));
  }

  void _drawEliteRose(Canvas canvas, Offset center) {
    final rosePaint = Paint();
    
    // Capas de pétalos envolventes
    for (int layer = 3; layer >= 1; layer--) {
      final count = layer * 4;
      final radius = layer * 10.0;
      final petalSize = 50.0 - (layer * 8);

      for (int i = 0; i < count; i++) {
        final angle = i * (2 * math.pi / count) + (layer * 0.5);
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(angle);

        rosePaint.shader = RadialGradient(
          colors: [
            const Color(0xFFFFCDD2),
            const Color(0xFFE57373),
            const Color(0xFFC62828).withAlpha(200),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: const Offset(0, -10), radius: radius));

        final path = Path();
        path.moveTo(0, 0);
        path.quadraticBezierTo(-petalSize/2, -radius, 0, -radius*1.5);
        path.quadraticBezierTo(petalSize/2, -radius, 0, 0);
        path.close();

        canvas.drawPath(path, rosePaint);
        canvas.restore();
      }
    }

    // Núcleo espiral
    canvas.drawCircle(center, 6, Paint()..color = const Color(0xFFB71C1C));
  }

  @override
  bool shouldRepaint(covariant ThemedFlowerPainter oldDelegate) => oldDelegate.theme != theme;
}
