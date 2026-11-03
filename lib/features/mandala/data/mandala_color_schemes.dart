import 'dart:ui';

import '../models/mandala_definition.dart';

/// Curated color palettes for each mandala design's color-by-number mode.
///
/// Each palette uses warm, relaxing tones consistent with the YellowFlowers
/// visual identity. Colors are ordered by number (1-based).
const Map<String, List<NumberedColor>> kMandalaColorSchemes = {
  'sol': [
    NumberedColor(number: 1, color: Color(0xFFD4AF37), name: 'Oro'),
    NumberedColor(number: 2, color: Color(0xFFF9E076), name: 'Girasol'),
    NumberedColor(number: 3, color: Color(0xFFFFAB76), name: 'Durazno'),
    NumberedColor(number: 4, color: Color(0xFFFF8A80), name: 'Coral'),
    NumberedColor(number: 5, color: Color(0xFFF48FB1), name: 'Rosa'),
    NumberedColor(number: 6, color: Color(0xFFCE93D8), name: 'Orquídea'),
    NumberedColor(number: 7, color: Color(0xFF9FA8DA), name: 'Lavanda'),
    NumberedColor(number: 8, color: Color(0xFF80CBC4), name: 'Salvia'),
  ],
  'loto': [
    NumberedColor(number: 1, color: Color(0xFFF48FB1), name: 'Rosa'),
    NumberedColor(number: 2, color: Color(0xFFCE93D8), name: 'Orquídea'),
    NumberedColor(number: 3, color: Color(0xFFD4AF37), name: 'Oro'),
    NumberedColor(number: 4, color: Color(0xFFA5D6A7), name: 'Menta'),
    NumberedColor(number: 5, color: Color(0xFF81D4FA), name: 'Cielo'),
    NumberedColor(number: 6, color: Color(0xFFF9E076), name: 'Girasol'),
    NumberedColor(number: 7, color: Color(0xFFFFAB76), name: 'Durazno'),
    NumberedColor(number: 8, color: Color(0xFF80CBC4), name: 'Salvia'),
  ],
  'estrella': [
    NumberedColor(number: 1, color: Color(0xFF7E57C2), name: 'Amatista'),
    NumberedColor(number: 2, color: Color(0xFF9FA8DA), name: 'Lavanda'),
    NumberedColor(number: 3, color: Color(0xFFD4AF37), name: 'Oro'),
    NumberedColor(number: 4, color: Color(0xFF81D4FA), name: 'Cielo'),
    NumberedColor(number: 5, color: Color(0xFFA5D6A7), name: 'Menta'),
    NumberedColor(number: 6, color: Color(0xFFF9E076), name: 'Girasol'),
    NumberedColor(number: 7, color: Color(0xFFCE93D8), name: 'Orquídea'),
    NumberedColor(number: 8, color: Color(0xFFFFAB76), name: 'Durazno'),
  ],
  'jardin': [
    NumberedColor(number: 1, color: Color(0xFF2D5D3A), name: 'Bosque'),
    NumberedColor(number: 2, color: Color(0xFFA5D6A7), name: 'Menta'),
    NumberedColor(number: 3, color: Color(0xFFF48FB1), name: 'Rosa'),
    NumberedColor(number: 4, color: Color(0xFFD4AF37), name: 'Oro'),
    NumberedColor(number: 5, color: Color(0xFFF9E076), name: 'Girasol'),
    NumberedColor(number: 6, color: Color(0xFFCE93D8), name: 'Orquídea'),
    NumberedColor(number: 7, color: Color(0xFF80CBC4), name: 'Salvia'),
    NumberedColor(number: 8, color: Color(0xFFFFAB76), name: 'Durazno'),
  ],
  'luna': [
    NumberedColor(number: 1, color: Color(0xFF9FA8DA), name: 'Lavanda'),
    NumberedColor(number: 2, color: Color(0xFF81D4FA), name: 'Cielo'),
    NumberedColor(number: 3, color: Color(0xFFCE93D8), name: 'Orquídea'),
    NumberedColor(number: 4, color: Color(0xFFD4AF37), name: 'Oro'),
    NumberedColor(number: 5, color: Color(0xFFF9E076), name: 'Girasol'),
    NumberedColor(number: 6, color: Color(0xFFA5D6A7), name: 'Menta'),
    NumberedColor(number: 7, color: Color(0xFFF48FB1), name: 'Rosa'),
    NumberedColor(number: 8, color: Color(0xFF80CBC4), name: 'Salvia'),
    NumberedColor(number: 9, color: Color(0xFF7E57C2), name: 'Amatista'),
  ],
  'corazon': [
    NumberedColor(number: 1, color: Color(0xFFE53935), name: 'Rubí'),
    NumberedColor(number: 2, color: Color(0xFFF48FB1), name: 'Rosa'),
    NumberedColor(number: 3, color: Color(0xFFD4AF37), name: 'Oro'),
    NumberedColor(number: 4, color: Color(0xFFCE93D8), name: 'Orquídea'),
    NumberedColor(number: 5, color: Color(0xFFF9E076), name: 'Girasol'),
    NumberedColor(number: 6, color: Color(0xFF9FA8DA), name: 'Lavanda'),
    NumberedColor(number: 7, color: Color(0xFF80CBC4), name: 'Salvia'),
    NumberedColor(number: 8, color: Color(0xFFFFAB76), name: 'Durazno'),
    NumberedColor(number: 9, color: Color(0xFFA5D6A7), name: 'Menta'),
  ],
  'lotus_flower': [
    NumberedColor(number: 1, color: Color(0xFFF48FB1), name: 'Rosa'),
    NumberedColor(number: 2, color: Color(0xFFD4AF37), name: 'Oro'),
    NumberedColor(number: 3, color: Color(0xFFCE93D8), name: 'Orquídea'),
  ],
  'star_mandala': [
    NumberedColor(number: 1, color: Color(0xFFD4AF37), name: 'Oro'),
    NumberedColor(number: 2, color: Color(0xFF9FA8DA), name: 'Lavanda'),
    NumberedColor(number: 3, color: Color(0xFFF9E076), name: 'Girasol'),
  ],
  'harmony_circles': [
    NumberedColor(number: 1, color: Color(0xFFD4AF37), name: 'Oro'),
    NumberedColor(number: 2, color: Color(0xFFF48FB1), name: 'Rosa'),
    NumberedColor(number: 3, color: Color(0xFFCE93D8), name: 'Orquídea'),
    NumberedColor(number: 4, color: Color(0xFF81D4FA), name: 'Cielo'),
  ],
  'sacred_geometry': [
    NumberedColor(number: 1, color: Color(0xFF7E57C2), name: 'Amatista'),
    NumberedColor(number: 2, color: Color(0xFFD4AF37), name: 'Oro'),
    NumberedColor(number: 3, color: Color(0xFF9FA8DA), name: 'Lavanda'),
    NumberedColor(number: 4, color: Color(0xFFF9E076), name: 'Girasol'),
    NumberedColor(number: 5, color: Color(0xFFA5D6A7), name: 'Menta'),
  ],
};
