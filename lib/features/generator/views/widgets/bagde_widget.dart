import 'package:flutter/material.dart';
import 'package:portefolio/core/ui/widgets/ui_widgets_extentions.dart';

/// Widget badge générique et réutilisable
/// Remplace _buildResultBadge et _buildEconomicBadge
class BadgeWidget extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color color;
  final String? label;
  final EdgeInsets? padding;

  const BadgeWidget({
    super.key,
    required this.text,
    this.icon,
    this.color = Colors.blue,
    this.label,
    this.padding,
  });

  /// Badge pour les résultats (avec check)
  factory BadgeWidget.result(String text) {
    return BadgeWidget(
      text: text,
      icon: Icons.check,
      color: Colors.green,
    );
  }

  /// Badge pour l'économique (avec label)
  factory BadgeWidget.economic({
    required String label,
    required String value,
  }) {
    return BadgeWidget(
      text: value,
      label: label,
      color: Colors.blue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          if (label != null) ...[
            ResponsiveText.bodySmall(
              label!,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            const SizedBox(width: 6),
          ],
          ResponsiveText.bodySmall(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: label != null ? FontWeight.bold : FontWeight.normal,
              fontSize: label != null ? 13 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Liste horizontale de badges avec scroll
class BadgeList extends StatelessWidget {
  final List<Widget> badges;
  final double height;

  const BadgeList({
    super.key,
    required this.badges,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) return const SizedBox.shrink();

    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: badges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) => badges[index],
      ),
    );
  }
}
