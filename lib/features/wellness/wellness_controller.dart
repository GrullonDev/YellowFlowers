import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Emotion { happy, relaxed, romantic, motivated, nostalgic }

class WellnessController extends ChangeNotifier { // YYYY-MM-DD -> Emotion.name

  WellnessController() {
    _load();
  }
  static const _kEmotionHistoryKey = 'wellness_emotion_history';

  Map<String, String> _history = {};

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final h = prefs.getString(_kEmotionHistoryKey);
      if (h != null) {
        final map = json.decode(h) as Map<String, dynamic>;
        _history = map.map((k, v) => MapEntry(k, v.toString()));
      }
    } catch (_) {}
    notifyListeners();
  }

  String get todayKey {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String dailyPhrase({required Emotion emotion}) {
    // frases muy básicas por emoción; se pueden mejorar luego
    switch (emotion) {
      case Emotion.motivated:
        return 'Hoy puedes con todo. Un paso a la vez ✨';
      case Emotion.nostalgic:
        return 'Honra tus recuerdos y sonríe por lo vivido 🌙';
      case Emotion.romantic:
        return 'Tu corazón late bonito. Disfruta el amor 💖';
      case Emotion.happy:
        return 'Que esta sonrisa te acompañe todo el día 💛';
      case Emotion.relaxed:
        return 'Respira profundo, todo está en calma 🌿';
    }
  }

  List<Emotion> get emotions => Emotion.values;

  Emotion? emotionOf(String key) {
    final v = _history[key];
    if (v == null) return null;
    return Emotion.values
        .firstWhere((e) => e.name == v, orElse: () => Emotion.relaxed);
  }

  Future<void> setEmotionToday(Emotion e) async {
    _history[todayKey] = e.name;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kEmotionHistoryKey, json.encode(_history));
    } catch (_) {}
  }

  List<Emotion?> last7Days() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = DateUtils.dateOnly(now.subtract(Duration(days: 6 - i)));
      final key =
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      return emotionOf(key);
    });
  }
}
