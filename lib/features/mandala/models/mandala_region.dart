import 'dart:ui';

/// A single colorable region within a mandala definition.
///
/// Regions are immutable geometry — mutable coloring state lives in
/// [MandalaColoringState]. Each region carries a stable [id] that persists
/// across sessions so saved progress can be restored reliably.
class MandalaRegion {
  const MandalaRegion({
    required this.id,
    required this.path,
    required this.colorNumber,
    required this.targetColor,
    required this.center,
  });

  /// Stable identifier derived from design structure, not list index.
  final String id;

  /// The closed path defining this region's shape in design-space coordinates.
  final Path path;

  /// The 1-based number shown inside uncolored regions in guided mode.
  final int colorNumber;

  /// The correct color for this region in guided (color-by-number) mode.
  final Color targetColor;

  /// Approximate visual center of the region, used for number placement.
  final Offset center;
}
