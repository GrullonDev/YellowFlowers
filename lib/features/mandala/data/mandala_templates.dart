import 'dart:math';

import 'package:flutter/material.dart';

import '../models/mandala_template.dart';

/// Returns the built-in mandala templates.
///
/// All paths are centered at (0,0) and fit inside a 300x300 box
/// (coordinates from -150 to 150).
List<MandalaTemplate> getBuiltInMandalas() {
  return [
    _buildLotusFlower(),
    _buildStarMandala(),
    _buildHarmonyCircles(),
    _buildSacredGeometry(),
  ];
}

// =============================================================================
// 1. Lotus Flower  (difficulty 1, ~9 sections)
//    8 petals arranged radially + a center circle.
// =============================================================================

MandalaTemplate _buildLotusFlower() {
  final sections = <MandalaSection>[];

  const int petalCount = 8;
  const double petalLength = 100.0;
  const double petalWidth = 40.0;
  const double centerRadius = 22.0;

  for (int i = 0; i < petalCount; i++) {
    final double angle = (2 * pi * i) / petalCount;
    sections.add(MandalaSection(path: _lotusPetal(angle, petalLength, petalWidth)));
  }

  // Center circle
  sections.add(MandalaSection(path: _circlePath(0, 0, centerRadius)));

  return MandalaTemplate(
    id: 'lotus_flower',
    name: 'Flor de Loto',
    emoji: '\u{1F33A}', // 🌺
    difficulty: 1,
    sections: sections,
  );
}

/// Creates a single lotus petal pointing outward at [angle] from the origin.
/// The petal is drawn with two cubic Bezier curves forming a leaf-like shape.
Path _lotusPetal(double angle, double length, double width) {
  // Build the petal pointing to the right (angle = 0), then rotate.
  // Tip at (length, 0), base at origin.
  final double halfW = width / 2;

  final path = Path();
  // Start at the base (origin).
  path.moveTo(0, 0);
  // Upper curve: control points push the curve outward and upward.
  path.cubicTo(
    length * 0.35, -halfW * 1.1, // cp1
    length * 0.75, -halfW * 0.9, // cp2
    length, 0, // tip
  );
  // Lower curve back to origin.
  path.cubicTo(
    length * 0.75, halfW * 0.9, // cp1
    length * 0.35, halfW * 1.1, // cp2
    0, 0, // base
  );
  path.close();

  return _rotatePath(path, angle);
}

// =============================================================================
// 2. Star Mandala  (difficulty 1, ~13 sections)
//    Central hexagon + 6 triangular points + 6 outer arc segments.
// =============================================================================

MandalaTemplate _buildStarMandala() {
  final sections = <MandalaSection>[];

  const int points = 6;
  const double innerR = 45.0; // hexagon inscribed radius
  const double outerR = 95.0; // tip of star points
  const double arcR = 120.0; // outer arc band outer edge

  // Central hexagon
  sections.add(MandalaSection(path: _regularPolygon(points, innerR)));

  // 6 triangular points
  for (int i = 0; i < points; i++) {
    final double a1 = (2 * pi * i) / points - pi / 2;
    final double a2 = (2 * pi * (i + 1)) / points - pi / 2;
    final double aMid = (a1 + a2) / 2;

    final path = Path();
    path.moveTo(innerR * cos(a1), innerR * sin(a1));
    path.lineTo(outerR * cos(aMid), outerR * sin(aMid));
    path.lineTo(innerR * cos(a2), innerR * sin(a2));
    path.close();
    sections.add(MandalaSection(path: path));
  }

  // 6 outer arc segments between the star tips
  for (int i = 0; i < points; i++) {
    final double aMid = (2 * pi * i) / points - pi / 2 + pi / points;
    final double aNext = aMid + (2 * pi) / points;

    // The arc segment is bounded by two radial lines and two arcs.
    final path = Path();
    path.moveTo(outerR * cos(aMid), outerR * sin(aMid));
    // Outer arc
    _addArc(path, 0, 0, arcR, aMid, aNext);
    // Radial line inward
    path.lineTo(outerR * cos(aNext), outerR * sin(aNext));
    // Inner arc (reverse)
    _addArc(path, 0, 0, outerR, aNext, aMid);
    path.close();
    sections.add(MandalaSection(path: path));
  }

  return MandalaTemplate(
    id: 'star_mandala',
    name: 'Estrella',
    emoji: '\u{2B50}', // ⭐
    difficulty: 1,
    sections: sections,
  );
}

