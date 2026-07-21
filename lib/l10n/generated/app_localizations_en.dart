// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTagline => 'yellow flowers';

  @override
  String get greetingMorning => 'Good morning,';

  @override
  String get greetingAfternoon => 'Good afternoon,';

  @override
  String get greetingEvening => 'Good evening,';

  @override
  String get greetingNight => 'Rest well,';

  @override
  String get gardenTitle => 'Your garden';

  @override
  String get gardenSubtitle => 'Choose how to live this moment';

  @override
  String get forYouToday => 'FOR YOU TODAY';

  @override
  String get exploreNow => 'Explore now';

  @override
  String get howDoYouFeelTitle => 'How you\'re feeling';

  @override
  String get thisWeek => 'This week';

  @override
  String get breathe => 'Breathe';

  @override
  String get affirmation => 'Affirmation';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String streakMilestoneTitle(int count) {
    return '$count days in a row!';
  }

  @override
  String streakMilestoneBody(String name) {
    return 'Every check-in counts, $name. Thank you for making time for this — keep going 🌼';
  }

  @override
  String get streakMilestoneCta => 'Keep my streak 💛';

  @override
  String get reminderTitle => 'Daily reminder';

  @override
  String get reminderSubtitle =>
      'A gentle nudge to log your mood and keep your streak. You can turn it off anytime.';

  @override
  String get reminderEnable => 'Enable reminder';

  @override
  String reminderTimeLabel(String time) {
    return 'Time: $time';
  }

  @override
  String get reminderChange => 'Change';

  @override
  String get reminderPermissionError =>
      'Turn on notifications for Amarillas in your system settings.';

  @override
  String get moodPageTitle => 'How are you feeling today? 🌸';

  @override
  String get moodPageSubtitle =>
      'Choose your mood\nto personalize your experience';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodHappyDesc => 'Positive energy and smiles';

  @override
  String get moodRelaxed => 'Calm';

  @override
  String get moodRelaxedDesc => 'Serenity and inner peace';

  @override
  String get moodRomantic => 'In love';

  @override
  String get moodRomanticDesc => 'Tenderness and romance';

  @override
  String get moodMotivated => 'Motivated';

  @override
  String get moodMotivatedDesc => 'Strength, focus and drive';

  @override
  String get moodNostalgic => 'Nostalgic';

  @override
  String get moodNostalgicDesc => 'Memories and special moments';
}
