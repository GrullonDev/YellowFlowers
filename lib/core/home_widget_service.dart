import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import 'package:yellow_flowers/core/personalization_service.dart';
import 'package:yellow_flowers/features/flowers/models/daily_inspiration.dart';
import 'package:yellow_flowers/features/flowers/models/personalization.dart';
import 'package:yellow_flowers/features/garden/data/garden_service.dart';

/// Publica la "frase del día" y el progreso del jardín en el widget de la
/// pantalla de inicio (Android: FlowerWidgetProvider, iOS: FlowerWidget).
///
/// Se precalculan las frases de los próximos [_daysAhead] días con clave
/// `quote_yyyy-MM-dd`, así el widget cambia de frase a medianoche aunque la
/// app no se abra.
class HomeWidgetService {
  HomeWidgetService(this._personalization, this._garden);

  final PersonalizationService _personalization;
  final GardenService _garden;

  static const appGroupId = 'group.com.grullondev.amarillas';
  static const androidProvider = 'FlowerWidgetProvider';
  static const iOSKind = 'FlowerWidget';
  static const _daysAhead = 14;

  /// URI con la que el widget abre la app (directo a "Mi Jardín").
  static final gardenUri = Uri.parse('amarillas://garden');

  Future<void> init() async {
    if (kIsWeb) return;
    await HomeWidget.setAppGroupId(appGroupId);
  }

  Future<void> refresh() async {
    if (kIsWeb) return;
    try {
      final name = _personalization.getUserName() ?? '';
      final today = DateTime.now();
      final futures = <Future<bool?>>[];

      for (var i = 0; i < _daysAhead; i++) {
        final day = DateTime(today.year, today.month, today.day + i);
        final insp =
            DailyInspiration.forToday(name, mood: Mood.calm, now: day);
        final key = _fmt(day);
        futures
          ..add(HomeWidget.saveWidgetData<String>('quote_$key', insp.quote))
          ..add(HomeWidget.saveWidgetData<String>(
              'author_$key', insp.author ?? ''));
      }

      final todayInsp = DailyInspiration.forToday(name, mood: Mood.calm);
      // Valores numéricos como texto para leerlos igual en Kotlin y Swift.
      futures
        ..add(HomeWidget.saveWidgetData<String>('quote_fallback', todayInsp.quote))
        ..add(HomeWidget.saveWidgetData<String>(
            'flowers', '${_garden.totalFlowers}'))
        ..add(HomeWidget.saveWidgetData<String>(
            'streak', '${_garden.currentStreak}'))
        ..add(HomeWidget.saveWidgetData<String>(
            'bloomed_on', _garden.hasBloomedToday ? _fmt(today) : ''));
      await Future.wait(futures);

      await HomeWidget.updateWidget(
        androidName: androidProvider,
        iOSName: iOSKind,
      );
    } catch (e) {
      // El widget es opcional: nunca debe romper la app.
      debugPrint('HomeWidget refresh error: $e');
    }
  }

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
