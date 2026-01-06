import 'package:flutter/material.dart';

class MenuItem {
  MenuItem({
    required this.title,
    required this.icon,
    required this.destination,
    required this.description,
  });
  final String title;
  final IconData icon;
  final Widget destination;
  final String description;
}
