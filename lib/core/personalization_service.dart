import 'package:shared_preferences/shared_preferences.dart';

class PersonalizationService {
  PersonalizationService(this._prefs);
  final SharedPreferences _prefs;

  static const String _keyLastMood = 'last_selected_mood';
  static const String _keyUserName = 'user_name';

  String getRecommendation() {
    final name = getUserName() ?? 'hermosa';
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

  /// The [MenuItem.id] that [getRecommendation]'s copy is actually talking
  /// about, so the home screen's "Explorar ahora" button can navigate to
  /// the recommended feature instead of always opening the first menu
  /// item. Kept on the same hour bands as [getRecommendation] so the text
  /// and the destination never disagree.
  ///
  /// Fixes the bug documented in
  /// YellowFlowers_Analisis_Dinamismo_Social.docx, sección 3.1: "el botón
  /// 'Explorar ahora' ... siempre navega al primer ítem del menú, sin
  /// importar qué mood o recomendación se mostró".
  String getRecommendationTargetId() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'music'; // Enérgico ☀️ — playlist para empezar el día
    } else if (hour >= 12 && hour < 18) {
      return 'flowers'; // Creativo 🎨 — canalizar la creatividad en una flor
    } else if (hour >= 18 && hour < 22) {
      return 'music'; // Relajado 🌙 — playlist para desconectar
    } else {
      return 'moments'; // Soñador ✨ — recuerdos antes de dormir
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
}
