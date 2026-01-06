import 'package:flutter/material.dart';

import 'package:yellow_flowers/features/home/pages/home_page.dart';
import 'package:yellow_flowers/utils/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}
