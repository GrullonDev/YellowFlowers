import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yellow_flowers/features/music/domain/entities/mood.dart';

/// Global mood state used to personalize background palette, messages and music
class MoodController extends ChangeNotifier {
  static const _prefKey = 'global_mood';

  MoodController() {
    _load();
  }

  Mood _mood = Mood.relaxed; // default
  Mood get mood => _mood;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw != null) {
        _mood = Mood.values.firstWhere(
          (m) => m.name == raw,
          orElse: () => Mood.relaxed,
        );
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setMood(Mood m) async {
    if (_mood == m) return;
    _mood = m;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, m.name);
    } catch (_) {}
  }
}
