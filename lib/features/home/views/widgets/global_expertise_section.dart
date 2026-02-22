import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/affichage/colors_spec.dart';
import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/provider/expertise_provider.dart';
import '../../../../core/ui/ui_widgets_extentions.dart';
import '../../../generator/data/extention_models.dart';

/// Section affichant un résumé global des expertises
class GlobalExpertiseSection extends ConsumerWidget {
  const GlobalExpertiseSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = ref.watch(globalExpertiseStatsProvider);
    final info = ref.watch(responsiveInfoProvider);

    return ResponsiveBox(
      padding: EdgeInsets.all(info.isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top 10 compétences avec graphique
          if (stats.topSkills.isNotEmpty) ...[
            _buildTopSkillsSection(context, stats, info),
          ],
        ],
      ),
    );
  }

  Widget _buildTopSkillsSection(
    BuildContext context,
    GlobalExpertiseStats stats,
    ResponsiveInfo info,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText.titleLarge(
          'Top 10 compétences',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const ResponsiveBox(paddingSize: ResponsiveSpacing.xl, height: 24),
        if (info.isMobile || info.isPortrait)
          _buildSkillsList(stats.topSkills, theme)
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Graphique à gauche
              Expanded(
                flex: 2,
                child: _buildPieChart(stats.topSkills.take(5).toList(), theme),
              ),
              const ResponsiveBox(paddingSize: ResponsiveSpacing.m, width: 40),
              // Liste à droite
              Expanded(
                flex: 3,
                child: _buildSkillsList(stats.topSkills, theme),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPieChart(List<TechSkill> skills, ThemeData theme) {
    return ResponsiveBox(
      paddingSize: ResponsiveSpacing.xxl,
      child: PieChart(
        PieChartData(
          sections: skills.map((skill) {
            final index = skills.indexOf(skill);
            final colors = [
              Colors.blue,
              Colors.green,
              Colors.orange,
              Colors.purple,
              Colors.red,
            ];

            return PieChartSectionData(
              value: skill.level * 100,
              title: '${skill.levelPercent}%',
              color: colors[index % colors.length],
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildSkillsList(List<TechSkill> skills, ThemeData theme) {
    return Column(
      children: skills.map((skill) {
        final color = ColorHelpers.getExpertiseColor(skill.level);

        return ResponsiveBox(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        ResponsiveBox(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const ResponsiveBox(width: 12),
                        Expanded(
                          child: ResponsiveText.bodyMedium(
                            skill.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ResponsiveText.bodySmall(
                    '${skill.levelPercent}%',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const ResponsiveBox(paddingSize: ResponsiveSpacing.s, height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: skill.level,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const ResponsiveBox(paddingSize: ResponsiveSpacing.xs, height: 4),
              ResponsiveText.bodySmall(
                '${skill.projectCount} projets • ${skill.yearsOfExperience} ans',
                style: TextStyle(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
