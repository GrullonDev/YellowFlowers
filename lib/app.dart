import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/cycle/cycle_controller.dart';
import 'package:yellow_flowers/features/home/pages/home_page.dart';
import 'package:yellow_flowers/features/mood/mood_controller.dart';
import 'package:yellow_flowers/features/wellness/wellness_controller.dart';
import 'package:yellow_flowers/theme/app_theme.dart';
import 'package:yellow_flowers/theme/theme_controller.dart';

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
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeCtrl, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flores Amarillas',
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: themeCtrl.mode,
          home: const HomePage(),
        ),
      ),
    );
  }
}
