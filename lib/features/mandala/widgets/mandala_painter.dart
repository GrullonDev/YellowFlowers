import 'package:flutter/material.dart';

import '../models/mandala_template.dart';

/// Renders a [MandalaTemplate] on a canvas, filling each section with its
/// current color and drawing a thin outline on top.
///
/// The mandala paths are authored in a 300x300 coordinate space centered at
/// (0,0). The painter translates and scales them to fit the provided [size],
/// keeping aspect ratio 1:1 and centering the result.
class MandalaPainter extends CustomPainter {
  MandalaPainter({required this.template})
      : _colorSnapshot =
            template.sections.map((s) => s.color).toList(growable: false);

  final MandalaTemplate template;

  /// Snapshot of every section's color at the time this painter was created.
  /// Used by [shouldRepaint] to detect color changes without comparing Path
  /// objects.
  final List<Color> _colorSnapshot;

  @override
  void paint(Canvas canvas, Size size) {
    final double side = size.shortestSide;
    // The mandala lives in [-150, 150] on both axes (300 wide).
    final double scale = side / 300.0;

    canvas.save();
    // Center the mandala in the available area.
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale, scale);

    final fillPaint = Paint()..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF4E342E) // warm dark brown, matches app palette
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final section in template.sections) {
      fillPaint.color = section.color;
      canvas.drawPath(section.path, fillPaint);
      canvas.drawPath(section.path, strokePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MandalaPainter oldDelegate) {
    if (identical(template, oldDelegate.template) &&
        _colorsEqual(oldDelegate._colorSnapshot)) {
      return false;
    }
    return true;
  }

  bool _colorsEqual(List<Color> other) {
    if (_colorSnapshot.length != other.length) return false;
    for (int i = 0; i < _colorSnapshot.length; i++) {
      if (_colorSnapshot[i] != other[i]) return false;
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Hit-testing
  // ---------------------------------------------------------------------------

  /// Given a tap [point] in the widget's local coordinate space and the
  /// widget's [size], returns the index of the tapped [MandalaSection], or
  /// -1 if the tap landed outside every section.
  ///
  /// Sections are tested in reverse order so that sections painted later
  /// (visually on top) take priority.
  static int sectionHitTest(MandalaTemplate template, Offset point, Size size) {
    final double side = size.shortestSide;
    final double scale = side / 300.0;

    // Convert the tap point from widget-local coordinates into the mandala's
    // own coordinate space (centered at origin, 300x300).
    final Offset mandalaPoint = Offset(
      (point.dx - size.width / 2) / scale,
      (point.dy - size.height / 2) / scale,
    );

    // Walk backwards so the topmost painted section wins.
    for (int i = template.sections.length - 1; i >= 0; i--) {
      if (template.sections[i].path.contains(mandalaPoint)) {
        return i;
      }
    }
    return -1;
  }
}
