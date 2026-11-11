import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'site_model.dart';
import 'solar.dart';

class ShadowField {
  ShadowField(this.model, {this.cellPixels = 3})
    : columns = (model.image.width / cellPixels).ceil(),
      rows = (model.image.height / cellPixels).ceil() {
    final count = columns * rows;
    _east = Float64List(count);
    _north = Float64List(count);
    _base = Float64List(count);
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final k = row * columns + column;
        final ground = model.image.toGround(
          ui.Offset((column + 0.5) * cellPixels, (row + 0.5) * cellPixels),
        );
        _east[k] = ground.east;
        _north[k] = ground.north;
        _base[k] = model.baseHeight(ground.east, ground.north);
      }
    }
  }

  final SiteModel model;
  final int cellPixels;
  final int columns;
  final int rows;
  late final Float64List _east;
  late final Float64List _north;
  late final Float64List _base;

  ui.Rect get imageRect => ui.Rect.fromLTWH(
    0,
    0,
    (columns * cellPixels).toDouble(),
    (rows * cellPixels).toDouble(),
  );

  Future<ui.Image> render({
    required SunPosition sun,
    required ui.Color litColor,
    required ui.Color shadeColor,
    required ui.Color nightColor,
  }) {
    final count = columns * rows;
    final pixels = Uint8List(count * 4);
    if (sun.elevation <= 0) {
      _fill(pixels, 0, count, nightColor);
    } else {
      final angle = model.gridRadians(sun.azimuth);
      final sinA = math.sin(angle);
      final cosA = math.cos(angle);
      final tanE = math.tan(sun.elevation * math.pi / 180);
      final lit = _premultiplied(litColor);
      final shade = _premultiplied(shadeColor);
      for (var k = 0; k < count; k++) {
        final color =
            model.isLit(_east[k], _north[k], _base[k], sinA, cosA, tanE)
            ? lit
            : shade;
        pixels.setRange(k * 4, k * 4 + 4, color);
      }
    }
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      columns,
      rows,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  void _fill(Uint8List pixels, int from, int to, ui.Color color) {
    final value = _premultiplied(color);
    for (var k = from; k < to; k++) {
      pixels.setRange(k * 4, k * 4 + 4, value);
    }
  }

  static Uint8List _premultiplied(ui.Color color) {
    final a = color.a;
    return Uint8List.fromList([
      (color.r * a * 255).round(),
      (color.g * a * 255).round(),
      (color.b * a * 255).round(),
      (a * 255).round(),
    ]);
  }
}