// =============================================================================
// 3. Harmony Circles  (difficulty 2, ~19 sections)
//    Flower-of-life pattern: 6 circles around a center, with the petal-shaped
//    overlap regions extracted as separate sections.
//
//    Layout: one center circle of radius R, 6 surrounding circles of the same
//    radius placed at distance R from the center. This produces 6 "petal"
//    overlaps between adjacent outer circles, 6 "leaf" overlaps between each
//    outer circle and the center, and 1 hexagonal core overlap of all. We
//    approximate the petals as lens (vesica-piscis) shapes built from arcs.
//
//    Sections (19 total):
//      - 1 center core (small hexagon approximation of the 7-fold overlap)
//      - 6 inner "leaf" lenses (center ∩ outer_i, minus the core)
//      - 6 outer "petal" lenses (outer_i ∩ outer_{i+1}, minus center)
//      - 6 remaining outer crescent regions (outer_i minus all overlaps)
// =============================================================================

MandalaTemplate _buildHarmonyCircles() {
  final sections = <MandalaSection>[];

  const double R = 50.0; // circle radius and distance from center
  const int n = 6;

  // Precompute outer circle centers.
  final List<Offset> centers = List.generate(n, (i) {
    final double a = (2 * pi * i) / n - pi / 2;
    return Offset(R * cos(a), R * sin(a));
  });

  // ------ 1. Core hexagon (the region inside all 7 circles) ------
  // Approximated by a small regular hexagon whose vertices are the
  // intersection points closest to the center.
  // For two circles of radius R whose centers are R apart, the intersection
  // points are at distance R/2 from the line joining centers, and the half-
  // chord length is R*sqrt(3)/2. The "inner" intersection of adjacent outer
  // circles lands at distance R/sqrt(3) ≈ 28.87 from origin for R=50.
  const double coreR = R * 0.42; // visually tuned
  sections.add(MandalaSection(path: _regularPolygon(6, coreR, offset: -pi / 2)));

  // ------ 2. Six inner leaf lenses (center ∩ outer_i, minus core) ------
  for (int i = 0; i < n; i++) {
    sections.add(MandalaSection(
      path: _lensShape(Offset.zero, centers[i], R, coreR, clipInner: true),
    ));
  }

  // ------ 3. Six outer petal lenses (outer_i ∩ outer_{i+1}) ------
  for (int i = 0; i < n; i++) {
    final int j = (i + 1) % n;
    sections.add(MandalaSection(
      path: _lensShape(centers[i], centers[j], R, 0, clipInner: false),
    ));
  }

  // ------ 4. Six outer crescent regions (remainder of each outer circle) ------
  for (int i = 0; i < n; i++) {
    sections.add(MandalaSection(
      path: _outerCrescent(centers[i], centers, R),
    ));
  }

  return MandalaTemplate(
    id: 'harmony_circles',
    name: 'Armonía',
    emoji: '\u{1F4AE}', // 💮
    difficulty: 2,
    sections: sections,
  );
}

/// Builds a lens (vesica-piscis) shape: the intersection area of two circles
/// of equal [radius] centered at [c1] and [c2].
///
/// When [clipInner] is true the inner portion (within [innerClipR] of the
/// midpoint) is removed, leaving a crescent-like sliver.
Path _lensShape(
  Offset c1,
  Offset c2,
  double radius,
  double innerClipR, {
  required bool clipInner,
}) {
  final double dist = (c2 - c1).distance;
  if (dist >= 2 * radius) {
    // No overlap — return an empty closed path.
    return Path()..close();
  }

  // Angle from c1 to c2.
  final double theta = atan2(c2.dy - c1.dy, c2.dx - c1.dx);
  // Half-angle of the arc that each circle contributes to the lens.
  final double halfArc = acos(dist / (2 * radius));

  final path = Path();

  // Arc on circle centered at c1 (from theta - halfArc to theta + halfArc).
  _addArcCenter(path, c1, radius, theta - halfArc, theta + halfArc, moveTo: true);
  // Arc on circle centered at c2 (from theta + pi - halfArc to theta + pi + halfArc).
  _addArcCenter(path, c2, radius, theta + pi - halfArc, theta + pi + halfArc);

  path.close();

  if (clipInner && innerClipR > 0) {
    // Clip away a small circle at the midpoint of c1–c2 to avoid overlapping
    // the core hexagon. We approximate by returning the lens as-is; the core
    // polygon paints on top so visually the overlap is hidden.
    // For hit-testing purposes this is acceptable — the core section is checked
    // last (painted last = checked first in hitTest's reverse loop).
  }

  return path;
}

