import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Emotion {
  happy,
  relaxed,
  romantic,
  motivated,
  nostalgic,
  anxious,
  grateful,
  empowered,
  melancholic,
  hopeful,
  overwhelmed,
  tender,
  confident,
}

class WellnessController extends ChangeNotifier {
  // YYYY-MM-DD -> Emotion.name

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
      case Emotion.anxious:
        return 'Esto también pasará. Respira y confía 🕊️';
      case Emotion.grateful:
        return 'Hoy es un buen día para dar gracias 🌼';
      case Emotion.empowered:
        return 'Tu fuerza interior no tiene límites 👑';
      case Emotion.melancholic:
        return 'Sentir es humano. Abráza lo que eres hoy 🌧️';
      case Emotion.hopeful:
        return 'Algo hermoso viene en camino 🌅';
      case Emotion.overwhelmed:
        return 'No tienes que resolverlo todo hoy 🫧';
      case Emotion.tender:
        return 'Tu sensibilidad es un regalo al mundo 🦋';
      case Emotion.confident:
        return 'Confía en ti. Ya has superado tanto 💫';
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
