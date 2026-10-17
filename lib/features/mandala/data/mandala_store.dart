import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda en el dispositivo los colores de cada mandala (zona → color).
class MandalaStore {
  MandalaStore(this._prefs);
  final SharedPreferences _prefs;

  static String _key(String id) => 'mandala_colors_$id';

  Map<int, Color> load(String id) {
    final raw = _prefs.getStringList(_key(id)) ?? const [];
    final colors = <int, Color>{};
    for (final entry in raw) {
      final parts = entry.split(':');
      if (parts.length != 2) continue;
      final region = int.tryParse(parts[0]);
      final value = int.tryParse(parts[1]);
      if (region != null && value != null) colors[region] = Color(value);
    }
    return colors;
  }

  Future<void> save(String id, Map<int, Color> colors) => _prefs.setStringList(
        _key(id),
        [for (final e in colors.entries) '${e.key}:${e.value.toARGB32()}'],
      );

  Future<void> clear(String id) => _prefs.remove(_key(id));
}
