import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: Colors.indigo,
    colorScheme: const ColorScheme.light(
      primary: Colors.indigo,
      secondary: Colors.deepPurple,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.indigo,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        side: BorderSide.none,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Colors.indigo, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: Colors.deepPurple,
    colorScheme: const ColorScheme.dark(
      primary: Colors.deepPurple,
      secondary: Colors.purpleAccent,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    scaffoldBackgroundColor: Colors.grey[900],
    cardColor: Colors.grey[850],
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[850],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    ),
  );
}
