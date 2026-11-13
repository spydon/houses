import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sun_study/sun_study.dart';

void main() {
  final model = SiteModel.fromJson(
    jsonDecode(File('assets/surface_model.json').readAsStringSync())
        as Map<String, dynamic>,
  );
  final pool = model.spots.firstWhere((spot) => spot.name == 'Pool');
  final horizon = model.horizon(pool.east, pool.north);

  DayProfile profile(int month, int day) => DayProfile.compute(
    model: model,
    horizon: horizon,
    dayOfYear: dayOfYearFor(month, day),
  );

  group('sun position', () {
    test('midsummer sunrise and sunset match Stockholm almanac times', () {
      final midsummer = profile(6, 21);
      expect(midsummer.sunrise, inInclusiveRange(3 * 60 + 32, 3 * 60 + 36));
      expect(midsummer.sunset, inInclusiveRange(22 * 60 + 3, 22 * 60 + 7));
      expect(midsummer.noonElevation, closeTo(54.2, 0.3));
    });

    test('winter solstice sun stays low', () {
      final winter = profile(12, 21);
      expect(winter.sunrise, inInclusiveRange(8 * 60 + 42, 8 * 60 + 46));
      expect(winter.noonElevation, closeTo(7.4, 0.3));
    });
  });

  group('pool', () {
    test('the horizon to the south and west is low', () {
      expect(horizonAt(horizon, 180), closeTo(20.8, 1.5));
      expect(horizonAt(horizon, 270), closeTo(7.8, 1.5));
    });

    test('June sun matches the reference model', () {
      final june = profile(6, 15);
      final windows = june.windows;
      expect(windows, isNotEmpty);
      expect(windows.first.start, inInclusiveRange(6 * 60 + 43, 6 * 60 + 53));
      expect(windows.first.end, inInclusiveRange(18 * 60 + 36, 18 * 60 + 46));
    });

    test('no direct sun in December', () {
      expect(profile(12, 15).litMinutes, 0);
    });
  });

  group('west end of the pool', () {
    final spot = model.spots.firstWhere(
      (spot) => spot.name == 'West end of the pool',
    );
    final westHorizon = model.horizon(spot.east, spot.north);

    test('the hedge by the road blocks the afternoon sun', () {
      expect(horizonAt(westHorizon, 250), greaterThan(45));
      final june = DayProfile.compute(
        model: model,
        horizon: westHorizon,
        dayOfYear: dayOfYearFor(6, 15),
      );
      expect(june.windows.last.end, lessThan(15 * 60));
    });
  });
}
