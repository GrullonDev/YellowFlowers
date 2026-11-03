import 'dart:async';
import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/mandala_definition.dart';

/// Persists per-mandala coloring progress to SharedPreferences.
///
/// Format (v2): JSON with schema version, mode, and region-id-keyed colors.
/// Migrates from v1 (index-keyed StringList) transparently.
class MandalaStore {
  MandalaStore(this._prefs);
  final SharedPreferences _prefs;

  static const _currentVersion = 2;
  Timer? _debounceTimer;

  static String _key(String id) => 'mandala_progress_$id';
  static String _legacyKey(String id) => 'mandala_colors_$id';

  /// Load saved progress for a mandala. Returns region ID → color map.
  Map<String, Color> load(String id) {
    final raw = _prefs.getString(_key(id));
    if (raw != null) return _loadV2(raw);
    return _migrateV1(id);
  }

  /// Load the saved coloring mode, defaulting to guided.
  ColoringMode loadMode(String id) {
    final raw = _prefs.getString(_key(id));
    if (raw == null) return ColoringMode.guided;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final mode = json['mode'] as String?;
      return mode == 'free' ? ColoringMode.free : ColoringMode.guided;
    } catch (_) {
      return ColoringMode.guided;
    }
  }

  /// Save progress, debounced to avoid excessive disk writes.
  void saveDebounced(
    String id,
    Map<String, Color> colors,
    ColoringMode mode, {
    Duration delay = const Duration(seconds: 2),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () => save(id, colors, mode));
  }

  /// Save progress immediately.
  Future<void> save(
    String id,
    Map<String, Color> colors,
    ColoringMode mode,
  ) async {
    final data = <String, dynamic>{
      'v': _currentVersion,
      'mode': mode == ColoringMode.free ? 'free' : 'guided',
      'regions': {
        for (final e in colors.entries) e.key: e.value.toARGB32(),
      },
    };
    await _prefs.setString(_key(id), jsonEncode(data));
  }

  /// Flush any pending debounced save immediately.
  Future<void> flush(
    String id,
    Map<String, Color> colors,
    ColoringMode mode,
  ) async {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    await save(id, colors, mode);
  }

  Future<void> clear(String id) async {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    await _prefs.remove(_key(id));
    await _prefs.remove(_legacyKey(id));
  }

  void dispose() {
    _debounceTimer?.cancel();
  }

  // -- V2 loader --

  Map<String, Color> _loadV2(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final regions = json['regions'] as Map<String, dynamic>? ?? {};
      return {
        for (final e in regions.entries) e.key: Color(e.value as int),
      };
    } catch (_) {
      return {};
    }
  }

  // -- V1 migration (index-based StringList) --

  Map<String, Color> _migrateV1(String id) {
    final raw = _prefs.getStringList(_legacyKey(id));
    if (raw == null || raw.isEmpty) return {};

    final colors = <String, Color>{};
    for (final entry in raw) {
      final parts = entry.split(':');
      if (parts.length != 2) continue;
      final index = int.tryParse(parts[0]);
      final value = int.tryParse(parts[1]);
      if (index != null && value != null) {
        colors['${id}_s$index'] = Color(value);
      }
    }
    return colors;
  }
}
