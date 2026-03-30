import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/home/pages/home_page.dart';
import 'package:yellow_flowers/features/mood/mood_controller.dart';
import 'package:yellow_flowers/features/wellness/wellness_controller.dart';
import 'package:yellow_flowers/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MoodController()),
        ChangeNotifierProvider(create: (_) => WellnessController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flores Amarillas',
        theme: buildLightTheme(),
        home: const HomePage(),
      ),
    );
  }
}
