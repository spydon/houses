import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';

class Spot {
  const Spot({
    required this.name,
    required this.east,
    required this.north,
    this.elevation,
    this.note,
    this.isCustom = false,
  });

  factory Spot.fromJson(Map<String, dynamic> json) => Spot(
    name: json['name'] as String,
    east: (json['east'] as num).toDouble(),
    north: (json['north'] as num).toDouble(),
  );

  final String name;
  final double east;
  final double north;
  final double? elevation;
  final String? note;
  final bool isCustom;
}

class NetPoint {
  const NetPoint({
    required this.east,
    required this.north,
    required this.height,
  });

  factory NetPoint.fromJson(List<dynamic> json) => NetPoint(
    east: (json[0] as num).toDouble(),
    north: (json[1] as num).toDouble(),
    height: (json[2] as num).toDouble(),
  );

  final double east;
  final double north;
  final double height;
}

class ClimbingNet {
  ClimbingNet({
    required this.name,
    required this.roofAnchors,
    required this.poles,
  });

  factory ClimbingNet.fromJson(Map<String, dynamic> json) => ClimbingNet(
    name: json['name'] as String,
    roofAnchors: [
      for (final point in json['roofAnchors'] as List<dynamic>)
        NetPoint.fromJson(point as List<dynamic>),
    ],
    poles: [
      for (final point in json['poles'] as List<dynamic>)
        NetPoint.fromJson(point as List<dynamic>),
    ],
  );

  final String name;
  final List<NetPoint> roofAnchors;
  final List<NetPoint> poles;

  List<NetPoint> get corners => [
    roofAnchors[0],
    roofAnchors[1],
    poles[1],
    poles[0],
  ];

  NetPoint get middle {
    final points = corners;
    double mean(double Function(NetPoint) value) =>
        points.map(value).reduce((a, b) => a + b) / points.length;
    return NetPoint(
      east: mean((p) => p.east),
      north: mean((p) => p.north),
      height: mean((p) => p.height),
    );
  }
}

class HeightGrid {
  HeightGrid({
    required this.originEast,
    required this.originNorth,
    required this.width,
    required this.height,
    required this.values,
    required this.maximum,
  });

  factory HeightGrid.fromJson(Map<String, dynamic> json) {
    final bytes = base64Decode(json['decimeters'] as String);
    final raw = bytes.buffer.asByteData(
      bytes.offsetInBytes,
      bytes.lengthInBytes,
    );
    final count = bytes.lengthInBytes ~/ 2;
    final values = Float32List(count);
    var maximum = double.negativeInfinity;
    for (var i = 0; i < count; i++) {
      final value = raw.getInt16(i * 2, Endian.little) / 10;
      values[i] = value;
      if (value > maximum) {
        maximum = value;
      }
    }
    return HeightGrid(
      originEast: (json['originEast'] as num).toDouble(),
      originNorth: (json['originNorth'] as num).toDouble(),
      width: json['width'] as int,
      height: json['height'] as int,
      values: values,
      maximum: maximum,
    );
  }

  final double originEast;
  final double originNorth;
  final int width;
  final int height;
  final Float32List values;
  final double maximum;

  double? at(double east, double north) {
    final x = east - originEast;
    final y = originNorth - north;
    if (x < 0 || y < 0 || x >= width || y >= height) {
      return null;
    }
    return values[y.toInt() * width + x.toInt()];
  }
}

class ImageGeoreference {
  const ImageGeoreference({
    required this.width,
    required this.height,
    required this.a,
    required this.b,
    required this.eastOffset,
    required this.northOffset,
  });

  factory ImageGeoreference.fromJson(Map<String, dynamic> json) =>
      ImageGeoreference(
        width: (json['width'] as num).toDouble(),
        height: (json['height'] as num).toDouble(),
        a: (json['a'] as num).toDouble(),
        b: (json['b'] as num).toDouble(),
        eastOffset: (json['eastOffset'] as num).toDouble(),
        northOffset: (json['northOffset'] as num).toDouble(),
      );

  final double width;
  final double height;
  final double a;
  final double b;
  final double eastOffset;
  final double northOffset;

  Size get size => Size(width, height);

  double get metersPerPixel => math.sqrt(a * a + b * b);

  ({double east, double north}) toGround(Offset pixel) => (
    east: a * pixel.dx + b * pixel.dy + eastOffset,
    north: b * pixel.dx - a * pixel.dy + northOffset,
  );

