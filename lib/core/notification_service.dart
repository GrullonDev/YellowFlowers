import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService(this._prefs);
  final SharedPreferences _prefs;

  static const _keyEnabled = 'notifications_enabled';
  static const _channelId = 'garden_reminder';
  static const _dailyId = 42;

  final _plugin = FlutterLocalNotificationsPlugin();

  bool get enabled => _prefs.getBool(_keyEnabled) ?? true;

  Future<void> init() async {
    if (kIsWeb) return;

    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('mipmap/yellow_flowers_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin, macOS: darwin),
    );

    if (enabled) await scheduleDailyReminder();
  }

  Future<void> setEnabled(bool value) async {
    await _prefs.setBool(_keyEnabled, value);
    if (value) {
      await scheduleDailyReminder();
    } else {
      await _plugin.cancel(_dailyId);
    }
  }

  Future<void> scheduleDailyReminder() async {
    if (kIsWeb) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      'Recordatorio del jardín',
      channelDescription: 'Te recuerda cuidar tu jardín cada día',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const darwinDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await _plugin.zonedSchedule(
        _dailyId,
        'Tu jardín te espera 🌱',
        _randomBody(),
        scheduled,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  String _randomBody() {
    const bodies = [
      'Lee tu frase de hoy y planta una nueva flor.',
      'Una flor nueva te espera. ¿Vienes a verla?',
      'Tu jardín crece con cada visita. No lo dejes solo.',
      'Hoy es un buen día para florecer.',
      'Tu constancia hace florecer cosas hermosas.',
    ];
    return bodies[DateTime.now().day % bodies.length];
  }
}
