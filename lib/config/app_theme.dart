import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // =============================================
  // LIGHT THEME COLORS
  // =============================================
  static const Color primaryColor = Color(0xFF0D47A1);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color textColor = Color(0xFF1A1A2E);
  static const Color subtitleColor = Color(0xFF6B7280);
  static const Color cardColor = Color(0xFFFFFFFF);

  // =============================================
  // DARK THEME COLORS
  // =============================================
  static const Color darkPrimaryColor = Color(0xFF1565C0);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkTextColor = Color(0xFFE4E4E4);
  static const Color darkSubtitleColor = Color(0xFF9E9E9E);
  static const Color darkCardColor = Color(0xFF1E1E1E);

  // =============================================
  // LIGHT THEME
  // =============================================
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: GoogleFonts.poppins().fontFamily,
    useMaterial3: true,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w600, color: textColor),
        titleLarge: TextStyle(fontWeight: FontWeight.w600, color: textColor),
        titleMedium: TextStyle(fontWeight: FontWeight.w500, color: textColor),
        bodyMedium: TextStyle(color: textColor),
        bodySmall: TextStyle(color: subtitleColor),
      ),
    ),
  );

  // =============================================
  // DARK THEME
  // =============================================
  static ThemeData darkTheme = ThemeData(
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    fontFamily: GoogleFonts.poppins().fontFamily,
    useMaterial3: true,
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      backgroundColor: darkPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: darkCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w600, color: darkTextColor),
        titleLarge: TextStyle(fontWeight: FontWeight.w600, color: darkTextColor),
        titleMedium: TextStyle(fontWeight: FontWeight.w500, color: darkTextColor),
        bodyMedium: TextStyle(color: darkTextColor),
        bodySmall: TextStyle(color: darkSubtitleColor),
      ),
    ),
  );

  // =============================================
  // GET THEME BASED ON PREFERENCE
  // =============================================
  static ThemeData getTheme(bool isDark) {
    return isDark ? darkTheme : lightTheme;
  }
}