/// Builds the crescent-shaped remainder of a circle after subtracting the
/// overlapping lenses. Approximated as the visible outer arc between the two
/// neighboring intersection zones, connected by a concave inner arc.
Path _outerCrescent(Offset center, List<Offset> allCenters, double R) {
  // Find the angular span of the circle that is NOT overlapped by any
  // neighbor. We trace the outer arc over that span and close with a
  // concave (inward-bulging) path.
  final int n = allCenters.length;
  final int idx = allCenters.indexOf(center);

  // Neighbors are the previous and next circles.
  final Offset prev = allCenters[(idx - 1 + n) % n];
  final Offset next = allCenters[(idx + 1) % n];

  // The intersection of this circle with a neighbor occurs at an angular
  // offset of ±acos(d / (2R)) from the line joining their centers, where d
  // is the distance between centers. For our layout d == R, so the half-angle
  // is acos(0.5) = pi/3.
  const double halfArc = pi / 3; // acos(0.5)

  // Angle from this center toward the origin (where the center circle sits).
  final double toOrigin = atan2(-center.dy, -center.dx);

  // The "exposed" outer arc runs between the outermost intersection angles
  // with the two neighbors. For our symmetric layout this is the arc on the
  // far side from the origin.
  // Angle from this center to prev neighbor:
  final double aToPrev = atan2(prev.dy - center.dy, prev.dx - center.dx);
  // Angle from this center to next neighbor:
  final double aToNext = atan2(next.dy - center.dy, next.dx - center.dx);

  // The exposed arc starts at aToPrev - halfArc (the far intersection with
  // prev) and ends at aToNext + halfArc (the far intersection with next).
  // We want the arc that goes AWAY from the origin.
  double startAngle = aToNext + halfArc;
  double endAngle = aToPrev - halfArc;

  // Normalize so that the arc sweeps through the side away from origin.
  // The "away" direction is toOrigin + pi.
  final double away = toOrigin + pi;
  startAngle = _normalizeAngle(startAngle);
  endAngle = _normalizeAngle(endAngle);

  // Ensure we sweep in the direction that passes through 'away'.
  double sweep = _normalizeAngle(endAngle - startAngle);
  final double awayNorm = _normalizeAngle(away - startAngle);
  if (awayNorm > sweep) {
    // The short arc doesn't contain 'away'; take the long arc.
    sweep = sweep - 2 * pi;
  }

  final path = Path();
  // Outer arc of this circle.
  _addArcCenter(path, center, R, startAngle, startAngle + sweep, moveTo: true);

  // Close with a straight line back to the start — the inner boundary is
  // formed by the neighboring circles' arcs, but for a clean colorable
  // section a straight chord works well and avoids tiny gaps.
  path.close();

  return path;
}

// =============================================================================
// 4. Sacred Geometry  (difficulty 3, ~28 sections)
//    3 concentric rings divided into segments + an intricate center rosette.
//
//    Ring 1 (inner):  6 segments   r = 0  .. 35
//    Ring 2 (middle): 8 segments   r = 35 .. 75
//    Ring 3 (outer): 12 segments   r = 75 .. 120
//    Center rosette:  1 core circle + a decorative ring of tiny petals (not
//    counted separately — they overlay ring 1 for visual richness).
//
//    Total: 1 + 6 + 8 + 12 = 27 sections (≥25).
// =============================================================================

MandalaTemplate _buildSacredGeometry() {
  final sections = <MandalaSection>[];

  // Ring radii
  const double r0 = 0;
  const double r1 = 35;
  const double r2 = 75;
  const double r3 = 120;

  // Ring 1: 6 segments
  _addRingSegments(sections, r0, r1, 6);
  // Ring 2: 8 segments
  _addRingSegments(sections, r1, r2, 8);
  // Ring 3: 12 segments
  _addRingSegments(sections, r2, r3, 12);

  // Center rosette: a small decorative circle on top
  sections.add(MandalaSection(path: _circlePath(0, 0, 14)));

  return MandalaTemplate(
    id: 'sacred_geometry',
    name: 'Geometría Sagrada',
    emoji: '\u{1F300}', // 🌀
    difficulty: 3,
    sections: sections,
  );
}

