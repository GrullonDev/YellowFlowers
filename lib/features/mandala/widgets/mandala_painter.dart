import 'package:flutter/material.dart';

import 'package:yellow_flowers/features/mandala/data/mandala_designs.dart';

const kMandalaInk = Color(0xFF4A3466);
const kMandalaPaper = Color(0xFFFFFDF7);

/// Dibuja un mandala con sus zonas coloreadas y el contorno encima.
class MandalaPainter extends CustomPainter {
  MandalaPainter(this.design, this.colors, {this.version = 0});

  final MandalaDesign design;
  final Map<int, Color> colors;

  /// Cambia con cada trazo, para repintar aunque el mapa sea el mismo objeto.
  final int version;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / kMandalaCanvas;
    canvas.save();
    canvas.scale(scale);

    final regions = design.regions;
    final fill = Paint()..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(kMandalaCanvas / 2, kMandalaCanvas / 2),
        kMandalaCanvas / 2, fill..color = kMandalaPaper);
    for (var i = 0; i < regions.length; i++) {
      canvas.drawPath(regions[i], fill..color = colors[i] ?? kMandalaPaper);
    }

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeJoin = StrokeJoin.round
      ..color = kMandalaInk;
    for (final region in regions) {
      canvas.drawPath(region, stroke);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(MandalaPainter old) =>
      old.design.id != design.id ||
      old.version != version ||
      !identical(old.colors, colors);
}

/// Zona bajo [local] (en coordenadas del widget de lado [side]), o null.
int? hitMandalaRegion(MandalaDesign design, Offset local, double side) {
  final point = local * (kMandalaCanvas / side);
  final regions = design.regions;
  for (var i = regions.length - 1; i >= 0; i--) {
    if (regions[i].contains(point)) return i;
  }
  return null;
}
