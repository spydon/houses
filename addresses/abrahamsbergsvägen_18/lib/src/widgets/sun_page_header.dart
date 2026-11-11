import 'package:flutter/material.dart';

import '../address_info.dart';

class SunPageHeader extends StatelessWidget {
  const SunPageHeader({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        TextButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('All houses'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            foregroundColor: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(title, style: theme.textTheme.displaySmall),
        Text(
          'When the sun reaches the backyard in $area',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
