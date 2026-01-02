import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/affichage/screen_size_detector.dart';
import '../../../../../core/ui/widgets/ui_widgets_extentions.dart';
import '../../../../experience/data/experiences_data.dart';
import '../../generator_widgets_extentions.dart';

/// Section stack technique
class ExperienceStackSection extends ConsumerWidget {
  final Experience experience;
  final ThemeData theme;
  final ResponsiveInfo info;

  const ExperienceStackSection({
    super.key,
    required this.experience,
    required this.theme,
    required this.info,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (experience.stack.isEmpty) return const SizedBox.shrink();

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
                icon: Icons.code,
                color: theme.colorScheme.primary,
                size: info.isMobile ? 36 : 48,
                padding: 4,
              ),
              const SizedBox(width: 12),
              ResponsiveText.titleLarge(
                'Stack Technique',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: experience.stack.entries
                .expand((entry) => entry.value.map(
                      (tech) => ExperienceTechChip(
                        tech: tech,
                        primaryColor: theme.colorScheme.primary,
                        theme: theme,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
