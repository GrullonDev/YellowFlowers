import 'dart:ui';

import 'mandala_region.dart';

/// A numbered color entry in a mandala's palette.
class NumberedColor {
  const NumberedColor({
    required this.number,
    required this.color,
    required this.name,
  });

  final int number;
  final Color color;
  final String name;
}

enum ColoringMode { guided, free }

/// An immutable mandala definition: geometry, palette, and metadata.
///
/// All mutable coloring state is kept in [MandalaColoringState] instead.
class MandalaDefinition {
  const MandalaDefinition({
    required this.id,
    required this.name,
    required this.emoji,
    required this.difficulty,
    required this.canvasSize,
    required this.regions,
    required this.palette,
  });

  final String id;
  final String name;
  final String emoji;

  /// 1 = simple, 2 = medium, 3 = complex.
  final int difficulty;

  /// Side length of the square coordinate space the paths live in.
  final double canvasSize;

  /// Ordered list of colorable regions (back-to-front paint order).
  final List<MandalaRegion> regions;

  /// The numbered color palette for this mandala's color-by-number mode.
  final List<NumberedColor> palette;

  /// How many distinct color numbers this mandala uses.
  int get colorCount => palette.length;

  /// All region IDs that belong to [colorNumber].
  List<String> regionIdsForNumber(int colorNumber) {
    return regions
        .where((r) => r.colorNumber == colorNumber)
        .map((r) => r.id)
        .toList();
  }
}
