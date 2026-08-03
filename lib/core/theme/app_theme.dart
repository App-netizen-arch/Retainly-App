import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData _base(ColorScheme colorScheme, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        labelStyle: TextStyle(color: colorScheme.onSurface),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  static ThemeData lightTheme() {
    return _base(
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF1B5E20),
        brightness: Brightness.light,
      ),
      Brightness.light,
    );
  }

  static ThemeData darkTheme() {
    return _base(
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF1B5E20),
        brightness: Brightness.dark,
      ),
      Brightness.dark,
    );
  }

  static ThemeData highContrastLightTheme() {
    return _base(
      const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF000000),
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFE0E0E0),
        onPrimaryContainer: Color(0xFF000000),
        secondary: Color(0xFF424242),
        onSecondary: Color(0xFFFFFFFF),
        tertiary: Color(0xFF616161),
        onTertiary: Color(0xFFFFFFFF),
        error: Color(0xFFB00020),
        onError: Color(0xFFFFFFFF),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF000000),
        onSurfaceVariant: Color(0xFF212121),
        outline: Color(0xFF000000),
        surfaceContainerHighest: Color(0xFFE0E0E0),
        surfaceContainerLowest: Color(0xFFFFFFFF),
        surfaceContainerLow: Color(0xFFFFFFFF),
        surfaceContainer: Color(0xFFF5F5F5),
        surfaceContainerHigh: Color(0xFFE0E0E0),
        surfaceBright: Color(0xFFFFFFFF),
        surfaceDim: Color(0xFFE0E0E0),
        inverseSurface: Color(0xFF212121),
        onInverseSurface: Color(0xFFFFFFFF),
        inversePrimary: Color(0xFFE0E0E0),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        errorContainer: Color(0xFFCF6679),
        onErrorContainer: Color(0xFF000000),
        onSecondaryContainer: Color(0xFF000000),
        onTertiaryContainer: Color(0xFF000000),
        outlineVariant: Color(0xFF757575),
        surfaceTint: Color(0xFF000000),
      ),
      Brightness.light,
    );
  }

  static ThemeData highContrastDarkTheme() {
    return _base(
      const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFFFFFFF),
        onPrimary: Color(0xFF000000),
        primaryContainer: Color(0xFF424242),
        onPrimaryContainer: Color(0xFFFFFFFF),
        secondary: Color(0xFFE0E0E0),
        onSecondary: Color(0xFF000000),
        tertiary: Color(0xFF9E9E9E),
        onTertiary: Color(0xFF000000),
        error: Color(0xFFCF6679),
        onError: Color(0xFF000000),
        surface: Color(0xFF121212),
        onSurface: Color(0xFFFFFFFF),
        onSurfaceVariant: Color(0xFFE0E0E0),
        outline: Color(0xFFFFFFFF),
        surfaceContainerHighest: Color(0xFF424242),
        surfaceContainerLowest: Color(0xFF000000),
        surfaceContainerLow: Color(0xFF1A1A1A),
        surfaceContainer: Color(0xFF212121),
        surfaceContainerHigh: Color(0xFF424242),
        surfaceBright: Color(0xFF2A2A2A),
        surfaceDim: Color(0xFF000000),
        inverseSurface: Color(0xFFE0E0E0),
        onInverseSurface: Color(0xFF000000),
        inversePrimary: Color(0xFF424242),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        errorContainer: Color(0xFFCF6679),
        onErrorContainer: Color(0xFF000000),
        onSecondaryContainer: Color(0xFF000000),
        onTertiaryContainer: Color(0xFF000000),
        outlineVariant: Color(0xFF9E9E9E),
        surfaceTint: Color(0xFFFFFFFF),
      ),
      Brightness.dark,
    );
  }
}
