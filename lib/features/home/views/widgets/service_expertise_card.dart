import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

import '../../data/services_data.dart';

class ServiceExpertiseCard extends ConsumerWidget {
  final ServiceExpertise expertise;
  final bool compact;

  const ServiceExpertiseCard({
    super.key,
    required this.expertise,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ResponsiveBox(
        paddingSize: ResponsiveSpacing.l,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec statistiques globales
            _buildHeader(theme),

            const ResponsiveBox(paddingSize: ResponsiveSpacing.l),

            // Graphique radar des compétences principales
            if (!compact) ...[
              _buildRadarChart(theme),
              const ResponsiveBox(paddingSize: ResponsiveSpacing.l),
            ],

            // Liste des compétences avec barres de progression
            _buildSkillsList(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText.titleLarge(
              'Niveau d\'expertise',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const ResponsiveBox(paddingSize: ResponsiveSpacing.xs),
            ResponsiveText.bodyMedium(
              '${(expertise.averageLevel * 100).toStringAsFixed(0)}% en moyenne',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        _buildStatsChips(theme),
      ],
    );
  }

  Widget _buildStatsChips(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Chip(
          avatar: Icon(Icons.work, size: 16, color: theme.colorScheme.primary),
          label: ResponsiveText('${expertise.totalProjects} projets'),
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
        Chip(
          avatar: Icon(Icons.calendar_today,
              size: 16, color: theme.colorScheme.secondary),
          label: ResponsiveText.headlineSmall(
              '${expertise.totalYearsExperience} ans'),
          backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
        ),
      ],
    );
  }

  Widget _buildRadarChart(ThemeData theme) {
    final topSkills = expertise.topSkills;

    return ResponsiveBox(
      paddingSize: ResponsiveSpacing.m,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          radarBorderData: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 2,
          ),
          tickBorderData: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
          gridBorderData: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          tickCount: 5,
          ticksTextStyle: theme.textTheme.bodySmall!,
          radarBackgroundColor: theme.colorScheme.surface,
          dataSets: [
            RadarDataSet(
              fillColor: theme.colorScheme.primary.withValues(alpha: 0.3),
              borderColor: theme.colorScheme.primary,
              borderWidth: 2,
              entryRadius: 3,
              dataEntries: topSkills.map((skill) {
                return RadarEntry(value: skill.level * 100);
              }).toList(),
            ),
          ],
          getTitle: (index, angle) {
            if (index >= topSkills.length) {
              return const RadarChartTitle(text: '');
            }
            return RadarChartTitle(
              text: topSkills[index].name,
              angle: angle,
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkillsList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText.titleMedium(
          'Compétences techniques',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const ResponsiveBox(paddingSize: ResponsiveSpacing.l),
        ...expertise.skills.map((skill) => _buildSkillBar(skill, theme)),
      ],
    );
  }

  Widget _buildSkillBar(TechSkill skill, ThemeData theme) {
    final color = _getColorForLevel(skill.level, theme);

    return ResponsiveBox(
      paddingSize: ResponsiveSpacing.m,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ResponsiveText.bodyMedium(
                  skill.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
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
          const ResponsiveBox(paddingSize: ResponsiveSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: skill.level,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const ResponsiveBox(paddingSize: ResponsiveSpacing.xs),
          Row(
            children: [
              Icon(Icons.work_outline,
                  size: 12, color: theme.colorScheme.outline),
              const ResponsiveBox(paddingSize: ResponsiveSpacing.xs),
              ResponsiveText.bodySmall(
                '${skill.projectCount} projets',
                style: TextStyle(
                  color: theme.colorScheme.outline,
                ),
              ),
              const ResponsiveBox(paddingSize: ResponsiveSpacing.m, width: 12),
              Icon(Icons.calendar_today,
                  size: 12, color: theme.colorScheme.outline),
              const ResponsiveBox(paddingSize: ResponsiveSpacing.xs, width: 4),
              ResponsiveText.bodySmall(
                '${skill.yearsOfExperience} ans',
                style: TextStyle(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorForLevel(double level, ThemeData theme) {
    if (level >= 0.9) return Colors.green;
    if (level >= 0.7) return Colors.blue;
    if (level >= 0.5) return Colors.orange;
    return Colors.red;
  }
}

/// Widget compact pour afficher dans la carte de service
class CompactExpertiseIndicator extends StatelessWidget {
  final ServiceExpertise expertise;

  const CompactExpertiseIndicator({
    super.key,
    required this.expertise,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ResponsiveBox(
      paddingSize: ResponsiveSpacing.m,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const ResponsiveBox(paddingSize: ResponsiveSpacing.xs),
              ResponsiveText.bodySmall(
                'Expertise: ${(expertise.averageLevel * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const ResponsiveBox(paddingSize: ResponsiveSpacing.s),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: expertise.topSkills.take(3).map((skill) {
              return Chip(
                label: ResponsiveText.bodySmall(
                  skill.name,
                  style: theme.textTheme.bodySmall,
                ),
                backgroundColor: theme.colorScheme.primaryContainer,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
