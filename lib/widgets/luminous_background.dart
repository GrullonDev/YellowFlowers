import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Fondo nocturno luminoso: degradado profundo, orbes dorados que flotan
/// y un horizonte cálido que "respira".
class LuminousBackground extends StatefulWidget {
  const LuminousBackground({super.key});

  @override
  State<LuminousBackground> createState() => _LuminousBackgroundState();
}

class _LuminousBackgroundState extends State<LuminousBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 24))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _LuminousPainter(_c),
      ),
    );
  }
}

class _LuminousPainter extends CustomPainter {
  _LuminousPainter(this.animation) : super(repaint: animation);
  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final t = animation.value * 2 * math.pi;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0B0820),
            Color(0xFF1C1236),
            Color(0xFF3A1D33),
            Color(0xFF6B3A12),
          ],
          stops: [0.0, 0.45, 0.78, 1.0],
        ).createShader(rect),
    );

    void orb(Offset c, double r, Color color) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(colors: [color, color.withAlpha(0)])
              .createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    final w = size.width, h = size.height;
    orb(Offset(w * 0.2 + math.sin(t) * 30, h * 0.18 + math.cos(t) * 20),
        w * 0.55, const Color(0xFFFFC107).withAlpha(38));
    orb(Offset(w * 0.85 + math.cos(t * 1.3) * 25, h * 0.42 + math.sin(t) * 30),
        w * 0.6, const Color(0xFFFF8A65).withAlpha(30));
    orb(Offset(w * 0.5 + math.sin(t * 0.7) * 40, h * 0.7), w * 0.5,
        const Color(0xFFFFF59D).withAlpha(22));

    // Horizonte cálido
    final pulse = 0.85 + 0.15 * math.sin(t * 2);
    final horizon = Rect.fromCenter(
        center: Offset(w / 2, h * 1.02), width: w * 1.8, height: h * 0.55);
    canvas.drawOval(
      horizon,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFFB300).withAlpha((120 * pulse).round()),
          const Color(0xFFFFB300).withAlpha(0),
        ]).createShader(horizon),
    );
  }

  @override
  bool shouldRepaint(covariant _LuminousPainter oldDelegate) => false;
}
