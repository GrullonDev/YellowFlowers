import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final Widget destination;
  final String description;

  MenuItem({
    required this.title,
    required this.icon,
    required this.destination,
    required this.description,
  });
}
