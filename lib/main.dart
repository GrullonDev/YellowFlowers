import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:yellow_flowers/app.dart';
import 'package:yellow_flowers/core/analytics/analytics_service.dart';
import 'package:yellow_flowers/core/auth/auth_service.dart';
import 'package:yellow_flowers/core/notifications/notification_service.dart';
import 'package:yellow_flowers/core/notifications/push_notification_service.dart';
import 'package:yellow_flowers/di/injector.dart' as di;
import 'firebase_options.dart';

void main() {
  // runZonedGuarded + the Flutter/platform error hooks below are Fase 1
  // work (ver YellowFlowers_Analisis_Dinamismo_Social.docx, sección 3.4):
  // before this, the app had zero crash reporting — a stale-context bug
  // or a failed export could crash a user's session with nobody ever
  // finding out. Every uncaught error, Flutter-framework or otherwise,
  // now reaches Crashlytics instead of disappearing silently.
  runZonedGuarded<Future<void>>(() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      // Disabled in debug builds so local development noise never
      // pollutes the production Crashlytics dashboard.
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      // Must be registered before runApp so a push received while the
      // app is backgrounded/terminated has a handler to wake up into.
      FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler);

      await di.initDependencies();

      await di.sl<AuthService>().ensureSignedIn();

      unawaited(di.sl<NotificationService>().init());
      // Best-effort: request push permission and sync the FCM token.
      // Awaited AuthService above first so the token has a uid to save
      // under; never blocks startup on failure.
      unawaited(di.sl<PushNotificationService>().init());

      unawaited(di.sl<AnalyticsService>().logAppOpen());

      runApp(const MyApp());
    } catch (e, stack) {
      debugPrint('Error during app initialization: $e');
      // Best-effort: if Firebase itself failed to initialize above,
      // Crashlytics won't be usable either — never let reporting the
      // error become a second crash.
      try {
        await FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
      } catch (_) {}
      runApp(
        MaterialApp(
          home: Scaffold(body: Center(child: Text('Error al iniciar: $e'))),
        ),
      );
    }
  }, (error, stack) {
    try {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    } catch (_) {}
  });
}
