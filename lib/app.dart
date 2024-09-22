import 'package:flutter/material.dart';
import 'package:yellow_flowers/features/home/pages/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yellow Flowers',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
