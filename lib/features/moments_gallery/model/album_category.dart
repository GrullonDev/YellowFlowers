import 'package:flutter/material.dart';

class AlbumCategory {
  const AlbumCategory({
    required this.id,
    required this.label,
    required this.emoji,
    required this.icon,
    required this.colors,
  });
  final String id;
  final String label;
  final String emoji;
  final IconData icon;
  final List<Color> colors;
}
