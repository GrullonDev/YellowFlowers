import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CyclePhase { period, premenstrual, fertile, other }

class CycleController extends ChangeNotifier {

  CycleController() {
    _load();
  }
  static const _kLastPeriodKey = 'cycle_last_period';
  static const _kCycleLengthKey = 'cycle_length_days';
  static const _kFertileEnergeticKey = 'cycle_fertile_energetic';

  DateTime? _lastPeriodStart; // primer día del último periodo
  int _cycleLength = 28; // por defecto estándar
  bool _fertilePreferEnergetic = false; // preferencia del usuario

  DateTime? get lastPeriodStart => _lastPeriodStart;
  int get cycleLength => _cycleLength;
  bool get fertilePreferEnergetic => _fertilePreferEnergetic;

  CyclePhase get currentPhase => _computePhase(DateTime.now());

  /// Día actual dentro del ciclo (1-indexed). 0 si no está configurado.
  int get currentDayInCycle {
    if (_lastPeriodStart == null) return 0;
    final start = DateUtils.dateOnly(_lastPeriodStart!);
    final now = DateUtils.dateOnly(DateTime.now());
    final diff = now.difference(start).inDays;
    return (diff % _cycleLength) + 1;
  }

  /// Días que faltan para el próximo periodo. 0 si no está configurado.
  int get daysUntilNextPeriod {
    if (_lastPeriodStart == null) return 0;
    return _cycleLength - (currentDayInCycle - 1);
  }

  String get phaseEmoji {
    switch (currentPhase) {
      case CyclePhase.period:
        return '🌹';
      case CyclePhase.fertile:
        return '✨';
      case CyclePhase.premenstrual:
        return '🌙';
      case CyclePhase.other:
        return '🌸';
    }
  }

  String get phaseAffirmation {
    switch (currentPhase) {
      case CyclePhase.period:
        return 'Tu cuerpo es sabio.\nDescansa con amor.';
      case CyclePhase.fertile:
        return 'Brillas con una\nenergía especial.';
      case CyclePhase.premenstrual:
        return 'La calma es\ntu fortaleza.';
      case CyclePhase.other:
        return 'Creces con\ncada nuevo día.';
    }
  }

  List<String> get phaseTips {
    switch (currentPhase) {
      case CyclePhase.period:
        return ['Hidratate bien 💧', 'Movimiento suave 🧘', 'Date cariño 🛁', 'Descansa profundo 🌙'];
      case CyclePhase.fertile:
        return ['Conéctate 💬', 'Crea y expresa 🎨', 'Muévete 💃', 'Planifica ⭐'];
      case CyclePhase.premenstrual:
        return ['Reduce el café ☕', 'Medita 🧘', 'Escribe cómo te sientes ✍️', 'Cuídate extra 🌿'];
      case CyclePhase.other:
        return ['Aprende algo nuevo 📚', 'Aire libre 🌿', 'Planifica tu semana 📋', 'Comparte amor 💛'];
    }
  }

  List<Color> get phaseGradientColors {
    switch (currentPhase) {
      case CyclePhase.period:
        return [const Color(0xFFFFCDD2), const Color(0xFFEF9A9A)];
      case CyclePhase.fertile:
        return [const Color(0xFFFFF9C4), const Color(0xFFFFECB3)];
      case CyclePhase.premenstrual:
        return [const Color(0xFFE8EAF6), const Color(0xFFD1C4E9)];
      case CyclePhase.other:
        return [const Color(0xFFFCE4EC), const Color(0xFFF8BBD0)];
    }
  }

  String get currentPhaseLabel {
    switch (currentPhase) {
      case CyclePhase.period:
        return 'Fase Menstrual';
      case CyclePhase.fertile:
        return 'Fase Fértil';
      case CyclePhase.premenstrual:
        return 'Fase Lútea / Premenstrual';
      case CyclePhase.other:
        return 'Fase Folicular';
    }
  }

  String? get recommendation {
    switch (currentPhase) {
      case CyclePhase.period:
        return 'Es momento de cuidar de ti. Permítete descansar, escuchar tu cuerpo y recibir amor.';
      case CyclePhase.fertile:
        return 'Tu energía está en su punto máximo. ¡Aprovéchala, conecta con el mundo y disfruta!';
      case CyclePhase.premenstrual:
        return 'Busca el equilibrio interior. Sonidos relajantes y momentos de calma te nutren hoy.';
      case CyclePhase.other:
        return 'Estás en una fase de renovación. Un momento perfecto para aprender y florecer.';
    }
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kLastPeriodKey);
      final len = prefs.getInt(_kCycleLengthKey);
      _fertilePreferEnergetic = prefs.getBool(_kFertileEnergeticKey) ?? false;
      if (raw != null) {
        _lastPeriodStart = DateTime.tryParse(raw);
      }
      if (len != null && len >= 21 && len <= 35) {
        _cycleLength = len;
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setLastPeriod(DateTime date) async {
    _lastPeriodStart = DateUtils.dateOnly(date);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _kLastPeriodKey, _lastPeriodStart!.toIso8601String());
    } catch (_) {}
  }

  Future<void> setCycleLength(int days) async {
    _cycleLength = days.clamp(21, 35);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kCycleLengthKey, _cycleLength);
    } catch (_) {}
  }

  Future<void> setFertilePreferEnergetic(bool value) async {
    _fertilePreferEnergetic = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kFertileEnergeticKey, _fertilePreferEnergetic);
    } catch (_) {}
  }

  CyclePhase phaseOn(DateTime date) => _computePhase(date);

  CyclePhase _computePhase(DateTime now) {
    if (_lastPeriodStart == null) return CyclePhase.other;

    final start = DateUtils.dateOnly(_lastPeriodStart!);
    final daysSince = now.difference(start).inDays % _cycleLength;

    // Simplificado: periodo: día 0-5, fértil: día ~12-16 (ovulación aprox 14), premenstrual: último 5 días del ciclo
    if (daysSince >= 0 && daysSince <= 5) return CyclePhase.period;
    if (daysSince >= 12 && daysSince <= 16) return CyclePhase.fertile;
    if (daysSince >= _cycleLength - 5) return CyclePhase.premenstrual;
    return CyclePhase.other;
  }
}
