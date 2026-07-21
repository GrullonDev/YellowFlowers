import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:yellow_flowers/core/connectivity/connectivity_controller.dart';
import 'package:yellow_flowers/features/cycle/cycle_controller.dart';
import 'package:yellow_flowers/features/home/pages/home_page.dart';
import 'package:yellow_flowers/features/mood/mood_controller.dart';
import 'package:yellow_flowers/features/wellness/wellness_controller.dart';
import 'package:yellow_flowers/features/flowers/bloc/flower_bloc.dart';
import 'package:yellow_flowers/l10n/generated/app_localizations.dart';
import 'package:yellow_flowers/theme/app_theme.dart';
import 'package:yellow_flowers/theme/theme_controller.dart';
import 'package:yellow_flowers/widgets/offline_banner.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => MoodController()),
        ChangeNotifierProvider(create: (_) => WellnessController()),
        ChangeNotifierProvider(create: (_) => CycleController()),
        ChangeNotifierProvider(create: (_) => FlowerBloc()),
        ChangeNotifierProvider(create: (_) => ConnectivityController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeCtrl, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flores Amarillas',
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: themeCtrl.mode,
          // Localization infrastructure is wired up (ES template + EN
          // translation ready in lib/l10n/) but the app is pinned to
          // Spanish for now since only Home + Mood Entry have been
          // migrated to AppLocalizations so far — switching `locale` to
          // follow the system before the rest of the app is migrated
          // would leave most screens in Spanish anyway. Remove the
          // `locale:` override once the full string migration lands.
          locale: const Locale('es'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) =>
              OfflineBannerWrapper(child: child ?? const SizedBox.shrink()),
          home: const HomePage(),
        ),
      ),
    );
  }
}
