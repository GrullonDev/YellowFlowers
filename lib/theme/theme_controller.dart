import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple ChangeNotifier to toggle between light and dark ThemeMode.
class ThemeController extends ChangeNotifier {
  ThemeController() {
    _load();
  }
  static const _prefKey = 'app_theme_mode';

  ThemeMode _mode = ThemeMode.light;
  bool _loaded = false;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;
  bool get isLoaded => _loaded;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw != null) {
        switch (raw) {
          case 'dark':
            _mode = ThemeMode.dark;
            break;
          case 'light':
            _mode = ThemeMode.light;
            break;
          case 'system':
            _mode = ThemeMode.system;
            break;
        }
      }
    } catch (_) {
      // ignore storage errors silently
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _prefKey,
          switch (_mode) {
            ThemeMode.dark => 'dark',
            ThemeMode.light => 'light',
            ThemeMode.system => 'system'
          });
    } catch (_) {
      // ignore
    }
  }

  void toggle() {
    // Cycle: light -> dark -> system -> light
    _mode = switch (_mode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    notifyListeners();
    _persist();
  }

  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    _persist();
  }
}