  Offset toImage(double east, double north) {
    final de = east - eastOffset;
    final dn = north - northOffset;
    final d = a * a + b * b;
    return Offset((a * de + b * dn) / d, (b * de - a * dn) / d);
  }

  Offset directionOf(double gridRadians) {
    final p0 = toImage(0, 0);
    final p1 = toImage(math.sin(gridRadians), math.cos(gridRadians));
    final v = p1 - p0;
    return v / v.distance;
  }
}

class Building {
  Building({
    required this.name,
    required this.roof,
    required List<List<double>> points,
  }) : east = Float64List.fromList([for (final p in points) p[0]]),
       north = Float64List.fromList([for (final p in points) p[1]]);

  factory Building.fromJson(Map<String, dynamic> json) => Building(
    name: json['name'] as String,
    roof: (json['roof'] as num).toDouble(),
    points: [
      for (final point in json['points'] as List<dynamic>)
        [for (final value in point as List<dynamic>) (value as num).toDouble()],
    ],
  );

  final String name;
  final double roof;
  final Float64List east;
  final Float64List north;

  bool contains(double x, double y) {
    var inside = false;
    final count = east.length;
    for (var i = 0, j = count - 1; i < count; j = i++) {
      if ((north[i] > y) != (north[j] > y) &&
          x <
              (east[j] - east[i]) * (y - north[i]) / (north[j] - north[i]) +
                  east[i]) {
        inside = !inside;
      }
    }
    return inside;
  }

  double entryDistance(double x, double y, double dx, double dy) {
    var best = double.infinity;
    final count = east.length;
    for (var i = 0; i < count; i++) {
      final j = (i + 1) % count;
      final ex = east[j] - east[i];
      final ey = north[j] - north[i];
      final denominator = dx * ey - dy * ex;
      if (denominator.abs() < 1e-12) {
        continue;
      }
      final wx = east[i] - x;
      final wy = north[i] - y;
      final t = (wx * ey - wy * ex) / denominator;
      final s = (wx * dy - wy * dx) / denominator;
      if (t > 0 && s >= 0 && s <= 1 && t < best) {
        best = t;
      }
    }
    return best;
  }
}

class SiteModel {
  SiteModel({
    required this.latitude,
    required this.longitude,
    required this.gridBearingOfTrueNorth,
    required this.surface,
    required this.ground,
    required this.image,
    required this.buildings,
    required List<Spot> spots,
    this.net,
  }) : netSpot = net == null ? null : _netSpot(net, ground) {
    final netSpot = this.netSpot;
    this.spots = [...spots, ?netSpot];
  }

