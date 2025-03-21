import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final Widget destination;

  MenuItem({
    required this.title,
    required this.icon,
    required this.destination,
  });
}
