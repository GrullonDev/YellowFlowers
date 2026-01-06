import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de Colores "Jardín Cálido"
  static const Color primaryYellow = Color(0xFFFFF9C4); // Amarillo suave
  static const Color accentPink = Color(0xFFF8BBD0); // Rosa pastel
  static const Color backgroundCream = Color(0xFFFFF8E1); // Crema muy suave
  static const Color textDark =
      Color(0xFF4E342E); // Marrón café suave (más cálido que negro)
  static const Color leafGreen = Color(0xFFA5D6A7); // Verde hoja suave
  static const Color sunnyGold =
      Color(0xFFFFB300); // Dorado para acentos fuertes

  static ThemeData get lightTheme {
    return ThemeData(
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

      // Tipografía (Fallback a fuentes del sistema por problemas de red)
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontFamily: 'Georgia', // Serif elegante como Playball
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        displayMedium: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineLarge: const TextStyle(
          fontFamily: 'Verdana', // Sans-serif moderno como Outfit
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        headlineMedium: const TextStyle(
          fontFamily: 'Verdana',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: const TextStyle(
          fontFamily: 'Verdana',
          fontSize: 16,
          color: textDark,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Verdana',
          fontSize: 14,
          color: textDark.withValues(alpha: 0.8),
        ),
      ),

      // Estilo de Tarjetas
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4,
        shadowColor: textDark.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Estilo de Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sunnyGold,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: sunnyGold.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Verdana',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Estilo de AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 26,
          color: textDark,
        ),
      ),
    );
  }
}
