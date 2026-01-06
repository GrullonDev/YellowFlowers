import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/home/pages/home_page.dart';
import 'package:yellow_flowers/features/mood/mood_controller.dart';
import 'package:yellow_flowers/features/mood/mood_entry_page.dart';
import 'package:yellow_flowers/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yellow_flowers/theme/theme_controller.dart';
import 'package:yellow_flowers/features/cycle/cycle_controller.dart';
import 'package:yellow_flowers/features/wellness/wellness_controller.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';
import 'package:yellow_flowers/utils/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
