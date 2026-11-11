import 'package:flutter/material.dart';

import '../day_profile.dart';
import '../site_model.dart';
import '../stockholm_clock.dart';
import '../sun_palette.dart';

class SpotSummary extends StatelessWidget {
  const SpotSummary({
    required this.spot,
    required this.profile,
    required this.minute,
    super.key,
  });

  final Spot spot;
  final DayProfile profile;
  final int minute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = SunPalette.of(context);
    final up = profile.sunAt(minute).elevation > 0;
    final lit = profile.isLitAt(minute);
    final status = !up
        ? 'Sun is down at ${formatClock(minute)}'
        : lit
        ? 'In sun at ${formatClock(minute)}'
        : 'In shade at ${formatClock(minute)}';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  spot.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _StatusPill(
                  text: status,
                  color: lit ? palette.sun : theme.colorScheme.outline,
                  foreground: lit
                      ? const Color(0xFF241800)
                      : theme.colorScheme.onSurface,
                ),
              ],
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: profile.litMinutes == 0
                        ? 'No direct sun'
                        : formatDuration(profile.litMinutes),
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: profile.litMinutes == 0
                          ? theme.colorScheme.onSurfaceVariant
                          : palette.sunText,
                    ),
                  ),
                  TextSpan(
                    text: profile.litMinutes == 0
                        ? '  on ${formatDate(profile.dayOfYear)}'
                        : '  of direct sun on ${formatDate(profile.dayOfYear)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              describeWindows(profile.windows),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.text,
    required this.color,
    required this.foreground,
  });

  final String text;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