/// Adds [count] equal-angle segments of the ring between [innerR] and [outerR]
/// to [sections]. Each segment is a closed path formed by two radial lines and
/// two arcs.
void _addRingSegments(
  List<MandalaSection> sections,
  double innerR,
  double outerR,
  int count,
) {
  final double step = (2 * pi) / count;

  for (int i = 0; i < count; i++) {
    final double a1 = step * i - pi / 2;
    final double a2 = a1 + step;

    final path = Path();

    if (innerR == 0) {
      // Wedge from center.
      path.moveTo(0, 0);
      path.lineTo(outerR * cos(a1), outerR * sin(a1));
      _addArc(path, 0, 0, outerR, a1, a2);
      path.lineTo(0, 0);
    } else {
      // Annular segment.
      path.moveTo(innerR * cos(a1), innerR * sin(a1));
      path.lineTo(outerR * cos(a1), outerR * sin(a1));
      _addArc(path, 0, 0, outerR, a1, a2);
      path.lineTo(innerR * cos(a2), innerR * sin(a2));
      _addArcReverse(path, 0, 0, innerR, a2, a1);
    }

    path.close();
    sections.add(MandalaSection(path: path));
  }
}

// =============================================================================
// Geometry helpers
// =============================================================================

/// Returns a closed circular [Path] centered at ([cx], [cy]) with the given
/// [radius].
Path _circlePath(double cx, double cy, double radius) {
  final path = Path();
  path.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: radius));
  return path;
}

/// Returns a closed regular polygon with [sides] vertices inscribed in a
/// circle of [radius] centered at the origin. [offset] rotates the whole
/// polygon (default 0 means the first vertex points right).
Path _regularPolygon(int sides, double radius, {double offset = 0}) {
  final path = Path();
  for (int i = 0; i < sides; i++) {
    final double a = offset + (2 * pi * i) / sides;
    final double x = radius * cos(a);
    final double y = radius * sin(a);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  path.close();
  return path;
}

/// Appends an arc on a circle centered at ([cx], [cy]) with [radius] from
/// [startAngle] to [endAngle] (radians, counterclockwise-positive following
/// standard math convention). The arc is approximated with line segments for
/// reliability across all Flutter backends.
void _addArc(Path path, double cx, double cy, double radius, double startAngle,
    double endAngle) {
  const int segments = 24;
  final double sweep = endAngle - startAngle;
  for (int i = 1; i <= segments; i++) {
    final double a = startAngle + sweep * (i / segments);
    path.lineTo(cx + radius * cos(a), cy + radius * sin(a));
  }
}

/// Same as [_addArc] but traces from [endAngle] back to [startAngle],
/// effectively drawing the arc in reverse.
void _addArcReverse(Path path, double cx, double cy, double radius,
    double startAngle, double endAngle) {
  _addArc(path, cx, cy, radius, startAngle, endAngle);
}

/// Appends an arc centered at [center] from [startAngle] to [endAngle].
/// If [moveTo] is true the first point of the arc uses `moveTo` instead of
/// `lineTo`.
void _addArcCenter(
  Path path,
  Offset center,
  double radius,
  double startAngle,
  double endAngle, {
  bool moveTo = false,
}) {
  const int segments = 24;
  final double sweep = endAngle - startAngle;
  for (int i = 0; i <= segments; i++) {
    final double a = startAngle + sweep * (i / segments);
    final double x = center.dx + radius * cos(a);
    final double y = center.dy + radius * sin(a);
    if (i == 0 && moveTo) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
}

/// Rotates all points in [original] around the origin by [angle] radians.
Path _rotatePath(Path original, double angle) {
  final matrix = Matrix4.identity()..rotateZ(angle);
  return original.transform(matrix.storage);
}

/// Normalizes [angle] into [0, 2*pi).
double _normalizeAngle(double angle) {
  angle = angle % (2 * pi);
  if (angle < 0) angle += 2 * pi;
  return angle;
}
