import 'package:flutter/material.dart';

import '../../../../../core/ui/widgets/responsive_text.dart';
import '../../generator_widgets_extentions.dart';

/// Section générique pour objectifs/missions/résultats
class ExperienceListSection extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String title;
  final List<String> items;

  const ExperienceListSection({
    super.key,
    required this.theme,
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ExperienceIcon3D(
                icon: icon,
                color: theme.colorScheme.primary,
                size: 24,
                padding: 4,
              ),
              const SizedBox(width: 12),
              ResponsiveText.titleLarge(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveBox(
                      margin: const EdgeInsets.only(top: 6),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ResponsiveText.bodyMedium(
                        item,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
