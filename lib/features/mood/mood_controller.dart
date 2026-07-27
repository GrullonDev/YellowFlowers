import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yellow_flowers/core/analytics/analytics_service.dart';
import 'package:yellow_flowers/di/injector.dart' as di;
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';

/// Global mood state used to personalize background palette, messages and music
class MoodController extends ChangeNotifier {
  MoodController() {
    _load();
  }
  static const _prefKey = 'global_mood';

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
    _mood = m;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, m.name);
      await prefs.setInt(
          'last_mood_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
    // Fase 1 analítica: cada cambio de mood alimenta el evento
    // mood_selected (ver AnalyticsService). Guardado tras
    // notifyListeners() para no retrasar la reacción de la UI.
    try {
      if (di.sl.isRegistered<AnalyticsService>()) {
        unawaited(di.sl<AnalyticsService>().logMoodSelected(m.name));
      }
    } catch (_) {}
  }

  Mood getRecommendedMood() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return Mood.happy; // Mañana enérgica
    if (hour >= 11 && hour < 17) return Mood.motivated; // Tarde productiva
    if (hour >= 17 && hour < 22) return Mood.relaxed; // Tarde-noche de calma
    return Mood.nostalgic; // Noche de recuerdos
  }
}
