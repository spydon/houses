import 'package:flutter/material.dart';

import '../site_model.dart';

class SpotPicker extends StatelessWidget {
  const SpotPicker({
    required this.spots,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<Spot> spots;
  final Spot selected;
  final ValueChanged<Spot> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final spot in spots)
          ChoiceChip(
            label: Text(spot.name),
            selected: !selected.isCustom && selected.name == spot.name,
            onSelected: (_) => onSelected(spot),
          ),
        if (selected.isCustom)
          ChoiceChip(
            label: const Text('Chosen spot'),
            selected: true,
            onSelected: (_) {},
          ),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Tap the image to check any other spot.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
