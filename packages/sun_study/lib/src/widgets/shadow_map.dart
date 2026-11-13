import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../shadow_field.dart';
import '../site_model.dart';
import '../solar.dart';
import '../stockholm_clock.dart';
import '../sun_palette.dart';

const _compassNames = [
  'north',
  'northeast',
  'east',
  'southeast',
  'south',
  'southwest',
  'west',
  'northwest',
];

String compassName(double azimuth) =>
    _compassNames[((azimuth % 360) / 45).round() % 8];

class ShadowMap extends StatelessWidget {
  const ShadowMap({
    required this.model,
    required this.photo,
    required this.field,
    required this.shadow,
    required this.spot,
    required this.sun,
    required this.isLit,
    required this.dayOfYear,
    required this.minute,
    required this.onSpotSelected,
    super.key,
  });

  final SiteModel model;
  final ImageProvider photo;
  final ShadowField field;
  final ui.Image? shadow;
  final Spot spot;
  final SunPosition sun;
  final bool isLit;
  final int dayOfYear;
  final int minute;
  final ValueChanged<Spot> onSpotSelected;

  @override
  Widget build(BuildContext context) {
    final palette = SunPalette.of(context);
    final sunText = sun.elevation > 0
        ? 'Sun ${sun.elevation.round()}° up in the ${compassName(sun.azimuth)}'
        : 'Sun below the horizon';
    return Semantics(
      label:
          'Aerial photo of the backyard with shade for ${formatDate(dayOfYear)} '
          'at ${formatClock(minute)}. Tap to choose a spot.',
      child: AspectRatio(
        aspectRatio: model.image.width / model.image.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final scale = constraints.maxWidth / model.image.width;
              return GestureDetector(
                onTapUp: (details) {
                  final ground = model.image.toGround(
                    details.localPosition / scale,
                  );
                  onSpotSelected(
                    Spot(
                      name: 'Chosen spot',
                      east: ground.east,
                      north: ground.north,
                      isCustom: true,
                    ),
                  );
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.precise,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: photo,
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.medium,
                      ),
                      CustomPaint(
                        painter: _ShadowMapPainter(
                          model: model,
                          field: field,
                          shadow: shadow,
                          spot: spot,
                          net: spot == model.netSpot ? model.net : null,
                          sun: sun,
                          isLit: isLit,
                          scale: scale,
                          sunColor: palette.sun,
                        ),
                      ),
                      Positioned(
                        left: 12,
                        top: 12,
                        child: _MapBadge(
                          title:
                              '${formatDate(dayOfYear)}, ${formatClock(minute)}',
                          detail: sunText,
                        ),
                      ),
                      const Positioned(
                        right: 10,
                        bottom: 8,
                        child: _Attribution(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MapBadge extends StatelessWidget {
  const _MapBadge({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              detail,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Attribution extends StatelessWidget {
  const _Attribution();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x99000000),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          '© Lantmäteriet',
          style: TextStyle(fontSize: 11, color: Color(0xFFFFFFFF)),
        ),
      ),
    );
  }
}

class _ShadowMapPainter extends CustomPainter {
  _ShadowMapPainter({
    required this.model,
    required this.field,
    required this.shadow,
    required this.spot,
    required this.net,
    required this.sun,
    required this.isLit,
    required this.scale,
    required this.sunColor,
  });

  static const _meshMeters = 0.9;

  final SiteModel model;
  final ShadowField field;
  final ui.Image? shadow;
  final Spot spot;
  final ClimbingNet? net;
  final SunPosition sun;
  final bool isLit;
  final double scale;
  final Color sunColor;

  @override
  void paint(Canvas canvas, Size size) {
    final shadow = this.shadow;
    if (shadow != null) {
      final rect = field.imageRect;
      canvas.drawImageRect(
        shadow,
        Rect.fromLTWH(0, 0, shadow.width.toDouble(), shadow.height.toDouble()),
        Rect.fromLTWH(0, 0, rect.width * scale, rect.height * scale),
        Paint()
          ..filterQuality = FilterQuality.medium
          ..imageFilter = ui.ImageFilter.blur(
            sigmaX: 1.6 * scale,
            sigmaY: 1.6 * scale,
            tileMode: TileMode.clamp,
          ),
      );
    }
    final white = Paint()..color = const Color(0xFFFFFFFF);
    final outline = Paint()
      ..color = const Color(0xCC0B1222)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final preset in model.spots) {
      final p = model.image.toImage(preset.east, preset.north) * scale;
      canvas.drawCircle(p, 4.5, white);
      canvas.drawCircle(p, 4.5, outline);
    }
    if (net case final net?) {
      _drawNet(canvas, net);
    }
    final center = model.image.toImage(spot.east, spot.north) * scale;
    final reach = math.min(size.shortestSide * 0.2, 90.0);
    if (sun.elevation > 0) {
      final direction = model.image.directionOf(model.gridRadians(sun.azimuth));
      final target = center + direction * reach;
      final rayPaint = Paint()
        ..color = isLit ? sunColor : const Color(0xCCFFFFFF)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      _dashedLine(
        canvas,
        center + direction * 12,
        target - direction * 12,
        rayPaint,
        solid: isLit,
      );
      final glyph = Paint()..color = sunColor;
      for (var i = 0; i < 8; i++) {
        final angle = i * math.pi / 4;
        final v = Offset(math.cos(angle), math.sin(angle));
        canvas.drawLine(
          target + v * 10,
          target + v * 14,
          Paint()
            ..color = sunColor
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round,
        );
      }
      canvas.drawCircle(target, 7.5, glyph);
      canvas.drawCircle(
        target,
        7.5,
        Paint()
          ..color = const Color(0xFFFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
    canvas.drawCircle(
      center,
      11,
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      center,
      11,
      Paint()
        ..color = const Color(0x660B1222)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawCircle(
      center,
      6,
      Paint()..color = isLit ? sunColor : const Color(0xFF5B6478),
    );
    _northArrow(canvas, size);
  }

  void _drawNet(Canvas canvas, ClimbingNet net) {
    final corners = [
      for (final corner in net.corners)
        model.image.toImage(corner.east, corner.north) * scale,
    ];
    final roofStart = corners[0];
    final roofEnd = corners[1];
    final poleEnd = corners[2];
    final poleStart = corners[3];
    Offset at(double across, double along) => Offset.lerp(
      Offset.lerp(roofStart, roofEnd, across),
      Offset.lerp(poleStart, poleEnd, across),
      along,
    )!;

    final outline = Path()..addPolygon(corners, true);
    canvas.drawPath(outline, Paint()..color = const Color(0x40FFF6E0));

    final first = net.roofAnchors[0];
    final second = net.roofAnchors[1];
    final width = math.sqrt(
      math.pow(second.east - first.east, 2) +
          math.pow(second.north - first.north, 2),
    );
    final length = math.sqrt(
      math.pow(net.poles[0].east - first.east, 2) +
          math.pow(net.poles[0].north - first.north, 2),
    );
    final acrossCount = math.max(2, (width / _meshMeters).round());
    final alongCount = math.max(2, (length / _meshMeters).round());
    final shadowPaint = Paint()
      ..color = const Color(0x8C0B1222)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final rope = Paint()
      ..color = const Color(0xFFFFF1D6)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;
    final mesh = Path();
    for (var i = 1; i < acrossCount; i++) {
      final across = i / acrossCount;
      mesh
        ..moveTo(at(across, 0).dx, at(across, 0).dy)
        ..lineTo(at(across, 1).dx, at(across, 1).dy);
    }
    for (var j = 1; j < alongCount; j++) {
      final along = j / alongCount;
      mesh
        ..moveTo(at(0, along).dx, at(0, along).dy)
        ..lineTo(at(1, along).dx, at(1, along).dy);
    }
    canvas
      ..drawPath(mesh, shadowPaint)
      ..drawPath(mesh, rope);

    final border = Paint()
      ..color = const Color(0xFFFFF1D6)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas
      ..drawPath(
        outline,
        Paint()
          ..color = const Color(0xB30B1222)
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round,
      )
      ..drawPath(outline, border);

    final bar = Paint()
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(
        roofStart,
        roofEnd,
        Paint()
          ..color = const Color(0xB30B1222)
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round,
      )
      ..drawLine(roofStart, roofEnd, bar..color = const Color(0xFFFFF1D6));

    for (final pole in [poleStart, poleEnd]) {
      canvas
        ..drawCircle(pole, 5.5, Paint()..color = const Color(0xFF3B2A1C))
        ..drawCircle(
          pole,
          5.5,
          Paint()
            ..color = const Color(0xFFFFFFFF)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
    }
  }

  void _dashedLine(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint paint, {
    required bool solid,
  }) {
    if (solid) {
      canvas.drawLine(from, to, paint);
      return;
    }
    final delta = to - from;
    final length = delta.distance;
    if (length <= 0) {
      return;
    }
    final unit = delta / length;
    for (var d = 0.0; d < length; d += 9) {
      canvas.drawLine(
        from + unit * d,
        from + unit * math.min(d + 5, length),
        paint,
      );
    }
  }

  void _northArrow(Canvas canvas, Size size) {
    final center = Offset(size.width - 26, 26);
    canvas.drawCircle(center, 17, Paint()..color = const Color(0xD9FFFFFF));
    final up = model.image.directionOf(model.gridRadians(0));
    final side = Offset(-up.dy, up.dx);
    final path = Path()
      ..moveTo(center.dx + up.dx * 11, center.dy + up.dy * 11)
      ..lineTo(
        center.dx - up.dx * 7 + side.dx * 6,
        center.dy - up.dy * 7 + side.dy * 6,
      )
      ..lineTo(center.dx - up.dx * 3, center.dy - up.dy * 3)
      ..lineTo(
        center.dx - up.dx * 7 - side.dx * 6,
        center.dy - up.dy * 7 - side.dy * 6,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF17213D));
  }

  @override
  bool shouldRepaint(_ShadowMapPainter oldDelegate) =>
      oldDelegate.shadow != shadow ||
      oldDelegate.spot != spot ||
      oldDelegate.net != net ||
      oldDelegate.sun.azimuth != sun.azimuth ||
      oldDelegate.sun.elevation != sun.elevation ||
      oldDelegate.isLit != isLit ||
      oldDelegate.scale != scale ||
      oldDelegate.sunColor != sunColor;
}
