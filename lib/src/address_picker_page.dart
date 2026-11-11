import 'package:flutter/material.dart';

import 'address.dart';
import 'address_card.dart';

class AddressPickerPage extends StatelessWidget {
  const AddressPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gutter = constraints.maxWidth >= 600 ? 40.0 : 16.0;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: gutter, vertical: 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      Text('Houses', style: theme.textTheme.displayLarge),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Text(
                          'Pick an address to see when the sun reaches the '
                          'garden, hour by hour, through the whole year.',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          for (final address in addresses)
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 680),
                              child: AddressCard(address: address),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
