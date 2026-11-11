import 'package:flutter/material.dart';

import '../sun_palette.dart';

class MethodNotes extends StatelessWidget {
  const MethodNotes({super.key});

  static const _notes = [
    'The sun position uses the solar position algorithm from the US National '
        'Oceanic and Atmospheric Administration for 59.236° north, 18.041° east, '
        'in Swedish time with summer time.',
    'Ground heights come from the Lantmäteriet 1 meter elevation model.',
    'Tree heights come from the Swedish Forest Agency tree height map, measured '
        'by airborne laser scanning on 26 March 2020. Every tree is raised by '
        '1.5 meters for six seasons of growth, and the trees that were cut for '
        'the house, the pool and the neighbor\'s house are removed.',
    'Buildings are simple blocks: the house is 7.5 meters tall, the neighboring '
        'houses 6.5 to 7.5 meters and the roofed patio south of the pool 2.8 meters.',
    'The aerial photo is the Lantmäteriet orthophoto from 2025, brightened so '
        'the shade is easier to read.',
    'A spot counts as sunny when the sun is visible from 1 meter above the '
        'ground, about the eye height of someone sitting down.',
    'Tree crowns are treated as solid. Leafless deciduous trees let some light '
        'through from October to May, so those months can be a little brighter '
        'than shown.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = SunPalette.of(context);
    final body = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      height: 1.5,
    );
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Text('How this is calculated', style: theme.textTheme.titleLarge),
            for (final note in _notes)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: palette.sun,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(child: Text(note, style: body)),
                ],
              ),
            const SizedBox(height: 4),
            Text(
              'Aerial photo and elevation data © Lantmäteriet. '
              'Tree heights © Skogsstyrelsen.',
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
