import 'dart:math' as math;
import 'dart:ui';

/// Lado del lienzo en el que se generan las zonas; el painter lo escala.
const double kMandalaCanvas = 1000;

enum RingKind { center, segments, petals, dots, scallops }

/// Un anillo del mandala entre los radios [inner] y [outer] (0 a 1).
class RingSpec {
  const RingSpec(this.kind, this.inner, this.outer,
      {this.count = 1, this.rotation = 0, this.backing = false});

  final RingKind kind;
  final double inner, outer;
  final int count;

  /// Giro del anillo en fracciones de un segmento (0.5 = medio segmento).
  final double rotation;

  /// Agrega el aro completo detrás de pétalos o puntos, para que el fondo
  /// entre ellos también se pueda colorear.
  final bool backing;
}

class MandalaDesign {
  const MandalaDesign(this.id, this.name, this.rings);
  final String id;
  final String name;
  final List<RingSpec> rings;

  /// Zonas coloreables en coordenadas de [kMandalaCanvas], de atrás hacia
  /// adelante. Se calculan una sola vez por diseño.
  List<Path> get regions => _cache.putIfAbsent(id, () => _build(rings));
}

final _cache = <String, List<Path>>{};

const kMandalaDesigns = <MandalaDesign>[
  MandalaDesign('sol', 'Sol interior', [
    RingSpec(RingKind.segments, 0.80, 0.96, count: 24),
    RingSpec(RingKind.dots, 0.70, 0.80, count: 24, backing: true),
    RingSpec(RingKind.petals, 0.40, 0.70, count: 12, backing: true),
    RingSpec(RingKind.segments, 0.30, 0.40, count: 16),
    RingSpec(RingKind.petals, 0.10, 0.30, count: 8, backing: true),
    RingSpec(RingKind.center, 0, 0.10),
  ]),
  MandalaDesign('loto', 'Flor de loto', [
    RingSpec(RingKind.petals, 0.78, 0.96, count: 24, backing: true),
    RingSpec(RingKind.segments, 0.70, 0.78, count: 36),
    RingSpec(RingKind.scallops, 0.50, 0.70, count: 12, backing: true),
    RingSpec(RingKind.petals, 0.25, 0.50,
        count: 12, rotation: 0.5, backing: true),
    RingSpec(RingKind.petals, 0.08, 0.25, count: 6, backing: true),
    RingSpec(RingKind.center, 0, 0.08),
  ]),
  MandalaDesign('estrella', 'Estrella de calma', [
    RingSpec(RingKind.scallops, 0.70, 0.96, count: 16, backing: true),
    RingSpec(RingKind.segments, 0.62, 0.70, count: 32),
    RingSpec(RingKind.petals, 0.42, 0.62,
        count: 16, rotation: 0.5, backing: true),
    RingSpec(RingKind.scallops, 0.22, 0.42, count: 8, backing: true),
    RingSpec(RingKind.segments, 0.12, 0.22, count: 8),
    RingSpec(RingKind.center, 0, 0.12),
  ]),
  MandalaDesign('jardin', 'Jardín secreto', [
    RingSpec(RingKind.petals, 0.75, 0.96, count: 20, backing: true),
    RingSpec(RingKind.dots, 0.65, 0.75,
        count: 20, rotation: 0.5, backing: true),
    RingSpec(RingKind.petals, 0.45, 0.65,
        count: 20, rotation: 0.5, backing: true),
    RingSpec(RingKind.petals, 0.18, 0.45, count: 10, backing: true),
    RingSpec(RingKind.dots, 0.10, 0.18, count: 6, backing: true),
    RingSpec(RingKind.center, 0, 0.10),
  ]),
  MandalaDesign('luna', 'Luna nueva', [
    RingSpec(RingKind.segments, 0.88, 0.96, count: 48),
    RingSpec(RingKind.scallops, 0.68, 0.88, count: 24, backing: true),
    RingSpec(RingKind.dots, 0.58, 0.68, count: 12, backing: true),
    RingSpec(RingKind.petals, 0.30, 0.58, count: 12, backing: true),
    RingSpec(RingKind.petals, 0.30, 0.50, count: 12, rotation: 0.5),
    RingSpec(RingKind.segments, 0.14, 0.30, count: 12),
    RingSpec(RingKind.center, 0, 0.14),
  ]),
  MandalaDesign('corazon', 'Corazón en paz', [
    RingSpec(RingKind.petals, 0.72, 0.96, count: 18, backing: true),
    RingSpec(RingKind.petals, 0.72, 0.88, count: 18, rotation: 0.5),
    RingSpec(RingKind.segments, 0.60, 0.72, count: 18),
    RingSpec(RingKind.scallops, 0.36, 0.60, count: 9, backing: true),
    RingSpec(RingKind.dots, 0.26, 0.36, count: 9, rotation: 0.5, backing: true),
    RingSpec(RingKind.petals, 0.08, 0.26, count: 9, backing: true),
    RingSpec(RingKind.center, 0, 0.08),
  ]),
];

