import 'package:flutter/material.dart';

import '../day_profile.dart';
import '../stockholm_clock.dart';

class DaySummary extends StatelessWidget {
  const DaySummary({
    required this.profile,
    required this.dayOfYear,
    required this.onShowToday,
    super.key,
  });

  final DayProfile profile;
  final int dayOfYear;
  final VoidCallback onShowToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sunrise = profile.sunrise;
    final sunset = profile.sunset;
    final period = partOfMonth(dayOfYear);
    final text = sunrise == null || sunset == null
        ? 'In $period the sun stays below the horizon.'
        : 'In $period the sun rises at ${formatClock(sunrise)} and sets at '
              '${formatClock(sunset)}. It is highest at '
              '${formatClock(profile.noon)}, '
              '${profile.noonElevation.round()}° above the horizon.';
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        Text(text, style: theme.textTheme.bodyLarge),
        TextButton(
          onPressed: onShowToday,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minimumSize: const Size(0, 32),
          ),
          child: const Text('Show today'),
        ),
      ],
    );
  }
}
