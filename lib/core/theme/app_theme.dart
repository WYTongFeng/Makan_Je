// path: lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryOrange = Color(0xFFF9943B);
  static const Color lightOrange = Color(0xFFFFB38A);
  static const Color paleYellow = Color(0xFFF8F7DA);
  static const Color darkRed = Color(0xFF5C0601);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGrey = Color(
    0xFF333333,
  ); // Used for high-contrast text

  // Define global ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryOrange,
      scaffoldBackgroundColor: paleYellow, // App's default background color
      // Font settings
      fontFamily: 'Roboto',

      // Global button style settings
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange, // The button is orange by default.
          foregroundColor: white, // Button text is white by default.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Rounded corner design
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      // Top navigation bar style
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: darkGrey,
        elevation: 0, // flat design
      ),
    );
  }
}
