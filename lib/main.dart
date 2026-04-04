import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

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
