import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:yellow_flowers/app.dart';
import 'package:yellow_flowers/di/injector.dart' as di;

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize unified dependencies (legacy container removed)
  await di.initDependencies();

  runApp(const MyApp());
}
