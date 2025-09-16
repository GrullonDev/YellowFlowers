import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/home/pages/home_page.dart';
import 'package:yellow_flowers/features/mood/mood_controller.dart';
import 'package:yellow_flowers/features/mood/mood_entry_page.dart';
import 'package:yellow_flowers/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yellow_flowers/theme/theme_controller.dart';
import 'package:yellow_flowers/data/music_service/jamendo_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => MoodController()),
      ],
      child: Consumer2<ThemeController, MoodController>(
        builder: (context, themeController, moodController, _) {
          final seed = _seedForMood(moodController.mood);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeController.mode,
            theme: buildLightTheme(seedColor: seed),
            darkTheme: buildDarkTheme(seedColor: seed),
            home: const _RootFlow(),
          );
        },
      ),
    );
  }
}

class _RootFlow extends StatefulWidget {
  const _RootFlow();
  @override
  State<_RootFlow> createState() => _RootFlowState();
}

class _RootFlowState extends State<_RootFlow> {
  @override
  void initState() {
    super.initState();
        // Mostrar MoodEntryPage una sola vez por día
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final shouldShow = await _shouldShowMoodEntry();
          if (!mounted || !shouldShow) return;
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const MoodEntryPage()),
          );
          if (result == true) {
            await _markMoodEntryShownToday();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }

    Future<bool> _shouldShowMoodEntry() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final last = prefs.getString(_kMoodGateKey);
        final today = _todayString();
        return last != today; // si es distinto o nulo, mostrar
      } catch (_) {
        return false;
      }
    }

    Future<void> _markMoodEntryShownToday() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kMoodGateKey, _todayString());
      } catch (_) {}
    }

    String _todayString() {
      final now = DateTime.now();
      return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    }
  
    static const _kMoodGateKey = 'last_mood_entry_date';
}

// Map each Mood to a representative seed color for dynamic theming
Color _seedForMood(Mood mood) {
  switch (mood) {
    case Mood.happy:
      return const Color(0xFFFFB200); // amarillo cálido
    case Mood.nostalgic:
      return const Color(0xFF7E57C2); // violeta suave
    case Mood.romantic:
      return const Color(0xFFFF5C93); // rosa romántico
    case Mood.motivated:
      return const Color(0xFFFF9800); // naranja energético
    case Mood.relaxed:
      return const Color(0xFF26C6DA); // turquesa relajante
  }
}
