// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTagline => 'flores amarillas';

  @override
  String get greetingMorning => 'Buenos días,';

  @override
  String get greetingAfternoon => 'Buenas tardes,';

  @override
  String get greetingEvening => 'Buenas noches,';

  @override
  String get greetingNight => 'Descansa bien,';

  @override
  String get gardenTitle => 'Tu jardín';

  @override
  String get gardenSubtitle => 'Elige cómo vivir este momento';

  @override
  String get forYouToday => 'PARA TI HOY';

  @override
  String get exploreNow => 'Explorar ahora';

  @override
  String get howDoYouFeelTitle => 'Cómo te sientes';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get breathe => 'Respirar';

  @override
  String get affirmation => 'Afirmación';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '$count día',
    );
    return '$_temp0';
  }

  @override
  String streakMilestoneTitle(int count) {
    return '¡$count días seguidos!';
  }

  @override
  String streakMilestoneBody(String name) {
    return 'Cada check-in cuenta, $name. Gracias por dedicarte este momento — sigue así 🌼';
  }

  @override
  String get streakMilestoneCta => 'Seguir mi racha 💛';

  @override
  String get reminderTitle => 'Recordatorio diario';

  @override
  String get reminderSubtitle =>
      'Un aviso suave para registrar tu ánimo y cuidar tu racha. Puedes desactivarlo cuando quieras.';

  @override
  String get reminderEnable => 'Activar recordatorio';

  @override
  String reminderTimeLabel(String time) {
    return 'Hora: $time';
  }

  @override
  String get reminderChange => 'Cambiar';

  @override
  String get reminderPermissionError =>
      'Activa las notificaciones para Amarillas en los ajustes del sistema.';

  @override
  String get moodPageTitle => '¿Cómo te sientes hoy? 🌸';

  @override
  String get moodPageSubtitle =>
      'Elige tu estado de ánimo\npara personalizar tu experiencia';

  @override
  String get moodHappy => 'Alegre';

  @override
  String get moodHappyDesc => 'Energía positiva y sonrisas';

  @override
  String get moodRelaxed => 'Tranquila';

  @override
  String get moodRelaxedDesc => 'Serenidad y paz interior';

  @override
  String get moodRomantic => 'Enamorada';

  @override
  String get moodRomanticDesc => 'Ternura y romanticismo';

  @override
  String get moodMotivated => 'Motivada';

  @override
  String get moodMotivatedDesc => 'Fuerza, enfoque y determinación';

  @override
  String get moodNostalgic => 'Nostálgica';

  @override
  String get moodNostalgicDesc => 'Recuerdos y momentos especiales';
}
