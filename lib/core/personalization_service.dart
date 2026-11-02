import 'package:shared_preferences/shared_preferences.dart';

import 'package:yellow_flowers/core/user_gender.dart';

class PersonalizationService {
  PersonalizationService(this._prefs);
  final SharedPreferences _prefs;

  static const String _keyLastMood = 'last_selected_mood';
  static const String _keyUserName = 'user_name';
  static const String _keyGender = 'user_gender';

  String getRecommendation() {
    final name = getUserName() ?? defaultGreetingName;
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return '¡Buenos días, $name! Hoy te recomendamos un mood *Enérgico* ☀️ para empezar con todo.';
    } else if (hour >= 12 && hour < 18) {
      return '¡Buenas tardes, $name! ¿Qué tal un mood *Creativo* 🎨 para fluir con tus ideas?';
    } else if (hour >= 18 && hour < 22) {
      return '¡Buenas noches, $name! Te recomendamos un mood *Relajado* 🌙 para desconectar.';
    } else {
      return 'Es tarde, $name... Disfruta de un mood *Soñador* ✨ antes de descansar.';
    }
  }

  String get defaultGreetingName {
    switch (getUserGender()) {
      case UserGender.female:
        return 'hermosa';
      case UserGender.male:
        return 'campeón';
      case UserGender.unspecified:
        return 'amigo';
    }
  }

  Future<void> saveUserName(String name) async {
    await _prefs.setString(_keyUserName, name);
  }

  String? getUserName() {
    return _prefs.getString(_keyUserName);
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

  Future<void> saveGender(UserGender gender) async {
    await _prefs.setString(_keyGender, gender.name);
  }

  UserGender getUserGender() {
    final raw = _prefs.getString(_keyGender);
    if (raw == null) return UserGender.unspecified;
    return UserGender.values.firstWhere(
      (g) => g.name == raw,
      orElse: () => UserGender.unspecified,
    );
  }

  bool get hasSelectedGender => _prefs.getString(_keyGender) != null;
}
