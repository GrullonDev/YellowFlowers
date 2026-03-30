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

  String get currentPhaseLabel {
    switch (currentPhase) {
      case CyclePhase.period:
        return 'Fase Menstrual';
      case CyclePhase.fertile:
        return 'Fase Fértil';
      case CyclePhase.premenstrual:
        return 'Fase Lútea / Premenstrual';
      case CyclePhase.other:
        return 'Ciclo en Curso';
    }
  }

  String? get recommendation {
    switch (currentPhase) {
      case CyclePhase.period:
        return 'Es momento de cuidar de ti. Una melodía suave ayudará a calmar tu mente y cuerpo.';
      case CyclePhase.fertile:
        return 'Tu energía está en su punto máximo. ¡Aprovéchala con ritmos vibrantes y alegres!';
      case CyclePhase.premenstrual:
        return 'Busca el equilibrio. Sonidos relajantes te ayudarán a navegar estos días con calma.';
      case CyclePhase.other:
        return 'Sigue el ritmo de tu corazón. Elige la música que mejor conecte con tu sentir hoy.';
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
