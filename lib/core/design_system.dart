import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumDesign {
  // --- Colors (Deep & Refined) ---
  static const Color cream = Color(0xFFFFFDF5);
  static const Color softLavender = Color(0xFFF3E5F5);
  static const Color pastelPink = Color(0xFFFFEBFA);
  static const Color premiumGold = Color(0xFFC5A059);
  static const Color radiantGold = Color(0xFFD4AF37);
  static const Color softText = Color(0xFF3E2723);
  static const Color secondaryText = Color(0xFF8D6E63);
  static const Color leafGreen = Color(0xFF2D5D3A);

  // Dark Mode
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF242424);
  static const Color darkDivider = Color(0xFF2C2C2C);

  // --- Dynamic Themes (Time of Day - Recuperados) ---
  static const List<Color> morningColors = [
    Color(0xFFFFF9C4),
    Color(0xFFFFECB3),
    Color(0xFFFFD54F)
  ];
  static const List<Color> afternoonColors = [
    Color(0xFFE3F2FD),
    Color(0xFFBBDEFB),
    Color(0xFF90CAF9)
  ];
  static const List<Color> nightColors = [
    Color(0xFF1A237E),
    Color(0xFF311B92),
    Color(0xFF000000)
  ];
  static const List<Color> moodPinkColors = [
    Color(0xFFFCE4EC),
    Color(0xFFF8BBD0),
    Color(0xFFF48FB1)
  ];

  // --- Mesh Gradient Colors ---
  static const Color mesh1 = Color(0xFFFFF9C4);
  static const Color mesh2 = Color(0xFFFFECB3);
  static const Color mesh3 = Color(0xFFFFCCBC);
  static const Color mesh4 = Color(0xFFD1C4E9);

  // --- Spacing ---
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s48 = 48.0;
  static const double s64 = 64.0;

  // --- Typography ---
  static TextStyle get serifDisplay => GoogleFonts.playfairDisplay(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
        height: 1.1,
        color: softText,
      );

  static TextStyle get serifHeading => GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: softText,
      );

  static TextStyle get serifSubHeading => GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: softText,
      );

  static TextStyle get sansBody => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.6,
        color: secondaryText,
      );

  static TextStyle get sansLabel => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.0,
        color: radiantGold,
      );

  // --- Animations ---
  static const Duration slow = Duration(milliseconds: 1500);
  static const Duration medium = Duration(milliseconds: 700);
  static const Duration fast = Duration(milliseconds: 350);

  // --- Shadows ---
  static List<BoxShadow> get deepShadow => [
        BoxShadow(
          color: Colors.black.withAlpha(20),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
      ];

  static List<BoxShadow> get premiumShadow => deepShadow;

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withAlpha(10),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get goldGlow => [
        BoxShadow(
          color: radiantGold.withAlpha(80),
          blurRadius: 30,
          spreadRadius: 2,
        ),
      ];

  // --- Shapes ---
  static const double cardRadius = 32.0;
  static BorderRadius premiumRadius = BorderRadius.circular(cardRadius);
  // --- Helpers ---
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
