import 'package:flutter/material.dart';
import 'package:yellow_flowers/core/design_system.dart';

class AppTheme {
  static const Color primaryYellow = PremiumDesign.radiantGold;
  static const Color accentPink = PremiumDesign.pastelPink;
  static const Color backgroundCream = PremiumDesign.cream;
  static const Color textDark = PremiumDesign.softText;
  static const Color leafGreen = PremiumDesign.leafGreen;
  static const Color sunnyGold = PremiumDesign.radiantGold;

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundCream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryYellow,
        primary: sunnyGold,
        secondary: accentPink,
        tertiary: leafGreen,
        surface: Colors.white,
        onSurface: textDark,
        brightness: Brightness.light,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: PremiumDesign.serifHeading,
        displayMedium: PremiumDesign.serifSubHeading,
        bodyLarge: PremiumDesign.sansBody,
        bodyMedium: PremiumDesign.sansLabel,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: PremiumDesign.premiumRadius,
          side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sunnyGold,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: PremiumDesign.premiumRadius,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: PremiumDesign.darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryYellow,
        primary: PremiumDesign.radiantGold,
        secondary: const Color(0xFFE91E63), // Softened Pink
        tertiary: const Color(0xFF81C784), // Softened Green
        surface: PremiumDesign.darkSurface,
        onSurface: Colors.white.withValues(alpha: 0.9),
        brightness: Brightness.dark,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: PremiumDesign.serifHeading.copyWith(color: Colors.white),
        displayMedium:
            PremiumDesign.serifSubHeading.copyWith(color: Colors.white70),
        bodyLarge: PremiumDesign.sansBody.copyWith(color: Colors.white),
        bodyMedium: PremiumDesign.sansLabel.copyWith(color: Colors.white60),
      ),
      cardTheme: CardThemeData(
        color: PremiumDesign.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: PremiumDesign.premiumRadius,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PremiumDesign.radiantGold,
          foregroundColor: Colors.black87,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: PremiumDesign.premiumRadius,
          ),
        ),
      ),
    );
  }
}
