import 'package:flutter/material.dart';

class MenuItem {
  MenuItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.destination,
    required this.description,
  });

  /// Stable identifier for this menu item (e.g. 'flowers', 'music'),
  /// independent of the display [title]. Used by
  /// [PersonalizationService.getRecommendationTargetId] to route the
  /// home screen's "Explorar ahora" button to the actual feature being
  /// recommended, instead of always opening the first item — see
  /// YellowFlowers_Analisis_Dinamismo_Social.docx, sección 3.1.
  final String id;
  final String title;
  final IconData icon;
  final Widget destination;
  final String description;
}
