import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:yellow_flowers/features/garden/data/garden_service.dart';

/// Recordatorios locales del jardín.
///
/// En vez de notificaciones diarias repetidas se programan avisos sueltos para
/// los próximos [_daysAhead] días, en la hora local del teléfono. Así se pueden
/// omitir los de hoy cuando la persona ya activó su racha, y se reprograman
/// cada vez que la app vuelve a primer plano o florece una flor.
class NotificationService {
  NotificationService(this._prefs, this._garden);
  final SharedPreferences _prefs;
  final GardenService _garden;

  static const _keyEnabled = 'notifications_enabled';
  static const _channelId = 'garden_reminder';
  static const _daysAhead = 7;

  /// Horas locales del recordatorio de racha: 7:00, 12:00 y 18:00.
  static const _streakHours = [7, 12, 18];
  static const _moodHour = 20;

  // IDs: racha = 100 + día * 3 + franja; ánimo = 200 + día.
  static const _streakBaseId = 100;
  static const _moodBaseId = 200;
  // Recordatorios diarios de versiones anteriores (9:00 y 20:00 en UTC).
  static const _legacyIds = [42, 43];

  final _plugin = FlutterLocalNotificationsPlugin();
  AppLifecycleListener? _lifecycle;
  Future<void> _pending = Future.value();

  FlutterLocalNotificationsPlugin get plugin => _plugin;

  bool get enabled => _prefs.getBool(_keyEnabled) ?? true;

  bool get _supported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> init() async {
    if (kIsWeb) return;

    tz.initializeTimeZones();

    const android =
        AndroidInitializationSettings('mipmap/yellow_flowers_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(
          android: android, iOS: darwin, macOS: darwin),
    );

    // Al volver a la app se renueva la ventana de 7 días (y el día cambia).
    _lifecycle ??= AppLifecycleListener(onResume: () => reschedule());

    await reschedule();
  }

  Future<void> setEnabled(bool value) async {
    await _prefs.setBool(_keyEnabled, value);
    await reschedule();
  }

  /// Vuelve a programar todos los recordatorios. Llamar también después de
  /// plantar la flor del día para quitar los avisos de hoy.
  Future<void> reschedule() {
    // Encadenado para que dos llamadas seguidas no se pisen.
    return _pending = _pending.then((_) => _reschedule()).catchError(
        (Object e) => debugPrint('[notifications] reschedule failed: $e'));
  }

  Future<void> _reschedule() async {
    if (!_supported) return;
    await _cancelAll();
    if (!enabled) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bloomedToday = _garden.hasBloomedToday;
    final streak = _garden.currentStreak;

    for (var day = 0; day < _daysAhead; day++) {
      final date = today.add(Duration(days: day));

      if (!(day == 0 && bloomedToday)) {
        for (var slot = 0; slot < _streakHours.length; slot++) {
          final at = DateTime(
              date.year, date.month, date.day, _streakHours[slot]);
          if (!at.isAfter(now)) continue;
          final (title, body) =
              _streakMessage(slot, day == 0 ? streak : 0, date.day);
          await _schedule(_streakBaseId + day * 3 + slot, title, body, at,
              'Te recuerda cuidar tu jardín cada día');
        }
      }

      final mood = DateTime(date.year, date.month, date.day, _moodHour);
      if (mood.isAfter(now)) {
        await _schedule(_moodBaseId + day, 'Buenas noches 🌙',
            _moodBody(date.day), mood,
            'Te recuerda registrar tu ánimo por la noche');
      }
    }
  }

  Future<void> _cancelAll() async {
    final ids = [
      ..._legacyIds,
      for (var i = 0; i < _daysAhead * _streakHours.length; i++)
        _streakBaseId + i,
      for (var i = 0; i < _daysAhead; i++) _moodBaseId + i,
    ];
    for (final id in ids) {
      await _plugin.cancel(id);
    }
  }

  Future<void> _schedule(int id, String title, String body, DateTime localTime,
      String channelDescription) {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Recordatorio del jardín',
        channelDescription: channelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    // tz.local es UTC (no se configura la zona del teléfono), así que se
    // convierte el instante local a UTC: el aviso sale a la hora local exacta.
    return _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(localTime, tz.UTC),
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  (String, String) _streakMessage(int slot, int streak, int dayOfMonth) {
    const morning = [
      'Lee tu frase de hoy y planta una nueva flor.',
      'Una flor nueva te espera. ¿Vienes a verla?',
      'Tu jardín crece con cada visita. No lo dejes solo.',
      'Hoy es un buen día para florecer.',
      'Tu constancia hace florecer cosas hermosas.',
    ];
    const noon = [
      'Tómate un respiro y planta la flor de hoy.',
      'Tu frase del día sigue esperándote.',
      'Un minuto para ti: tu jardín te extraña.',
    ];
    const evening = [
      'Aún estás a tiempo de plantar la flor de hoy.',
      'Antes de que termine el día, visita tu jardín.',
      'Tu flor de hoy todavía no florece. ¿La plantamos?',
    ];

    if (streak > 0 && slot > 0) {
      return (
        slot == 1 ? 'Tu racha te espera 🌼' : 'No pierdas tu racha 🌻',
        'Llevas $streak ${streak == 1 ? 'día' : 'días'} seguidos. '
            'Planta la flor de hoy para mantenerla.'
      );
    }
    return switch (slot) {
      0 => ('Buenos días ☀️', morning[dayOfMonth % morning.length]),
      1 => ('Tu flor de hoy 🌼', noon[dayOfMonth % noon.length]),
      _ => ('Aún estás a tiempo 🌻', evening[dayOfMonth % evening.length]),
    };
  }

  String _moodBody(int dayOfMonth) {
    const bodies = [
      '¿Cómo te fue hoy? Registra tu ánimo antes de dormir.',
      'Tómate un momento para reflexionar sobre tu día.',
      'Tu bienestar importa. ¿Cómo te sientes esta noche?',
      'Un minuto para ti: registra cómo estuvo tu día.',
      'Antes de descansar, cuéntale a tu jardín cómo te fue.',
    ];
    return bodies[dayOfMonth % bodies.length];
  }
}
