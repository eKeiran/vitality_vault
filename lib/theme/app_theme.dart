import 'package:flutter/material.dart';

class AppTheme {
  // Google-inspired colors
  static const Color googleBlue = Color(0xFF4285F4); // Primary
  static const Color googleGreen = Color(0xFF34A853); // Secondary
  static const Color googleYellow = Color(0xFFFBBC05); // Accent
  static const Color googleRed = Color(0xFFEA4335); // Highlight

  // Light mode colors
  static const Color lightBackground = Color(0xFFF5F6F5); // Soft off-white
  static const Color lightCard = Colors.white70; // Glassy white
  static const Color lightTextPrimary = Color(0xFF202124); // Dark gray for text
  static const Color lightTextSecondary = Color(0xFF5F6368); // Lighter gray

  // Dark mode colors
  static const Color darkBackground = Color(0xFF202124); // Deep gray
  static const Color darkCard = Color(0xFF303134); // Glassy dark gray
  static const Color darkTextPrimary = Color(0xFFE8EAED); // Light gray for text
  static const Color darkTextSecondary = Color(0xFFBDC1C6); // Softer gray

  static final ThemeData lightTheme = ThemeData(
    primaryColor: googleBlue,
    scaffoldBackgroundColor: lightBackground,
    cardColor: lightCard,
    colorScheme: ColorScheme.light(
      primary: googleBlue,
      secondary: googleGreen,
      tertiary: googleYellow,
      error: googleRed,
      surface: lightCard.withOpacity(0.9), // Glassy effect
      background: lightBackground,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: lightTextSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.white, // For buttons
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: googleBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: googleBlue,
        side: BorderSide(color: googleBlue.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: googleBlue.withOpacity(0.9),
    scaffoldBackgroundColor: darkBackground,
    cardColor: darkCard,
    colorScheme: ColorScheme.dark(
      primary: googleBlue.withOpacity(0.9),
      secondary: googleGreen.withOpacity(0.9),
      tertiary: googleYellow.withOpacity(0.9),
      error: googleRed.withOpacity(0.9),
      surface: darkCard.withOpacity(0.9), // Glassy effect
      background: darkBackground,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: darkTextPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: darkTextSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black, // For buttons
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: googleBlue.withOpacity(0.9),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: googleBlue.withOpacity(0.9),
        side: BorderSide(color: googleBlue.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    useMaterial3: true,
  );

  // Gradients for glassy effects
  static final LinearGradient lightGradient = LinearGradient(
    colors: [
      googleBlue.withOpacity(0.2),
      googleGreen.withOpacity(0.2),
      googleYellow.withOpacity(0.2),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient darkGradient = LinearGradient(
    colors: [
      googleBlue.withOpacity(0.3),
      googleGreen.withOpacity(0.3),
      googleYellow.withOpacity(0.3),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}