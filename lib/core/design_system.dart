import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumDesign {
  // --- Colors ---
  static const Color cream = Color(0xFFFFFDF5);
  static const Color softLavender = Color(0xFFF3E5F5);
  static const Color pastelPink = Color(0xFFFFEBFA);
  static const Color premiumGold = Color(0xFFC5A059);
  static const Color radiantGold = Color(0xFFD4AF37);
  static const Color softText = Color(0xFF3E2723);
  static const Color leafGreen = Color(0xFFA5D6A7);
  static const Color secondaryText = Color(0xFF795548);

  // Dark Mode
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF242424);
  static const Color darkDivider = Color(0xFF2C2C2C);

  // --- Spacing (Consistente 8 / 12 / 16 / 24 / 32) ---
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s48 = 48.0;
  static const double s64 = 64.0;

  // --- Typography ---
  static TextStyle get serifHeading => GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: softText,
      );

  static TextStyle get serifSubHeading => GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: softText,
      );

  static TextStyle get sansBody => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: softText,
      );

  static TextStyle get sansLabel => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: secondaryText,
      );

  // --- Animations ---
  static const Duration slow = Duration(milliseconds: 1200);
  static const Duration medium = Duration(milliseconds: 600);
  static const Duration fast = Duration(milliseconds: 300);

  // --- Shapes ---
  static const double cardRadius = 28.0;
  static BorderRadius premiumRadius = BorderRadius.circular(cardRadius);
  
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> premiumShadow = [
    BoxShadow(
      color: const Color(0xFF3E2723).withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  // --- Glow Effects ---
  static List<BoxShadow> goldGlow = [
    BoxShadow(
      color: radiantGold.withValues(alpha: 0.3),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
}
