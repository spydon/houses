import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../stockholm_clock.dart';
import '../sun_palette.dart';
import 'slider_parts.dart';

class YearSlider extends StatelessWidget {
  const YearSlider({
    required this.latitude,
    required this.dayOfYear,
    required this.litMinutes,
    required this.spotName,
    required this.onChanged,
    super.key,
  });

  final double latitude;
  final int dayOfYear;
  final Int32List litMinutes;
  final String spotName;
  final ValueChanged<int> onChanged;

  double _dayLength(int day) {
    final declination =
        23.44 * math.sin(2 * math.pi * (284 + day) / 365) * math.pi / 180;
    final lat = latitude * math.pi / 180;
    final cosHour =
        (math.sin(-0.833 * math.pi / 180) -
            math.sin(lat) * math.sin(declination)) /
        (math.cos(lat) * math.cos(declination));
    return 2 * math.acos(cosHour.clamp(-1.0, 1.0)) * 180 / math.pi / 15;
  }

  @override
  Widget build(BuildContext context) {
    final palette = SunPalette.of(context);
    final colors = [
      for (var day = 1; day <= daysInYear; day += 8)
        Color.lerp(
          palette.night,
          palette.day,
          ((_dayLength(day) - 6.2) / 12.4).clamp(0.0, 1.0),
        )!,
    ];
    final best = litMinutes.fold<int>(1, math.max);
    final ticks = [
      for (var month = 1; month <= 12; month++)
        Tick(
          (dayOfYearFor(month, 15) - 1) / (daysInYear - 1),
          monthNames[month - 1],
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        SliderHeading(
          label: 'Month',
          value: partOfMonth(dayOfYear),
          detail: formatDate(dayOfYear),
        ),
        SunSliderTheme(
          colors: colors,
          child: Slider(
            value: dayOfYear.toDouble(),
            min: 1,
            max: daysInYear.toDouble(),
            divisions: daysInYear - 1,
            onChanged: (value) => onChanged(value.round()),
            semanticFormatterCallback: (value) => formatDate(value.round()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: trackInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              TickLabels(ticks: ticks, labelWidth: 80),
              SpotStrip(
                values: [for (final minutes in litMinutes) minutes / best],
                label:
                    'Direct sun at the ${spotName.toLowerCase()} through the year, '
                    'at most ${formatDuration(best)} a day',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
