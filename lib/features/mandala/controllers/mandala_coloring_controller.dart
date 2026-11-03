import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/mandala_store.dart';
import '../models/coloring_state.dart';
import '../models/mandala_definition.dart';
import '../models/mandala_region.dart';

/// Manages all coloring state for a single mandala session.
///
/// Handles color selection, region validation, undo/redo, mode switching,
/// and debounced auto-saving through [MandalaStore].
class MandalaColoringController extends ChangeNotifier {
  MandalaColoringController({
    required this.definition,
    required MandalaStore store,
  }) : _store = store {
    _loadSavedProgress();
  }

  final MandalaDefinition definition;
  final MandalaStore _store;

  late MandalaColoringState _state = MandalaColoringState(
    designId: definition.id,
  );

  /// Snapshot of current region colors for painting. Read-only view.
  Map<String, Color> get coloredRegions =>
      Map.unmodifiable(_state.coloredRegions);

  /// Currently selected palette number (1-based), or null for eraser.
  int? _selectedNumber;
  int? get selectedNumber => _selectedNumber;

  /// The currently selected color (derived from number), or null for eraser.
  Color? get selectedColor {
    if (_selectedNumber == null) return null;
    final idx = _selectedNumber! - 1;
    if (idx < 0 || idx >= definition.palette.length) return null;
    return definition.palette[idx].color;
  }

  ColoringMode get mode => _state.mode;
  bool get canUndo => _state.canUndo;
  bool get canRedo => _state.canRedo;
  int get coloredCount => _state.coloredRegions.length;
  int get totalRegions => definition.regions.length;
  double get progress => _state.progress(totalRegions);
  bool get isComplete => _state.isComplete(totalRegions);

  /// The color applied to a region, or null if uncolored.
  Color? colorForRegion(String regionId) => _state.coloredRegions[regionId];

  /// Whether a region is colored.
  bool isRegionColored(String regionId) =>
      _state.coloredRegions.containsKey(regionId);

  /// How many uncolored regions remain for a given color number.
  int remainingForNumber(int number) {
    return definition.regions
        .where((r) =>
            r.colorNumber == number && !_state.coloredRegions.containsKey(r.id))
        .length;
  }

  void selectNumber(int? number) {
    if (_selectedNumber == number) return;
    _selectedNumber = number;
    notifyListeners();
  }

  void switchMode(ColoringMode newMode) {
    if (_state.mode == newMode) return;
    _state.mode = newMode;
    _autoSave();
    notifyListeners();
  }

  /// Color a region by its ID. In guided mode, validates the selection.
  /// Returns true if the region was colored.
  bool colorRegion(String regionId) {
    final region = _findRegion(regionId);
    if (region == null) return false;

    if (_state.mode == ColoringMode.guided) {
      if (_selectedNumber == null) {
        _state.applyColor(regionId, null);
      } else if (region.colorNumber != _selectedNumber) {
        HapticFeedback.heavyImpact();
        return false;
      } else {
        _state.applyColor(regionId, selectedColor);
      }
    } else {
      _state.applyColor(regionId, selectedColor);
    }

    if (_state.dirty) {
      _autoSave();
      HapticFeedback.lightImpact();
      notifyListeners();

      if (isComplete) {
        HapticFeedback.mediumImpact();
      }

      _autoAdvanceNumber();
    }
    return true;
  }

  void undo() {
    _state.undo();
    _autoSave();
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void redo() {
    _state.redo();
    _autoSave();
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void reset() {
    _state.reset();
    _selectedNumber = 1;
    _autoSave();
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  /// Save pending changes immediately (call when leaving the screen).
  Future<void> flushSave() async {
    await _store.flush(definition.id, _state.coloredRegions, _state.mode);
    _state.dirty = false;
  }

  @override
  void dispose() {
    flushSave();
    super.dispose();
  }

  // ── Private ────────────────────────────────────────────────────────────

  void _loadSavedProgress() {
    final savedColors = _store.load(definition.id);
    final savedMode = _store.loadMode(definition.id);
    _state = MandalaColoringState(
      designId: definition.id,
      mode: savedMode,
      coloredRegions: savedColors,
    );
    _selectedNumber = definition.palette.isNotEmpty ? 1 : null;
  }

  void _autoSave() {
    _store.saveDebounced(definition.id, _state.coloredRegions, _state.mode);
    _state.dirty = false;
  }

  /// When all regions for the current number are done, advance to the next
  /// number that still has uncolored regions.
  void _autoAdvanceNumber() {
    if (_selectedNumber == null) return;
    if (remainingForNumber(_selectedNumber!) > 0) return;

    for (final entry in definition.palette) {
      if (remainingForNumber(entry.number) > 0) {
        _selectedNumber = entry.number;
        notifyListeners();
        return;
      }
    }
  }

  MandalaRegion? _findRegion(String regionId) {
    for (final r in definition.regions) {
      if (r.id == regionId) return r;
    }
    return null;
  }
}
