import 'package:flutter/material.dart';

import 'address.dart';

class AddressCard extends StatefulWidget {
  const AddressCard({required this.address, super.key});

  final Address address;

  @override
  State<AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final address = widget.address;
    const onImage = Color(0xFFFFFFFF);
    return Semantics(
      button: true,
      label: 'Open the sun study for ${address.title}',
      child: Material(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surfaceContainer,
        child: InkWell(
          onTap: () => Navigator.of(context).pushNamed(address.path),
          onHover: (hovered) => setState(() => _hovered = hovered),
          child: AspectRatio(
            aspectRatio: 3 / 2,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedScale(
                  scale: _hovered ? 1.04 : 1,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  child: Image(image: address.cover, fit: BoxFit.cover),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.35, 1],
                      colors: [Color(0x00060A14), Color(0xE6060A14)],
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 22,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: [
                      Text(
                        address.area,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: onImage.withValues(alpha: 0.8),
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        address.title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: onImage,
                        ),
                      ),
                      Text(
                        address.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: onImage.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _OpenPill(hovered: _hovered),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OpenPill extends StatelessWidget {
  const _OpenPill({required this.hovered});

  final bool hovered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: hovered ? const Color(0xFFF4B740) : const Color(0xFFF2EBDD),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Text(
            'Open the sun study',
            style: theme.textTheme.labelLarge?.copyWith(
              color: const Color(0xFF1A1405),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Icon(Icons.arrow_forward, size: 18, color: Color(0xFF1A1405)),
        ],
      ),
    );
  }
}
