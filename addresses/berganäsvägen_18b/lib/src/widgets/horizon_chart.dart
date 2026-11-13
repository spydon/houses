import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../day_profile.dart';
import '../sun_palette.dart';

class HorizonChart extends StatelessWidget {
  const HorizonChart({
    required this.horizon,
    required this.profile,
    required this.minute,
    required this.spotName,
    super.key,
  });

  final Float32List horizon;
  final DayProfile profile;
  final int minute;
  final String spotName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = SunPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Text(
          'Sky seen from the ${spotName.toLowerCase()}',
          style: theme.textTheme.titleLarge,
        ),
        Text(
          'The gray area is everything that blocks the sky: trees, rock and '
          'buildings. The line is the path of the sun on the chosen day, bright '
          'where it reaches the spot.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 250,
          child: CustomPaint(
            painter: _HorizonPainter(
              horizon: horizon,
              profile: profile,
              minute: minute,
              palette: palette,
              text: theme.colorScheme.onSurfaceVariant,
              surface: theme.colorScheme.surface,
              blocked: theme.colorScheme.onSurfaceVariant.withValues(
                alpha: 0.55,
              ),
              labelStyle: theme.textTheme.bodySmall!,
            ),
          ),
        ),
      ],
    );
  }
}

class _HorizonPainter extends CustomPainter {
  _HorizonPainter({
    required this.horizon,
    required this.profile,
    required this.minute,
    required this.palette,
    required this.text,
    required this.surface,
    required this.blocked,
    required this.labelStyle,
  });

  final Float32List horizon;
  final DayProfile profile;
  final int minute;
  final SunPalette palette;
  final Color text;
  final Color surface;
  final Color blocked;
  final TextStyle labelStyle;

  static const _maxElevation = 60.0;
  static const _left = 34.0;
  static const _bottom = 24.0;
  static const _top = 10.0;
  static const _right = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(
      _left,
      _top,
      size.width - _right,
      size.height - _bottom,
    );
    double x(double azimuth) => plot.left + azimuth / 360 * plot.width;
    double y(double elevation) =>
        plot.bottom -
        elevation.clamp(0, _maxElevation) / _maxElevation * plot.height;

    final gridPaint = Paint()
      ..color = palette.grid
      ..strokeWidth = 1;
    for (var e = 0.0; e <= _maxElevation; e += 15) {
      canvas.drawLine(
        Offset(plot.left, y(e)),
        Offset(plot.right, y(e)),
        gridPaint,
      );
      _label(
        canvas,
        '${e.round()}°',
        Offset(plot.left - 6, y(e)),
        Alignment.centerRight,
      );
    }
    const directions = ['North', 'East', 'South', 'West', 'North'];
    for (var i = 0; i <= 8; i++) {
      final azimuth = i * 45.0;
      canvas.drawLine(
        Offset(x(azimuth), plot.top),
        Offset(x(azimuth), plot.bottom),
        gridPaint,
      );
      if (i.isEven) {
        final alignment = i == 0
            ? Alignment.topLeft
            : (i == 8 ? Alignment.topRight : Alignment.topCenter);
        _label(
          canvas,
          directions[i ~/ 2],
          Offset(x(azimuth), plot.bottom + 6),
          alignment,
        );
      }
    }

    final skyline = Path()..moveTo(plot.left, plot.bottom);
    for (var i = 0; i <= horizon.length; i++) {
      final azimuth = i * 360 / horizon.length;
      skyline.lineTo(x(azimuth), y(horizon[i % horizon.length]));
    }
    skyline
      ..lineTo(plot.right, plot.bottom)
      ..close();
    canvas.drawPath(skyline, Paint()..color = palette.skyline);

    final litPaint = Paint()
      ..color = palette.sun
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final blockedPaint = Paint()
      ..color = blocked
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i < profile.length; i++) {
      final e0 = profile.elevations[i - 1];
      final e1 = profile.elevations[i];
      if (e0 <= 0 && e1 <= 0) {
        continue;
      }
      final a0 = profile.azimuths[i - 1];
      final a1 = profile.azimuths[i];
      if ((a1 - a0).abs() > 180) {
        continue;
      }
      canvas.drawLine(
        Offset(x(a0), y(e0)),
        Offset(x(a1), y(e1)),
        profile.lit[i] == 1 ? litPaint : blockedPaint,
      );
    }

    final dot = Paint()..color = text;
    for (var hour = 0; hour < 24; hour++) {
      final sun = profile.sunAt(hour * 60);
      if (sun.elevation <= 1) {
        continue;
      }
      final p = Offset(x(sun.azimuth), y(sun.elevation));
      canvas.drawCircle(p, 2.5, dot);
      if (hour % 3 == 0) {
        _label(
          canvas,
          hour.toString().padLeft(2, '0'),
          p.translate(0, -8),
          Alignment.bottomCenter,
        );
      }
    }

    final now = profile.sunAt(minute);
    if (now.elevation > 0) {
      final p = Offset(x(now.azimuth), y(now.elevation));
      final lit = profile.isLitAt(minute);
      canvas.drawCircle(p, 9, Paint()..color = surface);
      canvas.drawCircle(p, 7, Paint()..color = lit ? palette.sun : blocked);
      canvas.drawCircle(
        p,
        9,
        Paint()
          ..color = palette.sun
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _label(Canvas canvas, String value, Offset anchor, Alignment alignment) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: labelStyle.copyWith(color: text),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = anchor.dx - painter.width * (alignment.x + 1) / 2;
    final dy = anchor.dy - painter.height * (alignment.y + 1) / 2;
    painter.paint(canvas, Offset(dx, math.max(0, dy)));
    painter.dispose();
  }

  @override
  bool shouldRepaint(_HorizonPainter oldDelegate) =>
      oldDelegate.horizon != horizon ||
      oldDelegate.profile != profile ||
      oldDelegate.minute != minute ||
      oldDelegate.palette.sun != palette.sun ||
      oldDelegate.text != text;
}
