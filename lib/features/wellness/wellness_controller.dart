import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Emotion { happy, relaxed, romantic, motivated, nostalgic }

class WellnessController extends ChangeNotifier {
  // YYYY-MM-DD -> Emotion.name

  WellnessController() {
    _load();
  }
  static const _kEmotionHistoryKey = 'wellness_emotion_history';

  /// Streak lengths (in consecutive check-in days) that trigger a
  /// celebratory milestone moment in the UI. Kept small-to-large so a
  /// returning user always has a nearby milestone to reach for.
  static const List<int> streakMilestones = [3, 7, 14, 30, 60, 100, 200, 365];

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

  String _keyFor(DateTime date) {
    final d = DateUtils.dateOnly(date);
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String get todayKey => _keyFor(DateTime.now());

  /// Number of consecutive days (ending today or yesterday) with a mood
  /// check-in logged. If today hasn't been logged yet, the streak still
  /// counts yesterday backwards so a user doesn't see it drop to zero
  /// before they've had a chance to check in.
  int get currentStreak {
    var cursor = DateUtils.dateOnly(DateTime.now());
    if (!_history.containsKey(_keyFor(cursor))) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (_history.containsKey(_keyFor(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Whether today's check-in is still pending (used to gently prompt,
  /// never to guilt-trip, the user).
  bool get hasCheckedInToday => _history.containsKey(todayKey);

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

  /// Logs today's mood and returns the streak milestone just reached
  /// (e.g. 3, 7, 30...), or null if no new milestone was hit. Changing
  /// an already-logged day's mood never re-triggers a milestone.
  Future<int?> setEmotionToday(Emotion e) async {
    final alreadyLoggedToday = hasCheckedInToday;
    final streakBefore = currentStreak;
    _history[todayKey] = e.name;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kEmotionHistoryKey, json.encode(_history));
    } catch (_) {}

    if (alreadyLoggedToday) return null;
    final streakAfter = currentStreak;
    if (streakAfter > streakBefore && streakMilestones.contains(streakAfter)) {
      return streakAfter;
    }
    return null;
  }

  List<Emotion?> last7Days() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      return emotionOf(_keyFor(now.subtract(Duration(days: 6 - i))));
    });
  }
}
