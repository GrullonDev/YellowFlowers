import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:yellow_flowers/features/flowers/models/personalization.dart';

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

  void _drawStem(Canvas canvas, Size size,
      {Color color = const Color(0xFF5A8F5D)}) {
    final center = Offset(size.width / 2, size.height / 2);
    final stemPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, Offset(center.dx, size.height), stemPaint);
  }

  void _drawSunflower(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Petal paints and stroke
    final petalPaint = Paint()..style = PaintingStyle.fill;
    final petalStroke = Paint()
      ..color = const Color(0xFFB06C00).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    Path petalPath(double w, double h, {double curvature = 0.5}) {
      final path = Path();
      final top = Offset(0, -h / 2);
      final bottom = Offset(0, h / 2);
      path.moveTo(bottom.dx, bottom.dy);
      path.cubicTo(-w / 2, h * 0.20, -w / 2, -h * 0.10, top.dx, top.dy);
      path.cubicTo(w / 2, -h * 0.10, w / 2, h * 0.20, bottom.dx, bottom.dy);
      path.close();
      return path;
    }

    // Outer ring of petals
    const outerCount = 20;
    for (var i = 0; i < outerCount; i++) {
      final angle = i * (2 * math.pi / outerCount);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.translate(0, -20);
      final path = petalPath(18, 36);
      final bounds = path.getBounds();
      petalPaint.shader = const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Color(0xFFFFA000), Color(0xFFFFE082)],
      ).createShader(bounds);
      canvas.drawPath(path, petalPaint);
      canvas.drawPath(path, petalStroke);
      canvas.restore();
    }

    // Inner ring, slightly shorter and offset
    const innerCount = 20;
    for (var i = 0; i < innerCount; i++) {
      final angle = i * (2 * math.pi / innerCount) + (math.pi / innerCount);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.translate(0, -14);
      final path = petalPath(14, 28);
      final bounds = path.getBounds();
      petalPaint.shader = const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Color(0xFFFF8F00), Color(0xFFFFEE58)],
      ).createShader(bounds);
      canvas.drawPath(path, petalPaint);
      canvas.drawPath(path, petalStroke);
      canvas.restore();
    }

    // Dark center disk with subtle gradient
    final diskPaint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawCircle(center, 18, diskPaint);
    canvas.drawCircle(center, 16, Paint()..color = const Color(0xFF6D4C41));

    // Seed pattern (golden-angle spiral) - keep light for performance
    const seeds = 80;
    for (var i = 0; i < seeds; i++) {
      final t = i / seeds;
      final angle = i * 2.399963229728653; // ~137.5° in radians
      final r = 2 + t * 14; // spread towards edge
      final dx = r * math.cos(angle);
      final dy = r * math.sin(angle);
      final p = Offset(center.dx + dx, center.dy + dy);
      final c = Color.lerp(const Color(0xFF8D6E63), const Color(0xFF3E2723), t)!
          .withValues(alpha: 0.9);
      canvas.drawCircle(p, 1.3 + 0.7 * (1 - t), Paint()..color = c);
    }

    _drawStem(canvas, size);
  }

  void _drawDaisy(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final petalStroke = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    Path petalPath(double w, double h) {
      final path = Path();
      final top = Offset(0, -h / 2);
      final bottom = Offset(0, h / 2);
      path.moveTo(bottom.dx, bottom.dy);
      path.quadraticBezierTo(-w / 2, 0, top.dx, top.dy);
      path.quadraticBezierTo(w / 2, 0, bottom.dx, bottom.dy);
      path.close();
      return path;
    }

    const petals = 20;
    for (var i = 0; i < petals; i++) {
      final angle = i * (2 * math.pi / petals);
      final w = 14 + (i.isEven ? 1.0 : -1.0); // sutil variación
      final h = 34 + (i % 3 == 0 ? 2.0 : 0.0);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.translate(0, -18);
      final path = petalPath(w, h);
      // Sombra suave en base del pétalo
      final bounds = path.getBounds();
      final shader = const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Color(0xFFEAEAEA), Color(0xFFFFFFFF)],
        stops: [0.0, 0.6],
      ).createShader(bounds);
      final fill = Paint()..shader = shader;
      canvas.drawPath(path, fill);
      canvas.drawPath(path, petalStroke);
      canvas.restore();
    }

    // Center disk with warm yellow/orange
    final centerOuter = Paint()..color = const Color(0xFFFFD54F);
    final centerInner = Paint()..color = const Color(0xFFFFC107);
    canvas.drawCircle(center, 16, centerOuter);
    canvas.drawCircle(center, 12, centerInner);

    _drawStem(canvas, size);
  }

  void _drawRose(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Colors
    const roseBase = Color(0xFFE57373); // soft rose red
    const roseLight = Color(0xFFFFCDD2); // light pink
    const roseDark = Color(0xFFC62828); // deep red for strokes

    // Paints
    final petalPaint = Paint()
      ..color = roseBase
      ..style = PaintingStyle.fill;
    final petalStroke = Paint()
      ..color = roseDark.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Helper: draw single petal as a teardrop using a path
    Path petalPath(double w, double h, {double curvature = 0.55}) {
      final path = Path();
      final top = Offset(0, -h / 2);
      final bottom = Offset(0, h / 2);
      final rightCtrl = Offset(w * curvature, -h * 0.15);
      path.moveTo(bottom.dx, bottom.dy);
      // Left curve to top
      path.cubicTo(
        -w / 2,
        h * 0.25,
        -w / 2,
        -h * 0.15,
        top.dx,
        top.dy,
      );
      // Right curve back to bottom
      path.cubicTo(
        rightCtrl.dx,
        rightCtrl.dy,
        w / 2,
        h * 0.25,
        bottom.dx,
        bottom.dy,
      );
      path.close();
      return path;
    }

    // Outer petals ring
    const outerCount = 8;
    for (var i = 0; i < outerCount; i++) {
      final t = i / outerCount;
      final angle = i * (2 * math.pi / outerCount) + 0.2;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.translate(0, -18);
      final path = petalPath(22, 36);
      // Slight color variation per petal
      petalPaint.color = Color.lerp(roseBase, roseLight, 0.25 + 0.2 * t)!;
      canvas.drawPath(path, petalPaint);
      canvas.drawPath(path, petalStroke);
      canvas.restore();
    }

    // Middle petals ring
    const middleCount = 6;
    for (var i = 0; i < middleCount; i++) {
      final t = i / middleCount;
      final angle = i * (2 * math.pi / middleCount) - 0.1;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.translate(0, -10);
      final path = petalPath(16, 26, curvature: 0.6);
      petalPaint.color = Color.lerp(roseBase, roseLight, 0.15 + 0.25 * t)!;
      canvas.drawPath(path, petalPaint);
      canvas.drawPath(path, petalStroke);
      canvas.restore();
    }

    // Inner bud: small petals + spiral stroke
    final budPaint = Paint()..color = roseBase.withValues(alpha: 0.95);
    canvas.drawCircle(center, 8, budPaint);

    // Spiral stroke to suggest rose core
    final spiral = Path();
    const turns = 3.0;
    const steps = 80;
    for (var i = 0; i <= steps; i++) {
      final p = i / steps;
      final ang = p * turns * 2 * math.pi;
      final r = 1.0 + p * 10.0;
      final x = center.dx + r * math.cos(ang);
      final y = center.dy + r * math.sin(ang);
      if (i == 0) {
        spiral.moveTo(x, y);
      } else {
        spiral.lineTo(x, y);
      }
    }
    final spiralStroke = Paint()
      ..color = roseDark.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawPath(spiral, spiralStroke);

    // Green sepals under the bud to make silhouette more rose-like
    final sepalPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;
    const sepalCount = 3;
    for (var i = 0; i < sepalCount; i++) {
      final ang = i * (2 * math.pi / sepalCount) + math.pi / 6;
      final p1 = Offset(
          center.dx + 2 * math.cos(ang), center.dy + 10 + 2 * math.sin(ang));
      final p2 = Offset(center.dx + 10 * math.cos(ang + 0.25),
          center.dy + 16 + 10 * math.sin(ang + 0.25));
      final p3 = Offset(center.dx + 10 * math.cos(ang - 0.25),
          center.dy + 16 + 10 * math.sin(ang - 0.25));
      final sepal = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..close();
      canvas.drawPath(sepal, sepalPaint);
    }

    // Stem at the end
    _drawStem(canvas, size);
  }

  @override
  bool shouldRepaint(covariant ThemedFlowerPainter oldDelegate) =>
      oldDelegate.theme != theme;
}
