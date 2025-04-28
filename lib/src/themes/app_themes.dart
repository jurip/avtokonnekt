import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  static const _seedColor = Colors.blue;

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    ).copyWith(
      surface: Color.fromARGB(255, 130, 238, 255),
      background: Color.fromARGB(255, 130, 238, 255),
      surfaceContainerLowest: Color.fromARGB(255, 130, 238, 255),
      surfaceContainerLow: Color.fromARGB(255, 130, 238, 255),
      surfaceContainer: Color.fromARGB(255, 130, 238, 255),
      surfaceContainerHigh: Color.fromARGB(255, 130, 238, 255),
      surfaceContainerHighest: Color.fromARGB(255, 130, 238, 255),
    ),
    scaffoldBackgroundColor: Color.fromARGB(255, 130, 238, 255),
    cardTheme: const CardTheme(
      color: Color.fromARGB(255, 130, 238, 255),
      surfaceTintColor: Colors.transparent,
    ),
    textTheme: GoogleFonts.libreFranklinTextTheme(
      ThemeData.light().textTheme.copyWith(
            labelLarge: const TextStyle(
              letterSpacing: 0.5,
            ),
            bodyMedium: TextStyle(
              color: Colors.grey[800],
            ),
          ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _seedColor,
        foregroundColor: Colors.white,
      ),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.libreFranklinTextTheme(
      ThemeData.dark().textTheme.copyWith(
            displayLarge: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
            labelLarge: const TextStyle(
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
    ),
  );
}