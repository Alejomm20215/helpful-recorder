import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFFF3B30), // Red
      secondary: Color(0xFFFFFFFF), // White
      surface: Colors.white,
      onSurface: Colors.black,
    ),
    useMaterial3: true,
  );

  static final darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF000000),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFF3B30), // Red
      secondary: Color(0xFFFFFFFF), // White
      surface: Color(0xFF1E1E1E),
      onSurface: Colors.white,
    ),
    useMaterial3: true,
  );
}
