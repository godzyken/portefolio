import 'package:flutter/material.dart';

import '../../../../../core/affichage/screen_size_detector.dart';
import '../../../../../core/ui/widgets/responsive_text.dart';
import '../../../../experience/data/experiences_data.dart';
import '../../generator_widgets_extentions.dart';

/// Card d'information pour les expériences
class ExperienceInfoCard extends StatelessWidget {
  final Experience experience;
  final ResponsiveInfo info;
  final ThemeData theme;

  const ExperienceInfoCard({
    super.key,
    required this.experience,
    required this.info,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(info.isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (experience.poste.isNotEmpty) ...[
            Row(
              children: [
                ExperienceIcon3D(
                  icon: Icons.work_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                  padding: 4,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ResponsiveText.titleLarge(
                    experience.poste,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          if (experience.periode.isNotEmpty) ...[
            Row(
              children: [
                ExperienceIcon3D(
                  icon: Icons.calendar_today,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                  size: 26,
                  padding: 4,
                ),
                const SizedBox(width: 16),
                ResponsiveText.bodyLarge(
                  experience.periode,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          if (experience.contexte.isNotEmpty) ...[
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            ResponsiveText.bodyMedium(
              experience.contexte,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
