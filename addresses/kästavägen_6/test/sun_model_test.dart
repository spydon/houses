import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sun_study/sun_study.dart';

void main() {
  final model = SiteModel.fromJson(
    jsonDecode(File('assets/surface_model.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  Float32List horizonFor(String name) {
    final spot = model.spots.firstWhere((spot) => spot.name == name);
    return model.horizon(spot.east, spot.north);
  }

  DayProfile profile(Float32List horizon, int month, int day) =>
      DayProfile.compute(
        model: model,
        horizon: horizon,
        dayOfYear: dayOfYearFor(month, day),
      );

  group('sun position', () {
    final horizon = horizonFor('Middle of the lawn');

    test('midsummer sunrise and sunset match Stockholm almanac times', () {
      final midsummer = profile(horizon, 6, 21);
      expect(midsummer.sunrise, inInclusiveRange(3 * 60 + 32, 3 * 60 + 36));
      expect(midsummer.sunset, inInclusiveRange(22 * 60 + 4, 22 * 60 + 8));
      expect(midsummer.noonElevation, closeTo(54.2, 0.3));
    });

    test('winter solstice sun stays low', () {
      final winter = profile(horizon, 12, 21);
      expect(winter.sunrise, inInclusiveRange(8 * 60 + 43, 8 * 60 + 47));
      expect(winter.noonElevation, closeTo(7.4, 0.3));
    });
  });

  group('terrace west of the house', () {
    final horizon = horizonFor('Terrace west of the house');

    test('the house blocks the morning sun', () {
      expect(horizonAt(horizon, 90), closeTo(48.5, 1.5));
      expect(horizonAt(horizon, 225), closeTo(10.5, 1.5));
    });

    test('June sun matches the reference model', () {
      final june = profile(horizon, 6, 15);
      expect(june.windows, hasLength(1));
      expect(
        june.windows.first.start,
        inInclusiveRange(9 * 60 + 24, 9 * 60 + 34),
      );
      expect(
        june.windows.first.end,
        inInclusiveRange(20 * 60 + 44, 20 * 60 + 54),
      );
    });
  });

  group('middle of the lawn', () {
    final horizon = horizonFor('Middle of the lawn');

    test('June sun matches the reference model', () {
      final june = profile(horizon, 6, 15);
      expect(june.litMinutes, closeTo(13 * 60 + 14, 15));
    });
  });

  group('north end of the lawn', () {
    final horizon = horizonFor('North end of the lawn');

    test('has some sun in December', () {
      expect(profile(horizon, 12, 15).litMinutes, closeTo(2 * 60 + 4, 15));
    });
  });
}
