import 'package:flutter/material.dart';

class AlbumCategory {
  final String id;
  final String label;
  final String emoji;
  final IconData icon;
  final List<Color> colors;

  const AlbumCategory({
    required this.id,
    required this.label,
    required this.emoji,
    required this.icon,
    required this.colors,
  });
}
