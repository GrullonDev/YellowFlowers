import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Apariencia de una flor del jardín.
class FlowerVariant {
  const FlowerVariant({
    required this.petalColor,
    required this.centerColor,
    required this.petalCount,
    required this.heightFactor,
    required this.lean,
  });

  /// Variante estable a partir de una semilla (p. ej. la fecha).
  factory FlowerVariant.fromSeed(int seed) {
    final rnd = math.Random(seed);
    final petal = _warmPalette[rnd.nextInt(_warmPalette.length)];
    return FlowerVariant(
      petalColor: petal,
      centerColor: petal == const Color(0xFFFFF8E1)
          ? const Color(0xFFFFB300)
          : const Color(0xFF8D4F12),
      petalCount: 5 + rnd.nextInt(5),
      heightFactor: 0.62 + rnd.nextDouble() * 0.38,
      lean: rnd.nextDouble() * 2 - 1,
    );
  }

  final Color petalColor;
  final Color centerColor;
  final int petalCount;

  /// 0..1, proporción de la altura disponible.
  final double heightFactor;

  /// -1..1, inclinación del tallo.
  final double lean;
}

/// Flor que crece de forma orgánica: el tallo se dibuja de abajo hacia
/// arriba, las hojas se despliegan, se forma el botón y los pétalos se
/// abren uno a uno.
///
/// [progress] 0..1 controla el crecimiento; [sway] (-1..1) el balanceo.
class GrowingFlower extends StatelessWidget {
  const GrowingFlower({
    super.key,
    required this.progress,
    required this.variant,
    this.sway = 0,
  });

  final double progress;
  final FlowerVariant variant;
  final double sway;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GrowingFlowerPainter(progress, variant, sway),
      size: Size.infinite,
    );
  }
}

class _GrowingFlowerPainter extends CustomPainter {
  _GrowingFlowerPainter(this.progress, this.v, this.sway);

  final double progress;
  final FlowerVariant v;
  final double sway;

  static double _seg(double t, double a, double b, [Curve c = Curves.easeOut]) =>
      c.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final w = size.width, h = size.height;
    final base = Offset(w / 2, h);
    final stemHeight = h * v.heightFactor * 0.82;
    final headRadius = math.min(w * 0.42, stemHeight * 0.2);

    // Balanceo alrededor de la base
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(sway * 0.05 * _seg(progress, 0.3, 1));
    canvas.translate(-base.dx, -base.dy);

    // --- Tallo ---
    final top = Offset(w / 2 + v.lean * w * 0.18, h - stemHeight);
    final stem = Path()
      ..moveTo(base.dx, base.dy)
      ..cubicTo(
        base.dx - v.lean * w * 0.25,
        h - stemHeight * 0.35,
        top.dx + v.lean * w * 0.2,
        h - stemHeight * 0.7,
        top.dx,
        top.dy,
      );
    final metric = stem.computeMetrics().first;
    final stemT = _seg(progress, 0.0, 0.5, Curves.easeOutCubic);
    final grown = metric.extractPath(0, metric.length * stemT);
    canvas.drawPath(
      grown,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = math.max(2.0, w * 0.06)
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFF2E6B3A), Color(0xFF7CB342)],
        ).createShader(Rect.fromLTWH(0, top.dy, w, stemHeight)),
    );

    // --- Hojas ---
    void leaf(double at, double start, double side) {
      final lt = _seg(progress, start, start + 0.25, Curves.easeOutBack);
      if (lt <= 0 || stemT < at) return;
      final tan = metric.getTangentForOffset(metric.length * at)!;
      final len = stemHeight * 0.22 * lt;
      canvas.save();
      canvas.translate(tan.position.dx, tan.position.dy);
      canvas.rotate(-tan.angle + side * 0.9 - math.pi / 2 * side * 0.2);
      final leafPath = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(side * len * 0.5, -len * 0.45, side * len, 0)
        ..quadraticBezierTo(side * len * 0.5, len * 0.25, 0, 0)
        ..close();
      canvas.drawPath(leafPath, Paint()..color = const Color(0xFF558B2F));
      canvas.restore();
    }

    leaf(0.32, 0.22, -1);
    leaf(0.55, 0.32, 1);

    // --- Cabeza de la flor ---
    if (stemT >= 1 || progress > 0.5) {
      final head = metric.getTangentForOffset(metric.length * stemT)!.position;
      final bud = _seg(progress, 0.45, 0.6, Curves.easeOutBack);
      final bloom = _seg(progress, 0.85, 1.0);

      // Resplandor cuando florece
      if (bloom > 0) {
        final r = headRadius * 2.6;
        canvas.drawCircle(
          head,
          r,
          Paint()
            ..shader = RadialGradient(colors: [
              v.petalColor.withAlpha((90 * bloom).round()),
              v.petalColor.withAlpha(0),
            ]).createShader(Rect.fromCircle(center: head, radius: r)),
        );
      }

      // Pétalos: cada uno se abre con un pequeño retraso
      final n = v.petalCount;
      for (var i = 0; i < n; i++) {
        final start = 0.55 + (i / n) * 0.25;
        final pt = _seg(progress, start, start + 0.2, Curves.easeOutBack);
        if (pt <= 0) continue;
        final angle = -math.pi / 2 + i * 2 * math.pi / n;
        final len = headRadius * 1.15 * pt;
        canvas.save();
        canvas.translate(head.dx, head.dy);
        canvas.rotate(angle);
        final petalRect =
            Rect.fromLTWH(headRadius * 0.15, -len * 0.28, len, len * 0.56);
        canvas.drawOval(
          petalRect,
          Paint()
            ..shader = LinearGradient(colors: [
              Color.lerp(v.petalColor, Colors.white, 0.35)!,
              v.petalColor,
            ]).createShader(petalRect),
        );
        canvas.restore();
      }

      // Botón / centro
      if (bud > 0) {
        final cr = headRadius * 0.42 * bud;
        canvas.drawCircle(
          head,
          cr,
          Paint()
            ..color = Color.lerp(
                const Color(0xFF689F38), v.centerColor, _seg(progress, 0.6, 0.85))!,
        );
        // Destello blanco del centro
        canvas.drawCircle(head.translate(-cr * 0.3, -cr * 0.3), cr * 0.25,
            Paint()..color = Colors.white.withAlpha((110 * bloom).round()));
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GrowingFlowerPainter old) =>
      old.progress != progress || old.sway != sway || old.v != v;
}

/// Amarillos cálidos, dorados y blancos luminosos.
const _warmPalette = [
  Color(0xFFFFD54F),
  Color(0xFFFFC107),
  Color(0xFFFFE082),
  Color(0xFFFFB300),
  Color(0xFFFFF8E1),
  Color(0xFFFFCA28),
];
