import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/home/pages/home_page.dart';
import 'package:yellow_flowers/theme/theme_controller.dart';
import 'package:yellow_flowers/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: Consumer<ThemeController>(
        builder: (context, controller, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: controller.mode,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          home: const HomePage(),
        ),
      ),
    );
  }
}
