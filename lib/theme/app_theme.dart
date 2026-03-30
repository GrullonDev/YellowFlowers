import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yellow_flowers/core/design_system.dart';

ThemeData buildLightTheme({Color seedColor = PremiumDesign.radiantGold}) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: seedColor,
    textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
      displayLarge: PremiumDesign.serifHeading,
      displayMedium: PremiumDesign.serifSubHeading,
      bodyLarge: PremiumDesign.sansBody,
      labelLarge: PremiumDesign.sansLabel,
    ),
  );
  final scheme = base.colorScheme;
  return base.copyWith(
    scaffoldBackgroundColor: PremiumDesign.cream,
    chipTheme: base.chipTheme.copyWith(
      selectedColor: scheme.primary,
      disabledColor: scheme.surfaceContainerHighest,
      secondarySelectedColor: scheme.primary,
      labelStyle: TextStyle(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      ),
      side: BorderSide(color: scheme.outlineVariant, width: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        textStyle: PremiumDesign.sansLabel.copyWith(
          color: scheme.onPrimary,
          letterSpacing: 0.5,
        ),
        shape:
            RoundedRectangleBorder(borderRadius: PremiumDesign.premiumRadius),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(
            color: scheme.primary.withValues(alpha: 0.4), width: 1.2),
        shape:
            RoundedRectangleBorder(borderRadius: PremiumDesign.premiumRadius),
        textStyle: PremiumDesign.sansLabel.copyWith(
          color: scheme.primary,
          letterSpacing: 0.5,
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
      ),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
            color: scheme.primary.withValues(alpha: 0.5), width: 1.5),
      ),
      labelStyle: PremiumDesign.sansLabel.copyWith(
        color: scheme.onSurface.withValues(alpha: 0.6),
      ),
    ),
    dialogTheme: base.dialogTheme.copyWith(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: PremiumDesign.premiumRadius),
      elevation: 4,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: PremiumDesign.serifSubHeading.copyWith(fontSize: 22),
      iconTheme: IconThemeData(color: scheme.onSurface),
    ),
  );
}

ThemeData buildDarkTheme({Color seedColor = PremiumDesign.radiantGold}) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: seedColor,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme)
        .copyWith(
      displayLarge: PremiumDesign.serifHeading.copyWith(color: Colors.white),
      displayMedium:
          PremiumDesign.serifSubHeading.copyWith(color: Colors.white),
      bodyLarge: PremiumDesign.sansBody.copyWith(color: Colors.white70),
      labelLarge: PremiumDesign.sansLabel.copyWith(color: Colors.white60),
    ),
  );
  return base.copyWith(
    scaffoldBackgroundColor: PremiumDesign.darkBackground,
    colorScheme: base.colorScheme.copyWith(
      surface: PremiumDesign.darkSurface,
      surfaceContainer: PremiumDesign.darkCard,
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: PremiumDesign.darkSurface,
      labelStyle: const TextStyle(color: Colors.white70),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: PremiumDesign.radiantGold,
        foregroundColor: Colors.black,
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: PremiumDesign.premiumRadius),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
      ).copyWith(
        shadowColor: WidgetStateProperty.all(
            PremiumDesign.radiantGold.withValues(alpha: 0.3)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: PremiumDesign.radiantGold,
        side:
            BorderSide(color: PremiumDesign.radiantGold.withValues(alpha: 0.5)),
        shape:
            RoundedRectangleBorder(borderRadius: PremiumDesign.premiumRadius),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: PremiumDesign.darkDivider,
      thickness: 1,
    ),
    dialogTheme: base.dialogTheme.copyWith(
      backgroundColor: PremiumDesign.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: PremiumDesign.premiumRadius),
    ),
  );
}
