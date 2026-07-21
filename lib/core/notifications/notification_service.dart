import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Local (on-device) daily reminder notifications — no backend/FCM needed.
///
/// This powers the "motivation & habit" loop: an opt-in reminder that
/// nudges the user back to their daily mood check-in (see
/// [WellnessController]) at a time they choose. Everything is scheduled
/// on-device via flutter_local_notifications; nothing is sent from a
/// server, so there is no additional infrastructure cost.
class NotificationService {
  NotificationService(this._prefs);
  final SharedPreferences _prefs;

  static const _keyEnabled = 'daily_reminder_enabled';
  static const _keyHour = 'daily_reminder_hour';
  static const _keyMinute = 'daily_reminder_minute';

  /// Fixed id for the recurring daily reminder so re-scheduling simply
  /// replaces it instead of stacking duplicates.
  static const _reminderNotificationId = 1001;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.local);
    } catch (_) {
      // If timezone data can't be loaded, scheduling falls back to
      // whatever tz.local defaults to rather than crashing app startup.
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    try {
      await _plugin.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
      );
    } catch (_) {
      // Notifications are a nice-to-have; never block app startup on this.
    }
    _initialized = true;

    // Re-arm the reminder on every cold start (harmless if already set —
    // zonedSchedule below cancels/replaces the existing one first).
    if (isEnabled) {
      await _schedule(hour: reminderHour, minute: reminderMinute);
    }
  }

  bool get isEnabled => _prefs.getBool(_keyEnabled) ?? false;
  int get reminderHour => _prefs.getInt(_keyHour) ?? 20;
  int get reminderMinute => _prefs.getInt(_keyMinute) ?? 0;

  TimeOfDay get reminderTime =>
      TimeOfDay(hour: reminderHour, minute: reminderMinute);

  /// Requests OS notification permission. Returns true if granted (or if
  /// the platform doesn't require an explicit prompt).
  Future<bool> requestPermission() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iosImpl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    var granted = true;
    if (androidImpl != null) {
      granted = await androidImpl.requestNotificationsPermission() ?? true;
    }
    if (iosImpl != null) {
      final iosGranted = await iosImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = granted && (iosGranted ?? true);
    }
    return granted;
  }

  Future<bool> enableReminder({required TimeOfDay time}) async {
    final granted = await requestPermission();
    if (!granted) return false;
    await _prefs.setBool(_keyEnabled, true);
    await _prefs.setInt(_keyHour, time.hour);
    await _prefs.setInt(_keyMinute, time.minute);
    await _schedule(hour: time.hour, minute: time.minute);
    return true;
  }

  Future<void> disableReminder() async {
    await _prefs.setBool(_keyEnabled, false);
    try {
      await _plugin.cancel(_reminderNotificationId);
    } catch (_) {}
  }

  Future<void> _schedule({required int hour, required int minute}) async {
    try {
      await _plugin.cancel(_reminderNotificationId);
      final now = tz.TZDateTime.now(tz.local);
      var scheduled =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        _reminderNotificationId,
        'Un momento para ti 🌼',
        '¿Cómo te sientes hoy? Registra tu ánimo y cuida tu racha.',
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel',
            'Recordatorio diario',
            channelDescription:
                'Recordatorio diario para registrar tu estado de ánimo',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // Scheduling failures (e.g. missing permission) should never crash
      // the app — the reminder simply won't fire until the user retries.
    }
  }
}
