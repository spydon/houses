import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sun_study/sun_study.dart';

void main() {
  group('Swedish time', () {
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

  test('a study finds its assets in its own package', () {
    const study = SunStudy(
      title: 'Example 1',
      area: 'Somewhere',
      package: 'example_1',
      notes: [],
      credits: '',
    );
    expect(study.modelAssetKey, 'packages/example_1/assets/surface_model.json');
    expect(
      study.photo,
      const AssetImage('assets/backyard.jpg', package: 'example_1'),
    );
  });
}