  factory SiteModel.fromJson(Map<String, dynamic> json) {
    final net = json['net'] as Map<String, dynamic>?;
    return SiteModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      gridBearingOfTrueNorth: (json['gridBearingOfTrueNorth'] as num)
          .toDouble(),
      surface: HeightGrid.fromJson(json['surface'] as Map<String, dynamic>),
      ground: HeightGrid.fromJson(json['ground'] as Map<String, dynamic>),
      image: ImageGeoreference.fromJson(json['image'] as Map<String, dynamic>),
      buildings: [
        for (final building in json['buildings'] as List<dynamic>)
          Building.fromJson(building as Map<String, dynamic>),
      ],
      spots: [
        for (final spot in json['spots'] as List<dynamic>)
          Spot.fromJson(spot as Map<String, dynamic>),
      ],
      net: net == null ? null : ClimbingNet.fromJson(net),
    );
  }

  static Spot _netSpot(ClimbingNet net, HeightGrid ground) {
    final middle = net.middle;
    final below = ground.at(middle.east, middle.north) ?? middle.height;
    final clearance = (middle.height - below).toStringAsFixed(1);
    return Spot(
      name: net.name,
      east: middle.east,
      north: middle.north,
      elevation: middle.height + observerHeightAboveGround,
      note:
          'Seen from 1 meter above the middle of the net, which hangs '
          '$clearance meters above the ground by the pool.',
    );
  }

  static const assetKey =
      'packages/abrahamsbergsvagen_18/assets/surface_model.json';
  static const observerHeightAboveGround = 1.0;
  static const smoothDistance = 40.0;

  static Future<SiteModel> load() async {
    final text = await rootBundle.loadString(assetKey);
    return SiteModel.fromJson(jsonDecode(text) as Map<String, dynamic>);
  }

  static final Float64List rayDistances = _rayDistances();

  static Float64List _rayDistances() {
    final distances = <double>[];
    var d = 0.75;
    while (d < 400) {
      distances.add(d);
      d += d < 30 ? 0.5 : (d < 100 ? 1.0 : 2.0);
    }
    return Float64List.fromList(distances);
  }

  final double latitude;
  final double longitude;
  final double gridBearingOfTrueNorth;
  final HeightGrid surface;
  final HeightGrid ground;
  final ImageGeoreference image;
  final List<Building> buildings;
  late final List<Spot> spots;
  final ClimbingNet? net;
  final Spot? netSpot;

  double gridRadians(double azimuth) =>
      (azimuth + gridBearingOfTrueNorth) * math.pi / 180;

  double baseHeight(double east, double north) {
    final top = surface.at(east, north) ?? 0;
    final bottom = ground.at(east, north) ?? top;
    var base = math.max(bottom + observerHeightAboveGround, top + 0.1);
    for (final building in buildings) {
      if (building.contains(east, north)) {
        base = math.max(base, building.roof + 0.1);
      }
    }
    return base;
  }

  double observerElevation(Spot spot) =>
      spot.elevation ?? baseHeight(spot.east, spot.north);

  bool isLit(
    double east,
    double north,
    double base,
    double sinAzimuth,
    double cosAzimuth,
    double tanElevation,
  ) {
    for (final building in buildings) {
      if (building.roof <= base) {
        continue;
      }
      final t = building.entryDistance(east, north, sinAzimuth, cosAzimuth);
      if (t.isFinite && base + t * tanElevation < building.roof) {
        return false;
      }
    }
    final values = surface.values;
    final width = surface.width;
    final height = surface.height;
    final top = surface.maximum;
    final x0 = east - surface.originEast;
    final y0 = surface.originNorth - north;
    final distances = rayDistances;
    for (var i = 0; i < distances.length; i++) {
      final d = distances[i];
      final rayHeight = base + d * tanElevation;
      if (rayHeight > top) {
        return true;
      }
      final x = x0 + d * sinAzimuth;
      final y = y0 - d * cosAzimuth;
      if (x < 1 || y < 1 || x >= width - 1 || y >= height - 1) {
        return true;
      }
      final double z;
      if (d < smoothDistance) {
        final fx = x - 0.5;
        final fy = y - 0.5;
        final ix = fx.floor();
        final iy = fy.floor();
        final tx = fx - ix;
        final ty = fy - iy;
        final k = iy * width + ix;
        z =
            (values[k] * (1 - tx) + values[k + 1] * tx) * (1 - ty) +
            (values[k + width] * (1 - tx) + values[k + width + 1] * tx) * ty;
      } else {
        z = values[y.toInt() * width + x.toInt()];
      }
      if (z > rayHeight) {
        return false;
      }
    }
    return true;
  }

  Float32List horizon(
    double east,
    double north, {
    double? elevation,
    int bins = 720,
  }) {
    final base = elevation ?? baseHeight(east, north);
    final values = surface.values;
    final width = surface.width;
    final height = surface.height;
    final x0 = east - surface.originEast;
    final y0 = surface.originNorth - north;
    final distances = rayDistances;
    final result = Float32List(bins);
    for (var bin = 0; bin < bins; bin++) {
      final angle = gridRadians(bin * 360 / bins);
      final sinA = math.sin(angle);
      final cosA = math.cos(angle);
      var best = double.negativeInfinity;
      for (var i = 0; i < distances.length; i++) {
        final d = distances[i];
        final x = x0 + d * sinA;
        final y = y0 - d * cosA;
        if (x < 0 || y < 0 || x >= width || y >= height) {
          break;
        }
        final slope = (values[y.toInt() * width + x.toInt()] - base) / d;
        if (slope > best) {
          best = slope;
        }
      }
      for (final building in buildings) {
        if (building.roof <= base) {
          continue;
        }
        final t = building.entryDistance(east, north, sinA, cosA);
        if (t.isFinite && (building.roof - base) / t > best) {
          best = (building.roof - base) / t;
        }
      }
      result[bin] = math.atan(best) * 180 / math.pi;
    }
    return result;
  }
}

double horizonAt(Float32List horizon, double azimuth) {
  final position = (azimuth % 360) / 360 * horizon.length;
  final i0 = position.floor() % horizon.length;
  final i1 = (i0 + 1) % horizon.length;
  final f = position - position.floor();
  return horizon[i0] * (1 - f) + horizon[i1] * f;
}
