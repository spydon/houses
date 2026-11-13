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
  group('climbing net', () {
    final net = model.netSpot!;
    final elevation = model.observerElevation(net);
    final netHorizon = model.horizon(net.east, net.north, elevation: elevation);

    test('is measured 1 meter above the middle of the net', () {
      expect(model.spots.last, same(net));
      expect(elevation, closeTo(model.net!.middle.height + 1, 1e-9));
      expect(elevation, greaterThan(model.baseHeight(net.east, net.north)));
    });

    test('sees over the house and the trees better than the pool', () {
      expect(horizonAt(netHorizon, 180), lessThan(horizonAt(horizon, 180)));
      expect(horizonAt(netHorizon, 60), lessThan(horizonAt(horizon, 60)));
    });

    test('gets more sun than the pool in June', () {
      final june = DayProfile.compute(
        model: model,
        horizon: netHorizon,
        dayOfYear: dayOfYearFor(6, 15),
      );
      expect(june.litMinutes, greaterThan(profile(6, 15).litMinutes));
    });
  });
}
