import 'package:shared_preferences/shared_preferences.dart';

class PersonalizationService {
  final SharedPreferences _prefs;
  
  static const String _keyLastMood = 'last_selected_mood';

  PersonalizationService(this._prefs);

  String getRecommendation() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "¡Buenos días! Hoy te recomendamos un mood *Enérgico* ☀️ para empezar con todo.";
    } else if (hour >= 12 && hour < 18) {
      return "¡Buenas tardes! ¿Qué tal un mood *Creativo* 🎨 para fluir con tus ideas?";
    } else if (hour >= 18 && hour < 22) {
      return "¡Buenas noches! Te recomendamos un mood *Relajado* 🌙 para desconectar.";
    } else {
      return "Es tarde... Disfruta de un mood *Soñador* ✨ antes de descansar.";
    }
  }

  Future<void> saveLastMood(String mood) async {
    await _prefs.setString(_keyLastMood, mood);
  }

  String? getLastMood() {
    return _prefs.getString(_keyLastMood);
  }

  bool isFirstTime() {
    return _prefs.getBool('is_first_time') ?? true;
  }

  Future<void> setNotFirstTime() async {
    await _prefs.setBool('is_first_time', false);
  }
}
