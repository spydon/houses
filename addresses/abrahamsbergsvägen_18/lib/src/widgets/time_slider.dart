import 'package:flutter/material.dart';

import '../day_profile.dart';
import '../stockholm_clock.dart';
import '../sun_palette.dart';
import 'slider_parts.dart';

class TimeSlider extends StatelessWidget {
  const TimeSlider({
    required this.minute,
    required this.profile,
    required this.spotName,
    required this.onChanged,
    super.key,
  });

  static const _maxMinute = 1435;

  final int minute;
  final DayProfile profile;
  final String spotName;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = SunPalette.of(context);
    final colors = [
      for (var m = 0; m <= _maxMinute; m += 15)
        palette.forElevation(profile.sunAt(m).elevation),
    ];
    final ticks = [
      for (var hour = 0; hour < 24; hour += 2)
        Tick(hour * 60 / _maxMinute, '$hour'),
    ];
    final litMinutes = profile.litMinutes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        SliderHeading(
          label: 'Time',
          value: formatClock(minute),
          detail: profile.isLitAt(minute)
              ? 'Sun at the ${spotName.toLowerCase()}'
              : 'Shade at the ${spotName.toLowerCase()}',
        ),
        SunSliderTheme(
          colors: colors,
          child: Slider(
            value: minute.toDouble(),
            max: _maxMinute.toDouble(),
            divisions: _maxMinute ~/ 5,
            onChanged: (value) => onChanged(value.round()),
            semanticFormatterCallback: (value) => formatClock(value.round()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: trackInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              TickLabels(ticks: ticks, labelWidth: 28),
              SpotStrip(
                values: [
                  for (var m = 0; m <= _maxMinute; m += 5)
                    profile.isLitAt(m) ? 1.0 : 0.0,
                ],
                label:
                    'Direct sun at the ${spotName.toLowerCase()} on this day, '
                    '${formatDuration(litMinutes)} in total',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
