import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'package:yellow_flowers/app.dart';
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

    // Música en segundo plano con controles en la notificación.
    // Debe inicializarse antes de crear cualquier AudioPlayer.
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.grullondev.amarillas.audio',
      androidNotificationChannelName: 'Música y sonidos',
      androidNotificationOngoing: true,
      androidNotificationIcon: 'mipmap/yellow_flowers_launcher',
    );

    // Initialize unified dependencies (legacy container removed)
    await di.initDependencies();

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
