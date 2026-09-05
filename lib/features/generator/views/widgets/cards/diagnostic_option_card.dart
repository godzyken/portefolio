import 'package:flutter/material.dart';

import '../../../../../core/ui/cards/base_card.dart';
import '../../../../../core/ui/widgets/responsive_text.dart';

class DiagnosticOptionCard extends StatelessWidget {
  const DiagnosticOptionCard({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return BaseCard(
      config: CardConfig(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        margin: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(14),
        backgroundColor: selected
            ? color.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.05),
        borderColor: selected ? color : Colors.white.withValues(alpha: 0.15),
        borderWidth: selected ? 2 : 1,
        enableHover: onTap != null,
      ),
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? color : Colors.white54,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: ResponsiveText.bodyMedium(
              label,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
