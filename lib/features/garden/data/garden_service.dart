import 'package:shared_preferences/shared_preferences.dart';

/// Guarda en el dispositivo los días en que la usuaria leyó su frase.
/// Cada día leído = una flor nueva en su jardín.
class GardenService {
  GardenService(this._prefs);
  final SharedPreferences _prefs;

  static const _key = 'garden_bloom_days';

  /// Días con flor, en orden cronológico (yyyy-MM-dd).
  List<DateTime> get bloomDays {
    final raw = _prefs.getStringList(_key) ?? const [];
    final days = raw.map(DateTime.tryParse).whereType<DateTime>().toList()
      ..sort();
    return days;
  }

  int get totalFlowers => bloomDays.length;

  bool get hasBloomedToday => bloomDays.contains(_today());

  /// Planta la flor de hoy. Devuelve `false` si ya se plantó.
  Future<bool> plantToday() async {
    final today = _today();
    final days = bloomDays;
    if (days.contains(today)) return false;
    days.add(today);
    await _prefs.setStringList(_key, days.map(_fmt).toList());
    return true;
  }

  /// Días consecutivos con flor hasta hoy (o hasta ayer, si hoy aún no).
  int get currentStreak {
    final set = bloomDays.toSet();
    var day = _today();
    if (!set.contains(day)) day = day.subtract(const Duration(days: 1));
    var streak = 0;
    while (set.contains(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Semanas desde la primera flor (mínimo 1).
  int get weeksGrowing {
    final days = bloomDays;
    if (days.isEmpty) return 0;
    return _today().difference(days.first).inDays ~/ 7 + 1;
  }

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
