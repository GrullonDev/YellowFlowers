import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:home_widget/home_widget.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'package:yellow_flowers/app.dart';
import 'package:yellow_flowers/core/firebase_messaging_service.dart';
import 'package:yellow_flowers/core/home_widget_service.dart';
import 'package:yellow_flowers/core/notification_service.dart';
import 'package:yellow_flowers/di/injector.dart' as di;

import 'firebase_options.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Si algún servicio opcional falla o se queda esperando, la app debe
    // arrancar igual: una excepción antes de runApp deja la pantalla en blanco.
    await _safe('JustAudioBackground', () => JustAudioBackground.init(
          androidNotificationChannelId: 'com.grullondev.amarillas.audio',
          androidNotificationChannelName: 'Música y sonidos',
          androidNotificationOngoing: true,
          androidNotificationIcon: 'mipmap/yellow_flowers_launcher',
        ));

    await di.initDependencies();

    final homeWidget = di.sl<HomeWidgetService>();
    await _safe('HomeWidget', homeWidget.init);
    homeWidget.refresh();

    await _safe('Notifications', di.sl<NotificationService>().init);

    Uri? launchUri;
    try {
      launchUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    } catch (_) {}

    runApp(MyApp(openGarden: launchUri?.host == 'garden'));

    // Pide permiso de notificaciones después del primer frame, sin bloquear.
    unawaited(_safe('FCM', di.sl<FirebaseMessagingService>().init,
        timeout: const Duration(seconds: 30)));
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

Future<void> _safe(
  String name,
  Future<void> Function() init, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  try {
    await init().timeout(timeout);
  } catch (e, stack) {
    debugPrint('[startup] $name failed: $e');
    FirebaseCrashlytics.instance.recordError(e, stack, reason: '$name init');
  }
}
