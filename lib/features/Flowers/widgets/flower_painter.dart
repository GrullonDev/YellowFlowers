import 'dart:math' as math;
import 'package:flutter/material.dart';

class FlorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // 1. TALLO DINÁMICO (High-End)
    final talloPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF1B5E20).withAlpha(200), const Color(0xFF4CAF50).withAlpha(150)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(center.dx - 2, center.dy, 4, size.height - center.dy))
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final talloPath = Path();
    talloPath.moveTo(center.dx, center.dy + 15);
    talloPath.quadraticBezierTo(
      center.dx + 15, center.dy + size.height * 0.25,
      center.dx - 5, size.height,
    );
    canvas.drawPath(talloPath, talloPaint);

    // 2. PÉTALOS (Capa Inferior - Sombras y Profundidad)
    final petalSombraPaint = Paint()..color = const Color(0xFFD4AF37).withAlpha(80)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    
    for (var i = 0; i < 6; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * math.pi / 3 + 0.1);
      canvas.drawOval(Rect.fromCenter(center: const Offset(3, -28), width: 22, height: 52), petalSombraPaint);
      canvas.restore();
    }

    // 3. PÉTALOS (Capa Principal con Gradiente Complejo)
    final petalPaint = Paint();
    
    for (var i = 0; i < 6; i++) {
      final rect = Rect.fromCenter(center: const Offset(0, -30), width: 24, height: 56);
      petalPaint.shader = RadialGradient(
        colors: [
          const Color(0xFFFFF9C4), // Brillo central
          const Color(0xFFFFD54F), // Cuerpo
          const Color(0xFFFFA000).withAlpha(220), // Borde profundo
        ],
        stops: const [0.0, 0.4, 1.0],
        center: Alignment.topCenter,
        radius: 1.2,
      ).createShader(rect);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * math.pi / 3);
      
      // Dibujar pétalo con forma orgánica (Path en lugar de Oval)
      final petalPath = Path();
      petalPath.moveTo(0, 0);
      petalPath.quadraticBezierTo(-12, -15, -12, -30);
      petalPath.quadraticBezierTo(-12, -56, 0, -60);
      petalPath.quadraticBezierTo(12, -56, 12, -30);
      petalPath.quadraticBezierTo(12, -15, 0, 0);
      petalPath.close();
      
      canvas.drawPath(petalPath, petalPaint);

      // Venas del pétalo (Líneas sutiles)
      final venaPaint = Paint()..color = Colors.white.withAlpha(50)..strokeWidth = 0.8..style = PaintingStyle.stroke;
      canvas.drawLine(const Offset(0, -5), const Offset(0, -45), venaPaint);
      canvas.drawLine(const Offset(0, -15), const Offset(-6, -35), venaPaint);
      canvas.drawLine(const Offset(0, -15), const Offset(6, -35), venaPaint);
      
      canvas.restore();
    }

    // 4. CENTRO FLORAL (Nivel Macro)
    final centroPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF422100), // Centro profundo
          const Color(0xFFE65100), // Medio
          const Color(0xFFFB8C00), // Brillo exterior
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 18));
    
    canvas.drawCircle(center, 18, centroPaint);
    
    // Puntos de polen (Acentúan el detalle)
    final polenPaint = Paint()..color = Colors.white.withAlpha(120);
    for (int p = 0; p < 8; p++) {
      final angle = p * math.pi / 4;
      canvas.drawCircle(
        Offset(center.dx + math.cos(angle) * 10, center.dy + math.sin(angle) * 10),
        1.5,
        polenPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
