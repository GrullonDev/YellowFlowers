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

    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.grullondev.amarillas.audio',
      androidNotificationChannelName: 'Música y sonidos',
      androidNotificationOngoing: true,
      androidNotificationIcon: 'mipmap/yellow_flowers_launcher',
    );

    await di.initDependencies();

    final homeWidget = di.sl<HomeWidgetService>();
    await homeWidget.init();
    homeWidget.refresh();

    await di.sl<NotificationService>().init();
    await di.sl<FirebaseMessagingService>().init();

    Uri? launchUri;
    try {
      launchUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    } catch (_) {}

    runApp(MyApp(openGarden: launchUri?.host == 'garden'));
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}
