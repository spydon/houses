import 'package:flutter/material.dart';

import '../sun_palette.dart';

class MethodNotes extends StatelessWidget {
  const MethodNotes({required this.notes, required this.credits, super.key});

  final List<String> notes;
  final String credits;

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
            for (final note in notes)
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
              credits,
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
