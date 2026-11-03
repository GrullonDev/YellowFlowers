import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:yellow_flowers/features/mandala/data/mandala_catalog.dart';
import 'package:yellow_flowers/features/mandala/data/mandala_designs.dart';
import 'package:yellow_flowers/features/mandala/models/coloring_state.dart';
import 'package:yellow_flowers/features/mandala/widgets/mandala_painter.dart';

void main() {
  // ── Design uniqueness ──────────────────────────────────────────────────

  test('design ids are unique', () {
    final ids = kMandalaDesigns.map((d) => d.id).toSet();
    expect(ids.length, kMandalaDesigns.length);
  });

  test('all definitions have unique IDs', () {
    final defs = getMandalaDefinitions();
    final ids = defs.map((d) => d.id).toSet();
    expect(ids.length, defs.length);
  });

  test('catalog returns all 10 designs', () {
    final defs = getMandalaDefinitions();
    expect(defs.length, 10);
  });

  // ── Hit-testing on ring-based designs ──────────────────────────────────

  for (final design in kMandalaDesigns) {
    test('${design.id}: center tap hits a region', () {
      final def = definitionById(design.id)!;
      const center = Offset(500, 500);
      const size = Size(1000, 1000);
      final hit = hitTestMandalaRegion(def, center, size);
      expect(hit, isNotNull);
    });

    test('${design.id}: corner tap hits nothing', () {
      final def = definitionById(design.id)!;
      const corner = Offset(2, 2);
      const size = Size(1000, 1000);
      final hit = hitTestMandalaRegion(def, corner, size);
      expect(hit, isNull);
    });

    test('${design.id}: most of the disc is colorable', () {
      final def = definitionById(design.id)!;
      const canvasSize = 1000.0;
      const size = Size(canvasSize, canvasSize);
      var inside = 0, hits = 0;
      for (var x = 0; x < canvasSize; x += 20) {
        for (var y = 0; y < canvasSize; y += 20) {
          final p = Offset(x.toDouble(), y.toDouble());
          if ((p - const Offset(500, 500)).distance > 460) continue;
          inside++;
          if (hitTestMandalaRegion(def, p, size) != null) hits++;
        }
      }
      expect(hits / inside, greaterThan(0.85));
    });
  }

  // ── Region IDs stable and unique ───────────────────────────────────────

  for (final def in getMandalaDefinitions()) {
    test('${def.id}: region IDs are unique', () {
      final ids = def.regions.map((r) => r.id).toSet();
      expect(ids.length, def.regions.length);
    });

    test('${def.id}: all regions have valid color numbers', () {
      final validNumbers = def.palette.map((p) => p.number).toSet();
      for (final region in def.regions) {
        expect(validNumbers, contains(region.colorNumber),
            reason:
                'Region ${region.id} has invalid colorNumber ${region.colorNumber}');
      }
    });

    test('${def.id}: palette numbers are sequential from 1', () {
      for (var i = 0; i < def.palette.length; i++) {
        expect(def.palette[i].number, i + 1);
      }
    });
  }

  // ── Coloring state ─────────────────────────────────────────────────────

  group('MandalaColoringState', () {
    test('apply and undo color', () {
      final state = MandalaColoringState(designId: 'test');
      state.applyColor('r1', const Color(0xFFFF0000));
      expect(state.coloredRegions['r1'], const Color(0xFFFF0000));
      expect(state.canUndo, true);

      state.undo();
      expect(state.coloredRegions.containsKey('r1'), false);
      expect(state.canUndo, false);
    });

    test('redo restores color', () {
      final state = MandalaColoringState(designId: 'test');
      state.applyColor('r1', const Color(0xFFFF0000));
      state.undo();
      expect(state.canRedo, true);

      state.redo();
      expect(state.coloredRegions['r1'], const Color(0xFFFF0000));
    });

    test('new action clears redo stack', () {
      final state = MandalaColoringState(designId: 'test');
      state.applyColor('r1', const Color(0xFFFF0000));
      state.undo();
      state.applyColor('r2', const Color(0xFF00FF00));
      expect(state.canRedo, false);
    });

    test('erase removes color (null)', () {
      final state = MandalaColoringState(designId: 'test');
      state.applyColor('r1', const Color(0xFFFF0000));
      state.applyColor('r1', null);
      expect(state.coloredRegions.containsKey('r1'), false);
    });

    test('reset clears everything', () {
      final state = MandalaColoringState(designId: 'test');
      state.applyColor('r1', const Color(0xFFFF0000));
      state.applyColor('r2', const Color(0xFF00FF00));
      state.reset();
      expect(state.coloredRegions, isEmpty);
      expect(state.canUndo, false);
      expect(state.canRedo, false);
    });

    test('progress calculates correctly', () {
      final state = MandalaColoringState(designId: 'test');
      state.applyColor('r1', const Color(0xFFFF0000));
      state.applyColor('r2', const Color(0xFF00FF00));
      expect(state.progress(10), 0.2);
      expect(state.progress(2), 1.0);
      expect(state.isComplete(2), true);
      expect(state.isComplete(3), false);
    });

    test('applying same color is a no-op', () {
      final state = MandalaColoringState(designId: 'test');
      state.applyColor('r1', const Color(0xFFFF0000));
      state.applyColor('r1', const Color(0xFFFF0000));
      expect(state.undoStack.length, 1);
    });
  });

  // ── Hit-testing at different canvas sizes ──────────────────────────────

  test('hit-testing works at various canvas sizes', () {
    final def = definitionById('sol')!;
    for (final sz in [300.0, 500.0, 1000.0, 2000.0]) {
      final center = Offset(sz / 2, sz / 2);
      final hit = hitTestMandalaRegion(def, center, Size(sz, sz));
      expect(hit, isNotNull, reason: 'Center tap failed at size $sz');
    }
  });

  // ── Template-based designs ─────────────────────────────────────────────

  test('template designs have valid hit testing', () {
    final def = definitionById('lotus_flower')!;
    const size = Size(300, 300);
    final center = hitTestMandalaRegion(def, const Offset(150, 150), size);
    expect(center, isNotNull);
  });
}
