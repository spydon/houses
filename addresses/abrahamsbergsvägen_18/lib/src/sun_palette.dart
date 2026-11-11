import 'package:flutter/material.dart';

class SunPalette {
  const SunPalette({
    required this.sun,
    required this.sunText,
    required this.day,
    required this.twilight,
    required this.night,
    required this.shadeOverlay,
    required this.litOverlay,
    required this.nightOverlay,
    required this.skyline,
    required this.grid,
  });

  factory SunPalette.of(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (scheme.brightness == Brightness.dark) {
      return SunPalette(
        sun: const Color(0xFFF4B740),
        sunText: const Color(0xFFF6C764),
        day: const Color(0xFFE2BE62),
        twilight: const Color(0xFF5A6884),
        night: const Color(0xFF2B3650),
        shadeOverlay: const Color(0xA6040814),
        litOverlay: const Color(0x14F4B740),
        nightOverlay: const Color(0xC8050A16),
        skyline: scheme.onSurface.withValues(alpha: 0.22),
        grid: scheme.onSurface.withValues(alpha: 0.08),
      );
    }
    return SunPalette(
      sun: const Color(0xFFF1A91C),
      sunText: const Color(0xFF9A5F00),
      day: const Color(0xFFF7D774),
      twilight: const Color(0xFFB5BFD0),
      night: const Color(0xFF8E9AB1),
      shadeOverlay: const Color(0x9C17213D),
      litOverlay: const Color(0x1AF1A91C),
      nightOverlay: const Color(0xBE101830),
      skyline: scheme.onSurface.withValues(alpha: 0.16),
      grid: scheme.onSurface.withValues(alpha: 0.07),
    );
  }

  final Color sun;
  final Color sunText;
  final Color day;
  final Color twilight;
  final Color night;
  final Color shadeOverlay;
  final Color litOverlay;
  final Color nightOverlay;
  final Color skyline;
  final Color grid;

  Color forElevation(double elevation) {
    if (elevation > 6) {
      return day;
    }
    if (elevation > 0) {
      return Color.lerp(twilight, day, elevation / 6)!;
    }
    if (elevation > -6) {
      return Color.lerp(night, twilight, (elevation + 6) / 6)!;
    }
    return night;
  }
}
