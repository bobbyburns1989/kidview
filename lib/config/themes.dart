import 'package:flutter/material.dart';

class AppThemes {
  // Colors for younger children (4-7)
  static const Color primaryYounger = Color(0xFF6C63FF);
  static const Color secondaryYounger = Color(0xFFFF6584);
  static const Color backgroundYounger = Color(0xFFFFF9C4);
  static const Color accentYounger = Color(0xFF4CAF50);
  
  // Colors for older children (8-12)
  static const Color primaryOlder = Color(0xFF3F51B5);
  static const Color secondaryOlder = Color(0xFF00BCD4);
  static const Color backgroundOlder = Color(0xFFE3F2FD);
  static const Color accentOlder = Color(0xFF009688);
  
  // Parent dashboard colors
  static const Color primaryParent = Color(0xFF37474F);
  static const Color primaryDark = Color(0xFF37474F); // For backwards compatibility
  static const Color secondaryParent = Color(0xFF546E7A);
  static const Color backgroundParent = Color(0xFFF5F5F5);
  static const Color accentParent = Color(0xFF2196F3);
  
  // Helper function for safe opacity handling (to replace deprecated withOpacity)
  static Color withTransparency(Color color, double opacity) {
    return color.withAlpha((opacity * 255).round());
  }

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryParent,
        brightness: Brightness.light,
      ),
      fontFamily: 'Nunito',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: primaryParent,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: primaryParent,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      cardTheme: CardTheme(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryParent,
        brightness: Brightness.dark,
      ),
      fontFamily: 'Nunito',
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.grey.shade900,
        titleTextStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade800,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      cardTheme: CardTheme(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}