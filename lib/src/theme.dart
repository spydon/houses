import 'package:flutter/material.dart';

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: dark ? const Color(0xFFF2B544) : const Color(0xFF8F5A00),
    onPrimary: dark ? const Color(0xFF241800) : const Color(0xFFFFFFFF),
    secondary: dark ? const Color(0xFF9DB0D3) : const Color(0xFF3A4C6E),
    onSecondary: dark ? const Color(0xFF0E1421) : const Color(0xFFFFFFFF),
    secondaryContainer: dark
        ? const Color(0xFF3A3020)
        : const Color(0xFFFBE7B8),
    onSecondaryContainer: dark
        ? const Color(0xFFF8DFA6)
        : const Color(0xFF3A2600),
    error: dark ? const Color(0xFFFFB4AB) : const Color(0xFFB3261E),
    onError: dark ? const Color(0xFF690005) : const Color(0xFFFFFFFF),
    surface: dark ? const Color(0xFF0E1421) : const Color(0xFFF3F5F8),
    onSurface: dark ? const Color(0xFFE6EAF1) : const Color(0xFF151C2B),
    onSurfaceVariant: dark ? const Color(0xFF9AA5B9) : const Color(0xFF586378),
    outline: dark ? const Color(0xFF3A4660) : const Color(0xFFC0C8D4),
    outlineVariant: dark ? const Color(0xFF243049) : const Color(0xFFDCE1E9),
    surfaceContainerLowest: dark
        ? const Color(0xFF0A0F1A)
        : const Color(0xFFFFFFFF),
    surfaceContainerLow: dark
        ? const Color(0xFF131B2B)
        : const Color(0xFFFAFBFC),
    surfaceContainer: dark ? const Color(0xFF182133) : const Color(0xFFECEFF4),
    surfaceContainerHigh: dark
        ? const Color(0xFF1E283C)
        : const Color(0xFFE5E9EF),
    surfaceContainerHighest: dark
        ? const Color(0xFF253047)
        : const Color(0xFFDDE2EA),
  );
  final base = ThemeData(
    colorScheme: scheme,
    brightness: brightness,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: scheme.surface,
  );
  const display = 'SpaceGrotesk';
  final text = base.textTheme;
  return base.copyWith(
    textTheme: text.copyWith(
      displayLarge: text.displayLarge?.copyWith(
        fontFamily: display,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
      ),
      displayMedium: text.displayMedium?.copyWith(
        fontFamily: display,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      ),
      displaySmall: text.displaySmall?.copyWith(
        fontFamily: display,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineMedium: text.headlineMedium?.copyWith(
        fontFamily: display,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: text.titleLarge?.copyWith(
        fontFamily: display,
        fontWeight: FontWeight.w600,
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
      side: BorderSide(color: scheme.outline),
      selectedColor: scheme.secondaryContainer,
      showCheckmark: false,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
  );
}
