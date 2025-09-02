import 'package:flutter/material.dart';
import 'dart:math' as math;

class FlorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
  // Paleta más suave y elegante
  final petaloPaint = Paint()..color = const Color(0xFFFFE07D); // amarillo suave
  final centroPaint = Paint()..color = const Color(0xFFFFB347); // naranja durazno
  final talloPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2;

    // Dibujar pétalos
    for (var i = 0; i < 6; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * math.pi / 3);
      canvas.drawOval(
        Rect.fromCenter(
          center: const Offset(0, -20),
          width: 15,
          height: 35,
        ),
        petaloPaint,
      );
      canvas.restore();
    }

    // Dibujar centro
    canvas.drawCircle(center, 15, centroPaint);

    // Dibujar tallo
    canvas.drawLine(center, Offset(center.dx, size.height), talloPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
