import 'dart:typed_data';

import 'site_model.dart';
import 'solar.dart';
import 'stockholm_clock.dart';

class TimeWindow {
  const TimeWindow(this.start, this.end);

  final int start;
  final int end;

  int get length => end - start;
}

class DayProfile {
  DayProfile._({
    required this.dayOfYear,
    required this.step,
    required this.elevations,
    required this.azimuths,
    required this.lit,
  });

  factory DayProfile.compute({
    required SiteModel model,
    required Float32List horizon,
    required int dayOfYear,
    int step = 1,
  }) {
    final count = 1440 ~/ step;
    final elevations = Float32List(count);
    final azimuths = Float32List(count);
    final lit = Uint8List(count);
    for (var i = 0; i < count; i++) {
      final sun = sunPositionAt(
        utcForLocal(dayOfYear, i * step),
        latitude: model.latitude,
        longitude: model.longitude,
      );
      elevations[i] = sun.elevation;
      azimuths[i] = sun.azimuth;
      lit[i] =
          sun.elevation > 0 && sun.elevation > horizonAt(horizon, sun.azimuth)
          ? 1
          : 0;
    }
    return DayProfile._(
      dayOfYear: dayOfYear,
      step: step,
      elevations: elevations,
      azimuths: azimuths,
      lit: lit,
    );
  }

  static const _upperLimb = -0.267;

  final int dayOfYear;
  final int step;
  final Float32List elevations;
  final Float32List azimuths;
  final Uint8List lit;

  int get length => elevations.length;

  int minuteAt(int index) => index * step;

  int indexFor(int minuteOfDay) => (minuteOfDay ~/ step).clamp(0, length - 1);

  SunPosition sunAt(int minuteOfDay) {
    final i = indexFor(minuteOfDay);
    return SunPosition(elevation: elevations[i], azimuth: azimuths[i]);
  }

  bool isLitAt(int minuteOfDay) => lit[indexFor(minuteOfDay)] == 1;

  int? get sunrise {
    for (var i = 0; i < length; i++) {
      if (elevations[i] > _upperLimb) {
        return minuteAt(i);
      }
    }
    return null;
  }

  int? get sunset {
    for (var i = length - 1; i >= 0; i--) {
      if (elevations[i] > _upperLimb) {
        return minuteAt(i);
      }
    }
    return null;
  }

  int get noon {
    var best = 0;
    for (var i = 1; i < length; i++) {
      if (elevations[i] > elevations[best]) {
        best = i;
      }
    }
    return minuteAt(best);
  }

  double get noonElevation => elevations[indexFor(noon)];

  int get litMinutes {
    var count = 0;
    for (var i = 0; i < length; i++) {
      count += lit[i];
    }
    return count * step;
  }

  List<TimeWindow> get windows {
    final raw = <TimeWindow>[];
    int? start;
    for (var i = 0; i <= length; i++) {
      final isLit = i < length && lit[i] == 1;
      if (isLit && start == null) {
        start = minuteAt(i);
      } else if (!isLit && start != null) {
        raw.add(TimeWindow(start, minuteAt(i)));
        start = null;
      }
    }
    final merged = <TimeWindow>[];
    for (final window in raw) {
      if (merged.isNotEmpty && window.start - merged.last.end < 10) {
        merged[merged.length - 1] = TimeWindow(merged.last.start, window.end);
      } else {
        merged.add(window);
      }
    }
    return [
      for (final window in merged)
        if (window.length >= 10) window,
    ];
  }
}

String describeWindows(List<TimeWindow> windows) {
  if (windows.isEmpty) {
    return 'No direct sun';
  }
  return windows
      .map((w) => '${formatClock(w.start)} to ${formatClock(w.end)}')
      .join(', ');
}
