import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:yellow_flowers/app.dart';
import 'package:yellow_flowers/di/injector.dart' as di;

import 'firebase_options.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize unified dependencies (legacy container removed)
    await di.initDependencies();

    runApp(const MyApp());
  } catch (e) {
    debugPrint("Error during app initialization: $e");
    // Run an error app or just proceed to launch if possible
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text("Error al iniciar: $e"),
        ),
      ),
    ));
  }
}
