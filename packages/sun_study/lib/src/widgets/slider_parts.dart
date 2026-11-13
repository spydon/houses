import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../sun_palette.dart';

const trackInset = 12.0;

class DaylightTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  const DaylightTrackShape(this.colors);

  final List<Color> colors;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final paint = Paint()
      ..shader = LinearGradient(colors: colors).createShader(rect);
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2)),
      paint,
    );
  }
}

class RingThumbShape extends SliderComponentShape {
  const RingThumbShape({required this.fill, required this.ring});

  final Color fill;
  final Color ring;
  static const _radius = 11.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_radius + 3);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final radius = _radius + activationAnimation.value * 2;
    canvas.drawCircle(
      center.translate(0, 1.5),
      radius + 3,
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(center, radius + 3, Paint()..color = ring);
    canvas.drawCircle(center, radius, Paint()..color = fill);
  }
}

class SunSliderTheme extends StatelessWidget {
  const SunSliderTheme({required this.colors, required this.child, super.key});

  final List<Color> colors;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = SunPalette.of(context);
    final scheme = Theme.of(context).colorScheme;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 10,
        trackShape: DaylightTrackShape(colors),
        thumbShape: RingThumbShape(
          fill: palette.sun,
          ring: scheme.surfaceContainerLowest,
        ),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
        overlayColor: palette.sun.withValues(alpha: 0.2),
        activeTrackColor: palette.sun,
        inactiveTrackColor: palette.night,
        tickMarkShape: SliderTickMarkShape.noTickMark,
        showValueIndicator: ShowValueIndicator.never,
        padding: const EdgeInsets.symmetric(horizontal: trackInset),
      ),
      child: child,
    );
  }
}

class SliderHeading extends StatelessWidget {
  const SliderHeading({
    required this.label,
    required this.value,
    this.detail,
    super.key,
  });

  final String label;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = this.detail;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
            style: theme.textTheme.titleMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        if (detail != null)
          Text(
            detail,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class Tick {
  const Tick(this.fraction, this.label);

  final double fraction;
  final String label;
}

class TickLabels extends StatelessWidget {
  const TickLabels({required this.ticks, required this.labelWidth, super.key});

  final List<Tick> ticks;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return SizedBox(
      height: 18,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final step = math.max(1, (ticks.length * labelWidth / width).ceil());
          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < ticks.length; i += step)
                Positioned(
                  left: (ticks[i].fraction * width - labelWidth / 2).clamp(
                    0.0,
                    math.max(0.0, width - labelWidth),
                  ),
                  width: labelWidth,
                  child: Text(
                    ticks[i].label,
                    textAlign: TextAlign.center,
                    style: style,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class SpotStrip extends StatelessWidget {
  const SpotStrip({required this.values, required this.label, super.key});

  final List<double> values;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = SunPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        SizedBox(
          height: 6,
          child: CustomPaint(
            painter: _StripPainter(
              values: values,
              color: palette.sun,
              background: theme.colorScheme.outlineVariant,
            ),
          ),
        ),
        Row(
          spacing: 6,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: palette.sun,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StripPainter extends CustomPainter {
  _StripPainter({
    required this.values,
    required this.color,
    required this.background,
  });

  final List<double> values;
  final Color color;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      Paint()..color = background,
    );
    if (values.isEmpty) {
      return;
    }
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(Offset.zero & size, radius));
    final width = size.width / values.length;
    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      if (value <= 0) {
        continue;
      }
      canvas.drawRect(
        Rect.fromLTWH(i * width, 0, width + 0.6, size.height),
        Paint()..color = color.withValues(alpha: 0.25 + 0.75 * value),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StripPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.color != color ||
      oldDelegate.background != background;
}
