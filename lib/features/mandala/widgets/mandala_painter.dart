import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/mandala_definition.dart';
import '../models/mandala_region.dart';

/// Renders a mandala using a [MandalaDefinition] and per-region color state.
///
/// Supports three rendering modes controlled by flags:
/// - Normal: outlines + fill colors + number labels on uncolored regions
/// - Highlight: pulses regions matching [highlightNumber]
/// - Export: fills only, no numbers, no highlights
class MandalaPainter extends CustomPainter {
  MandalaPainter({
    required this.definition,
    required this.regionColors,
    this.highlightNumber,
    this.highlightPhase = 0.0,
    this.showNumbers = true,
    this.exportMode = false,
    this.mode = ColoringMode.guided,
  });

  final MandalaDefinition definition;

  /// Region ID → applied color. Absent = uncolored (white).
  final Map<String, Color> regionColors;

  /// In guided mode, regions matching this number get a pulsing highlight.
  final int? highlightNumber;

  /// Animation phase for highlight pulse (0.0–1.0).
  final double highlightPhase;

  /// Whether to render numbers inside uncolored regions.
  final bool showNumbers;

  /// In export mode: no numbers, no highlights, no outlines on uncolored regions.
  final bool exportMode;

  final ColoringMode mode;

  @override
  void paint(Canvas canvas, Size size) {
    final double side = size.shortestSide;
    final double scale = side / definition.canvasSize;

    canvas.save();

    // Center the mandala: for 1000×1000 designs paths are already in
    // positive space; for 300×300 template designs paths are centered at
    // origin so we translate to center.
    if (definition.canvasSize <= 300) {
      canvas.translate(size.width / 2, size.height / 2);
    } else {
      final offset = (size.width - side) / 2;
      canvas.translate(offset, offset);
    }
    canvas.scale(scale, scale);

    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF4E342E)
      ..strokeWidth = exportMode ? 0.5 : 0.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final region in definition.regions) {
      final appliedColor = regionColors[region.id];
      final isColored = appliedColor != null;

      // Fill
      fillPaint.color = isColored ? appliedColor : Colors.white;
      canvas.drawPath(region.path, fillPaint);

      // Highlight matching regions
      if (!exportMode &&
          highlightNumber != null &&
          region.colorNumber == highlightNumber &&
          !isColored) {
        final targetColor = region.targetColor;
        canvas.drawPath(
          region.path,
          Paint()
            ..style = PaintingStyle.fill
            ..color = targetColor
                .withAlpha((35 + 25 * _pulse(highlightPhase)).round()),
        );
      }

      // Outline
      canvas.drawPath(region.path, strokePaint);

      // Number label (only on uncolored regions in non-export mode)
      if (showNumbers && !exportMode && !isColored) {
        _drawNumber(canvas, region, scale);
      }
    }

    canvas.restore();
  }

  void _drawNumber(Canvas canvas, MandalaRegion region, double canvasScale) {
    final bounds = region.path.getBounds();
    final minDim = math.min(bounds.width, bounds.height);

    // Skip numbers on very small regions — they'd be illegible.
    if (minDim < 12) return;

    final fontSize = (minDim * 0.35).clamp(8.0, 28.0);
    final center = region.center;

    final builder = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.center,
      maxLines: 1,
    ))
      ..pushStyle(ui.TextStyle(
        color: const Color(0xFF666666),
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
      ))
      ..addText('${region.colorNumber}');

    final paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: minDim));

    canvas.drawParagraph(
      paragraph,
      Offset(
        center.dx - paragraph.longestLine / 2,
        center.dy - paragraph.height / 2,
      ),
    );
  }

  /// Smooth pulse curve for highlight animation.
  double _pulse(double t) => (math.sin(t * 2 * math.pi) + 1) / 2;

  @override
  bool shouldRepaint(covariant MandalaPainter oldDelegate) {
    return !identical(definition, oldDelegate.definition) ||
        !_mapsEqual(regionColors, oldDelegate.regionColors) ||
        highlightNumber != oldDelegate.highlightNumber ||
        highlightPhase != oldDelegate.highlightPhase ||
        showNumbers != oldDelegate.showNumbers ||
        exportMode != oldDelegate.exportMode ||
        mode != oldDelegate.mode;
  }

  static bool _mapsEqual(Map<String, Color> a, Map<String, Color> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}

/// Hit-test: given a tap [point] in widget-local coordinates, find which
/// region was tapped. Returns the region ID or null.
///
/// Tests regions in reverse paint order so visually-topmost regions win.
String? hitTestMandalaRegion(
  MandalaDefinition definition,
  Offset point,
  Size size,
) {
  final double side = size.shortestSide;
  final double scale = side / definition.canvasSize;

  Offset mandalaPoint;
  if (definition.canvasSize <= 300) {
    mandalaPoint = Offset(
      (point.dx - size.width / 2) / scale,
      (point.dy - size.height / 2) / scale,
    );
  } else {
    final offset = (size.width - side) / 2;
    mandalaPoint = Offset(
      (point.dx - offset) / scale,
      (point.dy - offset) / scale,
    );
  }

  for (int i = definition.regions.length - 1; i >= 0; i--) {
    if (definition.regions[i].path.contains(mandalaPoint)) {
      return definition.regions[i].id;
    }
  }
  return null;
}
