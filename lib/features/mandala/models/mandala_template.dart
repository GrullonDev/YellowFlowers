import 'package:flutter/material.dart';

/// A single colorable section within a mandala.
///
/// Each section holds a [Path] that defines its shape and a mutable [color]
/// that starts as [Colors.white] (uncolored) and changes when the user taps it.
class MandalaSection {
  MandalaSection({
    required this.path,
    this.color = Colors.white,
  });

  final Path path;
  Color color;
}

/// A mandala template made up of colorable [sections].
///
/// [difficulty] ranges from 1 (simple, few sections) to 3 (intricate, many
/// sections). All paths are authored centered at (0,0) within a 300x300 box
/// (i.e. coordinates from -150 to 150) so the painter can scale them to fit
/// any canvas size.
class MandalaTemplate {
  MandalaTemplate({
    required this.id,
    required this.name,
    required this.emoji,
    required this.difficulty,
    required this.sections,
  });

  final String id;
  final String name;
  final String emoji;
  final int difficulty;
  final List<MandalaSection> sections;
}
