import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:yellow_flowers/app.dart';
import 'package:yellow_flowers/core/auth/auth_service.dart';
import 'package:yellow_flowers/core/notifications/notification_service.dart';
import 'package:yellow_flowers/di/injector.dart' as di;
import 'firebase_options.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Importante: En Android, si tienes el archivo google-services.json, 
    // Firebase ya se inicializa automáticamente en el lado nativo.
    // Usamos Firebase.apps.isEmpty para evitar el error [core/duplicate-app].
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    // Initialize unified dependencies (legacy container removed)
    await di.initDependencies();

    // Anonymous auth gives every install a stable uid so user-composed
    // content (special messages, moments gallery) can sync to Firestore
    // instead of being lost on reinstall. Awaited (it's fast and Firebase
    // is already initialized above) so features that read AuthService.uid
    // during their own init() have it available immediately.
    await di.sl<AuthService>().ensureSignedIn();

    // Best-effort: re-arm the opt-in daily reminder if the user enabled it.
    // Never blocks app startup on failure.
    unawaited(di.sl<NotificationService>().init());

    runApp(const MyApp());
  } catch (e) {
    debugPrint('Error during app initialization: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error al iniciar: $e'),
        ),
      ),
    ));
  }
}
