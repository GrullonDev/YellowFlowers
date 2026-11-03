import 'dart:ui';

import 'mandala_definition.dart';

/// A single coloring action, used for undo/redo.
class ColorAction {
  const ColorAction({
    required this.regionId,
    required this.previousColor,
    required this.newColor,
  });

  final String regionId;

  /// `null` means the region was uncolored before this action.
  final Color? previousColor;

  /// `null` means the region was erased by this action.
  final Color? newColor;
}

/// Mutable coloring progress for one mandala, kept separate from the
/// immutable [MandalaDefinition].
class MandalaColoringState {
  MandalaColoringState({
    required this.designId,
    this.mode = ColoringMode.guided,
    Map<String, Color>? coloredRegions,
  }) : coloredRegions = coloredRegions ?? {};

  final String designId;
  ColoringMode mode;

  /// Region ID → applied color. Absent keys are uncolored.
  final Map<String, Color> coloredRegions;

  final List<ColorAction> undoStack = [];
  final List<ColorAction> redoStack = [];

  /// Whether persisted data has changed since last save.
  bool dirty = false;

  /// Apply a color to a region, pushing to the undo stack.
  void applyColor(String regionId, Color? color) {
    final previous = coloredRegions[regionId];
    if (previous == color) return;

    undoStack.add(ColorAction(
      regionId: regionId,
      previousColor: previous,
      newColor: color,
    ));
    redoStack.clear();

    if (color != null) {
      coloredRegions[regionId] = color;
    } else {
      coloredRegions.remove(regionId);
    }
    dirty = true;
  }

  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;

  void undo() {
    if (!canUndo) return;
    final action = undoStack.removeLast();
    redoStack.add(action);
    if (action.previousColor != null) {
      coloredRegions[action.regionId] = action.previousColor!;
    } else {
      coloredRegions.remove(action.regionId);
    }
    dirty = true;
  }

  void redo() {
    if (!canRedo) return;
    final action = redoStack.removeLast();
    undoStack.add(action);
    if (action.newColor != null) {
      coloredRegions[action.regionId] = action.newColor!;
    } else {
      coloredRegions.remove(action.regionId);
    }
    dirty = true;
  }

  void reset() {
    coloredRegions.clear();
    undoStack.clear();
    redoStack.clear();
    dirty = true;
  }

  /// Completion ratio (0.0–1.0) for a given definition's total region count.
  double progress(int totalRegions) {
    if (totalRegions == 0) return 0.0;
    return coloredRegions.length / totalRegions;
  }

  bool isComplete(int totalRegions) => coloredRegions.length >= totalRegions;
}
