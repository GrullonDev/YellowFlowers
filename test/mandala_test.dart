import 'package:flutter_test/flutter_test.dart';

import 'package:yellow_flowers/features/mandala/data/mandala_designs.dart';
import 'package:yellow_flowers/features/mandala/widgets/mandala_painter.dart';

void main() {
  test('design ids are unique', () {
    final ids = kMandalaDesigns.map((d) => d.id).toSet();
    expect(ids.length, kMandalaDesigns.length);
  });

  for (final design in kMandalaDesigns) {
    test('${design.id}: center tap hits the center circle', () {
      final regions = design.regions;
      expect(regions, isNotEmpty);
      // El centro es el último anillo declarado, así que queda encima.
      final hit = hitMandalaRegion(design, const Offset(150, 150), 300);
      expect(hit, regions.length - 1);
    });

    test('${design.id}: taps outside the mandala hit nothing', () {
      expect(hitMandalaRegion(design, const Offset(2, 2), 300), isNull);
    });

    test('${design.id}: most of the disc is colorable', () {
      // Muestrea una cuadrícula dentro del círculo: casi todo punto debe
      // caer en alguna zona (las líneas del contorno pueden quedar fuera).
      var inside = 0, hits = 0;
      for (var x = 0; x < 300; x += 6) {
        for (var y = 0; y < 300; y += 6) {
          final p = Offset(x.toDouble(), y.toDouble());
          if ((p - const Offset(150, 150)).distance > 140) continue;
          inside++;
          if (hitMandalaRegion(design, p, 300) != null) hits++;
        }
      }
      expect(hits / inside, greaterThan(0.9));
    });
  }
}
