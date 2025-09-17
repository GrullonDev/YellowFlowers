import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/home/pages/home_page.dart';
import 'package:yellow_flowers/features/mood/mood_controller.dart';
import 'package:yellow_flowers/features/mood/mood_entry_page.dart';
import 'package:yellow_flowers/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yellow_flowers/theme/theme_controller.dart';
import 'package:yellow_flowers/data/music_service/jamendo_service.dart';
import 'package:yellow_flowers/features/cycle/cycle_controller.dart';
import 'package:yellow_flowers/features/wellness/wellness_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => MoodController()),
        ChangeNotifierProvider(create: (_) => CycleController()),
        ChangeNotifierProvider(create: (_) => WellnessController()),
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
  static const _updateInfoUrl = 'https://example.com/yellow_flowers/version.json'; // Cambia a tu endpoint real
  static const _playStoreUrl = 'https://play.google.com/apps/internaltest/4701562071927181144';
  String? _playStoreUrlOverride; // se puede sobreescribir desde el JSON

  @override
  void initState() {
    super.initState();
        // Mostrar MoodEntryPage una sola vez por día
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          _checkForUpdate();
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

  Future<void> _checkForUpdate() async {
    try {
  final info = await PackageInfo.fromPlatform();
  final localBuild = int.tryParse(info.buildNumber) ?? 0; // versionCode
      // Cache busting con timestamp para evitar JSON cacheado
      final ts = DateTime.now().millisecondsSinceEpoch;
      final resp = await http
          .get(Uri.parse('$_updateInfoUrl?ts=$ts'))
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode != 200) return;
      final data = json.decode(resp.body) as Map<String, dynamic>;
      final minVersionCode = data['minVersionCode'] as int?; // build mínimo recomendado u obligatorio
      if (minVersionCode == null) return; // JSON incompleto
      final latestVersion = data['latestVersion'] as String?; // para mostrar al usuario
      final force = (data['force'] as bool?) ?? true; // default true para retrocompatibilidad
      final changelog = data['changelog'] as String?; // notas
      _playStoreUrlOverride = data['playStoreUrl'] as String?; // override opcional

      if (localBuild < minVersionCode) {
        if (!mounted) return;
        if (force) {
          _showForceUpdateDialog(
            title: latestVersion == null
                ? 'Nueva versión disponible'
                : 'Actualiza a $latestVersion',
            changelog: changelog,
          );
        } else {
          _showOptionalUpdateDialog(
            title: latestVersion == null
                ? 'Actualización disponible'
                : 'Disponible: $latestVersion',
            changelog: changelog,
          );
        }
      }
    } catch (_) {
      // Silencioso: no bloquear si falla
    }
  }

  void _showForceUpdateDialog({required String title, String? changelog}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text(title),
          content: _UpdateDialogContent(
            forced: true,
            changelog: changelog,
          ),
          actions: [
            FilledButton(
              onPressed: () {
                // Abre Play Store
                _launchPlayStore();
              },
              child: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionalUpdateDialog({required String title, String? changelog}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: _UpdateDialogContent(
          forced: false,
            changelog: changelog,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Después'),
          ),
          FilledButton(
            onPressed: () {
              _launchPlayStore();
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPlayStore() async {
    final uri = Uri.parse(_playStoreUrlOverride ?? _playStoreUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // fallback: mostrar snackbar si falla
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la tienda')),
        );
      }
    }
  }
}

class _UpdateDialogContent extends StatelessWidget {
  const _UpdateDialogContent({required this.forced, this.changelog});
  final bool forced;
  final String? changelog;

  @override
  Widget build(BuildContext context) {
    final baseText = forced
        ? 'Hay una nueva versión obligatoria para continuar usando la app.'
        : 'Hay una nueva versión que mejora tu experiencia.';
    final hasChangelog = changelog != null && changelog!.trim().isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(baseText),
        if (hasChangelog) ...[
          const SizedBox(height: 12),
          Text('Novedades:', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 160),
            child: SingleChildScrollView(
              child: Text(
                changelog!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ],
    );
  }
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
