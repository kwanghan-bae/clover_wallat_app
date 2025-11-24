import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CloverTheme {
  static const Color primaryColor = Color(0xFF4CAF50); // Clover Green
  static const Color secondaryColor = Color(0xFFFFC107); // Gold Yellow
  static const Color accentColor = Color(0xFF2196F3); // Sky Blue
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color white = Color(0xFFFFFFFF);

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: backgroundColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: GoogleFonts.notoSansKrTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: textDark),
          displayMedium: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
          bodyLarge: TextStyle(fontSize: 16, color: textDark),
          bodyMedium: TextStyle(fontSize: 14, color: textLight),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
