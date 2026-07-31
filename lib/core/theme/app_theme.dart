import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData _base(ColorScheme colorScheme, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          brightness == Brightness.dark
              ? const Color(0xFF121212)
              : const Color(0xFFFAFAFA),
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
      ),
      Brightness.dark,
    );
  }
}
