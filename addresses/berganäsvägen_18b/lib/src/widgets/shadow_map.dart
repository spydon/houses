import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../address_info.dart';
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
                      const Image(
                        image: backyard,
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.medium,
                      ),
                      CustomPaint(
                        painter: _ShadowMapPainter(
                          model: model,
                          field: field,
                          shadow: shadow,
                          spot: spot,
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
    required this.sun,
    required this.isLit,
    required this.scale,
    required this.sunColor,
  });

  final SiteModel model;
  final ShadowField field;
  final ui.Image? shadow;
  final Spot spot;
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
      oldDelegate.sun.azimuth != sun.azimuth ||
      oldDelegate.sun.elevation != sun.elevation ||
      oldDelegate.isLit != isLit ||
      oldDelegate.scale != scale ||
      oldDelegate.sunColor != sunColor;
}
