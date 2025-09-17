import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:yellow_flowers/app.dart';
import 'package:yellow_flowers/utils/inyenction_container.dart' as di; // legacy
import 'package:yellow_flowers/di/injector.dart' as new_di; // new clean architecture injector

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize legacy dependencies
  di.initializeDependencies();
  // Initialize new clean architecture dependencies
  await new_di.initDependencies();

  runApp(const MyApp());
}
