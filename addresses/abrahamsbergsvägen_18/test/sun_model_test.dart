import 'dart:convert';
import 'dart:io';

import 'package:abrahamsbergsvagen_18/src/day_profile.dart';
import 'package:abrahamsbergsvagen_18/src/site_model.dart';
import 'package:abrahamsbergsvagen_18/src/stockholm_clock.dart';
import 'package:flutter_test/flutter_test.dart';

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

    test('summer time is applied between March and October', () {
      expect(isSummerTime(DateTime.utc(2026, 3, 29, 0, 59)), isFalse);
      expect(isSummerTime(DateTime.utc(2026, 3, 29, 1)), isTrue);
      expect(isSummerTime(DateTime.utc(2026, 10, 25, 0, 59)), isTrue);
      expect(isSummerTime(DateTime.utc(2026, 10, 25, 1)), isFalse);
    });
  });

  group('building outlines', () {
    final square = Building(
      name: 'Square',
      roof: 10,
      points: [
        [0, 0],
        [4, 0],
        [4, 4],
        [0, 4],
      ],
    );

    test('a ray from outside enters at the nearest wall', () {
      expect(square.entryDistance(-3, 2, 1, 0), closeTo(3, 1e-9));
      expect(square.entryDistance(2, 7, 0, -1), closeTo(3, 1e-9));
    });

    test('a ray pointing away never enters', () {
      expect(square.entryDistance(-3, 2, -1, 0), double.infinity);
    });

    test('points inside are detected', () {
      expect(square.contains(2, 2), isTrue);
      expect(square.contains(5, 2), isFalse);
    });
  });

  group('pool', () {
    test('trees to the south block the sun from late morning', () {
      expect(horizonAt(horizon, 180), closeTo(56.6, 1.5));
      expect(horizonAt(horizon, 225), closeTo(61.1, 1.5));
    });

    test('June sun matches the reference model', () {
      final june = profile(6, 15);
      final windows = june.windows;
      expect(windows, isNotEmpty);
      expect(windows.first.start, inInclusiveRange(6 * 60 + 46, 6 * 60 + 56));
      expect(windows.first.end, inInclusiveRange(12 * 60 + 26, 12 * 60 + 36));
    });

    test('no direct sun in December', () {
      expect(profile(12, 15).litMinutes, 0);
    });
  });
}