MandalaDesign? mandalaById(String id) {
  for (final d in kMandalaDesigns) {
    if (d.id == id) return d;
  }
  return null;
}

// ── Geometría ────────────────────────────────────────────────────────────────

const _c = kMandalaCanvas / 2;
const _maxR = kMandalaCanvas / 2 - 4;

Offset _polar(double r, double angle) =>
    Offset(_c + r * math.cos(angle), _c + r * math.sin(angle));

Rect _circle(double r) =>
    Rect.fromCircle(center: const Offset(_c, _c), radius: r);

/// Los anillos se declaran de afuera hacia adentro, que es también el orden
/// de dibujo: las zonas posteriores quedan encima y ganan al tocar.
List<Path> _build(List<RingSpec> rings) {
  final regions = <Path>[];
  for (final ring in rings) {
    final r0 = ring.inner * _maxR, r1 = ring.outer * _maxR;
    final step = 2 * math.pi / ring.count;
    final start = -math.pi / 2 + ring.rotation * step;

    if (ring.kind == RingKind.center) {
      regions.add(Path()..addOval(_circle(r1)));
      continue;
    }
    if (ring.backing) {
      regions.add(Path()
        ..fillType = PathFillType.evenOdd
        ..addOval(_circle(r1))
        ..addOval(_circle(r0)));
    }

    for (var i = 0; i < ring.count; i++) {
      final a0 = start + i * step, a1 = a0 + step, mid = a0 + step / 2;
      switch (ring.kind) {
        case RingKind.segments:
          regions.add(Path()
            ..arcTo(_circle(r1), a0, step, true)
            ..arcTo(_circle(r0), a1, -step, false)
            ..close());
        case RingKind.petals:
          final rm = r0 + (r1 - r0) * 0.45;
          final spread = step * 0.55;
          regions.add(Path()
            ..moveTo(_polar(r0, mid).dx, _polar(r0, mid).dy)
            ..quadraticBezierTo(
                _polar(rm, mid - spread).dx,
                _polar(rm, mid - spread).dy,
                _polar(r1, mid).dx,
                _polar(r1, mid).dy)
            ..quadraticBezierTo(
                _polar(rm, mid + spread).dx,
                _polar(rm, mid + spread).dy,
                _polar(r0, mid).dx,
                _polar(r0, mid).dy)
            ..close());
        case RingKind.dots:
          final rm = (r0 + r1) / 2;
          final radius =
              math.min((r1 - r0) / 2, rm * math.sin(step / 2)) * 0.75;
          regions.add(Path()
            ..addOval(
                Rect.fromCircle(center: _polar(rm, mid), radius: radius)));
        case RingKind.scallops:
          final p0 = _polar(r0, a0 + step * 0.04);
          final p1 = _polar(r0, a1 - step * 0.04);
          final c0 = _polar(r1 * 1.02, a0 + step * 0.1);
          final c1 = _polar(r1 * 1.02, a1 - step * 0.1);
          regions.add(Path()
            ..moveTo(p0.dx, p0.dy)
            ..cubicTo(c0.dx, c0.dy, c1.dx, c1.dy, p1.dx, p1.dy)
            ..arcTo(_circle(r0), a1 - step * 0.04, -(step * 0.92), false)
            ..close());
        case RingKind.center:
          break;
      }
    }
  }
  return regions;
}
