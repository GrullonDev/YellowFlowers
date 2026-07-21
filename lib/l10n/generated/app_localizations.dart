import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// Small wordmark shown at the top of the Home screen.
  ///
  /// In es, this message translates to:
  /// **'flores amarillas'**
  String get appTagline;

  /// No description provided for @greetingMorning.
  ///
  /// In es, this message translates to:
  /// **'Buenos días,'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In es, this message translates to:
  /// **'Buenas tardes,'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In es, this message translates to:
  /// **'Buenas noches,'**
  String get greetingEvening;

  /// No description provided for @greetingNight.
  ///
  /// In es, this message translates to:
  /// **'Descansa bien,'**
  String get greetingNight;

  /// No description provided for @gardenTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu jardín'**
  String get gardenTitle;

  /// No description provided for @gardenSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige cómo vivir este momento'**
  String get gardenSubtitle;

  /// No description provided for @forYouToday.
  ///
  /// In es, this message translates to:
  /// **'PARA TI HOY'**
  String get forYouToday;

  /// No description provided for @exploreNow.
  ///
  /// In es, this message translates to:
  /// **'Explorar ahora'**
  String get exploreNow;

  /// No description provided for @howDoYouFeelTitle.
  ///
  /// In es, this message translates to:
  /// **'Cómo te sientes'**
  String get howDoYouFeelTitle;

  /// No description provided for @thisWeek.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get thisWeek;

  /// No description provided for @breathe.
  ///
  /// In es, this message translates to:
  /// **'Respirar'**
  String get breathe;

  /// No description provided for @affirmation.
  ///
  /// In es, this message translates to:
  /// **'Afirmación'**
  String get affirmation;

  /// Consecutive daily check-in streak, shown as a small chip (e.g. '5 días').
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one {{count} día} other {{count} días}}'**
  String streakDays(int count);

  /// No description provided for @streakMilestoneTitle.
  ///
  /// In es, this message translates to:
  /// **'¡{count} días seguidos!'**
  String streakMilestoneTitle(int count);

  /// No description provided for @streakMilestoneBody.
  ///
  /// In es, this message translates to:
  /// **'Cada check-in cuenta, {name}. Gracias por dedicarte este momento — sigue así 🌼'**
  String streakMilestoneBody(String name);

  /// No description provided for @streakMilestoneCta.
  ///
  /// In es, this message translates to:
  /// **'Seguir mi racha 💛'**
  String get streakMilestoneCta;

  /// No description provided for @reminderTitle.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio diario'**
  String get reminderTitle;

  /// No description provided for @reminderSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Un aviso suave para registrar tu ánimo y cuidar tu racha. Puedes desactivarlo cuando quieras.'**
  String get reminderSubtitle;

  /// No description provided for @reminderEnable.
  ///
  /// In es, this message translates to:
  /// **'Activar recordatorio'**
  String get reminderEnable;

  /// No description provided for @reminderTimeLabel.
  ///
  /// In es, this message translates to:
  /// **'Hora: {time}'**
  String reminderTimeLabel(String time);

  /// No description provided for @reminderChange.
  ///
  /// In es, this message translates to:
  /// **'Cambiar'**
  String get reminderChange;

  /// No description provided for @reminderPermissionError.
  ///
  /// In es, this message translates to:
  /// **'Activa las notificaciones para Amarillas en los ajustes del sistema.'**
  String get reminderPermissionError;

  /// No description provided for @moodPageTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo te sientes hoy? 🌸'**
  String get moodPageTitle;

  /// No description provided for @moodPageSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige tu estado de ánimo\npara personalizar tu experiencia'**
  String get moodPageSubtitle;

  /// No description provided for @moodHappy.
  ///
  /// In es, this message translates to:
  /// **'Alegre'**
  String get moodHappy;

  /// No description provided for @moodHappyDesc.
  ///
  /// In es, this message translates to:
  /// **'Energía positiva y sonrisas'**
  String get moodHappyDesc;

  /// No description provided for @moodRelaxed.
  ///
  /// In es, this message translates to:
  /// **'Tranquila'**
  String get moodRelaxed;

  /// No description provided for @moodRelaxedDesc.
  ///
  /// In es, this message translates to:
  /// **'Serenidad y paz interior'**
  String get moodRelaxedDesc;

  /// No description provided for @moodRomantic.
  ///
  /// In es, this message translates to:
  /// **'Enamorada'**
  String get moodRomantic;

  /// No description provided for @moodRomanticDesc.
  ///
  /// In es, this message translates to:
  /// **'Ternura y romanticismo'**
  String get moodRomanticDesc;

  /// No description provided for @moodMotivated.
  ///
  /// In es, this message translates to:
  /// **'Motivada'**
  String get moodMotivated;

  /// No description provided for @moodMotivatedDesc.
  ///
  /// In es, this message translates to:
  /// **'Fuerza, enfoque y determinación'**
  String get moodMotivatedDesc;

  /// No description provided for @moodNostalgic.
  ///
  /// In es, this message translates to:
  /// **'Nostálgica'**
  String get moodNostalgic;

  /// No description provided for @moodNostalgicDesc.
  ///
  /// In es, this message translates to:
  /// **'Recuerdos y momentos especiales'**
  String get moodNostalgicDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
