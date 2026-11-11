import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'day_profile.dart';
import 'shadow_field.dart';
import 'site_model.dart';
import 'stockholm_clock.dart';
import 'sun_palette.dart';
import 'widgets/day_summary.dart';
import 'widgets/horizon_chart.dart';
import 'widgets/method_notes.dart';
import 'widgets/month_table.dart';
import 'widgets/shadow_map.dart';
import 'widgets/spot_picker.dart';
import 'widgets/spot_summary.dart';
import 'widgets/sun_page_header.dart';
import 'widgets/time_slider.dart';
import 'widgets/year_slider.dart';

class SunPage extends StatefulWidget {
  const SunPage({super.key});

  @override
  State<SunPage> createState() => _SunPageState();
}

class _SunPageState extends State<SunPage> {
  late final Future<SiteModel> _model = SiteModel.load();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<SiteModel>(
        future: _model,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _LoadMessage(
              text: 'The terrain model could not be loaded. Reload the page to try again.',
            );
          }
          final model = snapshot.data;
          if (model == null) {
            return const _LoadMessage(
              text: 'Loading the terrain and tree model',
            );
          }
          return SunExplorer(model: model);
        },
      ),
    );
  }
}

class _LoadMessage extends StatelessWidget {
  const _LoadMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class SunExplorer extends StatefulWidget {
  const SunExplorer({required this.model, super.key});

  final SiteModel model;

  @override
  State<SunExplorer> createState() => _SunExplorerState();
}

class _SunExplorerState extends State<SunExplorer> {
  late final ShadowField _field = ShadowField(widget.model);
  late Spot _spot = widget.model.spots.first;
  late Float32List _horizon;
  late DayProfile _day;
  late List<DayProfile> _months;
  late Int32List _yearLitMinutes;
  int _dayOfYear = dayOfYearFor(7, 3);
  int _minute = 11 * 60;
  ui.Image? _shadow;
  SunPalette? _palette;
  bool _rendering = false;
  bool _dirty = false;

  SiteModel get _model => widget.model;

  @override
  void initState() {
    super.initState();
    _computeSpot();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final palette = SunPalette.of(context);
    if (_palette?.shadeOverlay != palette.shadeOverlay) {
      _palette = palette;
      _requestShadow();
    }
  }

  @override
  void dispose() {
    _shadow?.dispose();
    super.dispose();
  }

  void _computeSpot() {
    _horizon = _model.horizon(_spot.east, _spot.north);
    _day = DayProfile.compute(
      model: _model,
      horizon: _horizon,
      dayOfYear: _dayOfYear,
    );
    _months = [
      for (var month = 1; month <= 12; month++)
        DayProfile.compute(
          model: _model,
          horizon: _horizon,
          dayOfYear: dayOfYearFor(month, 15),
          step: 2,
        ),
    ];
    _yearLitMinutes = Int32List(daysInYear);
    for (var day = 1; day <= daysInYear; day++) {
      _yearLitMinutes[day - 1] = DayProfile.compute(
        model: _model,
        horizon: _horizon,
        dayOfYear: day,
        step: 10,
      ).litMinutes;
    }
  }

  Future<void> _requestShadow() async {
    if (_rendering) {
      _dirty = true;
      return;
    }
    _rendering = true;
    do {
      _dirty = false;
      final palette = _palette;
      if (palette == null) {
        break;
      }
      final image = await _field.render(
        sun: _day.sunAt(_minute),
        litColor: palette.litOverlay,
        shadeColor: palette.shadeOverlay,
        nightColor: palette.nightOverlay,
      );
      if (!mounted) {
        image.dispose();
        _rendering = false;
        return;
      }
      setState(() {
        _shadow?.dispose();
        _shadow = image;
      });
    } while (_dirty);
    _rendering = false;
  }

  void _setDay(int dayOfYear) {
    if (dayOfYear == _dayOfYear) {
      return;
    }
    setState(() {
      _dayOfYear = dayOfYear;
      _day = DayProfile.compute(
        model: _model,
        horizon: _horizon,
        dayOfYear: dayOfYear,
      );
    });
    _requestShadow();
  }

