import 'dart:math' as math;

const _toDegrees = 180 / math.pi;
const _toRadians = math.pi / 180;

class SunPosition {
  const SunPosition({required this.elevation, required this.azimuth});

  final double elevation;
  final double azimuth;
}

SunPosition sunPositionAt(
  DateTime time, {
  required double latitude,
  required double longitude,
}) {
  final utc = time.toUtc();
  final julianDay = utc.millisecondsSinceEpoch / 86400000.0 + 2440587.5;
  final t = (julianDay - 2451545.0) / 36525.0;
  final meanLongitude = (280.46646 + t * (36000.76983 + t * 0.0003032)) % 360;
  final meanAnomaly =
      (357.52911 + t * (35999.05029 - 0.0001537 * t)) * _toRadians;
  final eccentricity = 0.016708634 - t * (0.000042037 + 0.0000001267 * t);
  final center =
      math.sin(meanAnomaly) * (1.914602 - t * (0.004817 + 0.000014 * t)) +
      math.sin(2 * meanAnomaly) * (0.019993 - 0.000101 * t) +
      math.sin(3 * meanAnomaly) * 0.000289;
  final omega = (125.04 - 1934.136 * t) * _toRadians;
  final apparentLongitude =
      (meanLongitude + center - 0.00569 - 0.00478 * math.sin(omega)) *
      _toRadians;
  final meanObliquity =
      23 +
      (26 + (21.448 - t * (46.815 + t * (0.00059 - t * 0.001813))) / 60) / 60;
  final obliquity = (meanObliquity + 0.00256 * math.cos(omega)) * _toRadians;
  final declination = math.asin(
    math.sin(obliquity) * math.sin(apparentLongitude),
  );
  final y = math.pow(math.tan(obliquity / 2), 2).toDouble();
  final l0 = meanLongitude * _toRadians;
  final equationOfTime =
      4 *
      _toDegrees *
      (y * math.sin(2 * l0) -
          2 * eccentricity * math.sin(meanAnomaly) +
          4 * eccentricity * y * math.sin(meanAnomaly) * math.cos(2 * l0) -
          0.5 * y * y * math.sin(4 * l0) -
          1.25 * eccentricity * eccentricity * math.sin(2 * meanAnomaly));
  final minutes =
      utc.hour * 60 + utc.minute + utc.second / 60 + utc.millisecond / 60000;
  final trueSolarTime = (minutes + equationOfTime + 4 * longitude) % 1440;
  final hourAngle = (trueSolarTime / 4 - 180) * _toRadians;
  final lat = latitude * _toRadians;
  final cosZenith =
      (math.sin(lat) * math.sin(declination) +
              math.cos(lat) * math.cos(declination) * math.cos(hourAngle))
          .clamp(-1.0, 1.0);
  final elevation = 90 - math.acos(cosZenith) * _toDegrees;
  final azimuth =
      (math.atan2(
                math.sin(hourAngle),
                math.cos(hourAngle) * math.sin(lat) -
                    math.tan(declination) * math.cos(lat),
              ) *
              _toDegrees +
          180) %
      360;
  return SunPosition(
    elevation: elevation + _refraction(elevation),
    azimuth: azimuth,
  );
}

double _refraction(double elevation) {
  final double arcSeconds;
  if (elevation > 85) {
    arcSeconds = 0;
  } else if (elevation > 5) {
    final te = math.tan(elevation * _toRadians);
    arcSeconds =
        58.1 / te - 0.07 / math.pow(te, 3) + 0.000086 / math.pow(te, 5);
  } else if (elevation > -0.575) {
    arcSeconds =
        1735 +
        elevation *
            (-518.2 +
                elevation * (103.4 + elevation * (-12.79 + elevation * 0.711)));
  } else {
    arcSeconds = -20.774 / math.tan(elevation * _toRadians);
  }
  return arcSeconds / 3600;
}
