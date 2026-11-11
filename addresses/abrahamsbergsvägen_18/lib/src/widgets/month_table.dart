import 'package:flutter/material.dart';

import '../day_profile.dart';
import '../stockholm_clock.dart';
import '../sun_palette.dart';

class MonthTable extends StatelessWidget {
  const MonthTable({
    required this.months,
    required this.selectedMonth,
    required this.spotName,
    super.key,
  });

  final List<DayProfile> months;
  final int selectedMonth;
  final String spotName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Text(
          'Month by month at the ${spotName.toLowerCase()}',
          style: theme.textTheme.titleLarge,
        ),
        Text(
          'For the 15th of each month, in Swedish time.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            final fill = constraints.maxWidth >= 640;
            final grid = _MonthGrid(
              months: months,
              selectedMonth: selectedMonth,
              fill: fill,
            );
            if (fill) {
              return grid;
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: grid,
            );
          },
        ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.months,
    required this.selectedMonth,
    required this.fill,
  });

  final List<DayProfile> months;
  final int selectedMonth;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = SunPalette.of(context);
    final base = theme.textTheme.bodyMedium!.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final header = base.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurfaceVariant,
    );
    const headings = ['Month', 'Sunrise', 'Sunset', 'Direct sun', 'Total'];
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: fill
          ? const {
              0: IntrinsicColumnWidth(),
              1: IntrinsicColumnWidth(),
              2: IntrinsicColumnWidth(),
              3: FlexColumnWidth(),
              4: IntrinsicColumnWidth(),
            }
          : const {
              0: IntrinsicColumnWidth(),
              1: IntrinsicColumnWidth(),
              2: IntrinsicColumnWidth(),
              3: IntrinsicColumnWidth(),
              4: IntrinsicColumnWidth(),
            },
      children: [
        TableRow(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          children: [
            for (final heading in headings) _Cell(text: heading, style: header),
          ],
        ),
        for (var i = 0; i < months.length; i++)
          TableRow(
            decoration: BoxDecoration(
              color: i + 1 == selectedMonth
                  ? palette.sun.withValues(alpha: 0.16)
                  : null,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.6,
                  ),
                ),
              ),
            ),
            children: [
              _Cell(
                text: monthNames[i],
                style: base.copyWith(
                  fontWeight: i + 1 == selectedMonth ? FontWeight.w600 : null,
                ),
              ),
              _Cell(text: formatClock(months[i].sunrise ?? 0), style: base),
              _Cell(text: formatClock(months[i].sunset ?? 0), style: base),
              _Cell(text: describeWindows(months[i].windows), style: base),
              _Cell(
                text: formatDuration(months[i].litMinutes),
                style: base.copyWith(
                  fontWeight: FontWeight.w600,
                  color: months[i].litMinutes > 0
                      ? palette.sunText
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      child: Text(text, style: style),
    );
  }
}