  void _setMinute(int minute) {
    if (minute == _minute) {
      return;
    }
    setState(() => _minute = minute);
    _requestShadow();
  }

  void _setSpot(Spot spot) {
    setState(() {
      _spot = spot;
      _computeSpot();
    });
  }

  void _showToday() {
    final now = stockholmNow();
    setState(() {
      _minute = (now.minuteOfDay ~/ 5) * 5;
    });
    if (now.dayOfYear != _dayOfYear) {
      _setDay(now.dayOfYear);
    } else {
      _requestShadow();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sun = _day.sunAt(_minute);
    final header = SunPageHeader(
      onBack: () => Navigator.of(context).maybePop(),
    );
    final map = ShadowMap(
      model: _model,
      field: _field,
      shadow: _shadow,
      spot: _spot,
      sun: sun,
      isLit: _day.isLitAt(_minute),
      dayOfYear: _dayOfYear,
      minute: _minute,
      onSpotSelected: _setSpot,
    );
    final picker = SpotPicker(
      spots: _model.spots,
      selected: _spot,
      onSelected: _setSpot,
    );
    final summary = DaySummary(
      profile: _day,
      dayOfYear: _dayOfYear,
      onShowToday: _showToday,
    );
    final yearSlider = YearSlider(
      dayOfYear: _dayOfYear,
      litMinutes: _yearLitMinutes,
      spotName: _spot.name,
      onChanged: _setDay,
    );
    final timeSlider = TimeSlider(
      minute: _minute,
      profile: _day,
      spotName: _spot.name,
      onChanged: _setMinute,
    );
    final spotSummary = SpotSummary(
      spot: _spot,
      profile: _day,
      minute: _minute,
    );
    final chart = HorizonChart(
      horizon: _horizon,
      profile: _day,
      minute: _minute,
      spotName: _spot.name,
    );
    final table = MonthTable(
      months: _months,
      selectedMonth: dateForDay(_dayOfYear).month,
      spotName: _spot.name,
    );
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1000;
          final gutter = constraints.maxWidth >= 600 ? 32.0 : 16.0;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: gutter, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: wide
                    ? _WideLayout(
                        header: header,
                        map: map,
                        picker: picker,
                        summary: summary,
                        yearSlider: yearSlider,
                        timeSlider: timeSlider,
                        spotSummary: spotSummary,
                        chart: chart,
                        table: table,
                      )
                    : _NarrowLayout(
                        header: header,
                        map: map,
                        picker: picker,
                        summary: summary,
                        yearSlider: yearSlider,
                        timeSlider: timeSlider,
                        spotSummary: spotSummary,
                        chart: chart,
                        table: table,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.header,
    required this.map,
    required this.picker,
    required this.summary,
    required this.yearSlider,
    required this.timeSlider,
    required this.spotSummary,
    required this.chart,
    required this.table,
  });

  final Widget header;
  final Widget map;
  final Widget picker;
  final Widget summary;
  final Widget yearSlider;
  final Widget timeSlider;
  final Widget spotSummary;
  final Widget chart;
  final Widget table;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 28,
      children: [
        header,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 36,
          children: [
            Expanded(
              flex: 11,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [map, picker],
              ),
            ),
            Expanded(
              flex: 9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 24,
                children: [summary, yearSlider, timeSlider, spotSummary],
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 36,
          children: [
            Expanded(flex: 11, child: table),
            Expanded(flex: 9, child: chart),
          ],
        ),
        const MethodNotes(),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({
    required this.header,
    required this.map,
    required this.picker,
    required this.summary,
    required this.yearSlider,
    required this.timeSlider,
    required this.spotSummary,
    required this.chart,
    required this.table,
  });

  final Widget header;
  final Widget map;
  final Widget picker;
  final Widget summary;
  final Widget yearSlider;
  final Widget timeSlider;
  final Widget spotSummary;
  final Widget chart;
  final Widget table;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        header,
        summary,
        map,
        picker,
        yearSlider,
        timeSlider,
        spotSummary,
        chart,
        table,
        const MethodNotes(),
      ],
    );
  }
}
