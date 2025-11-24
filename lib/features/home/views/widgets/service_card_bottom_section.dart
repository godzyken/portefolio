import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';

import '../../../../../core/affichage/screen_size_detector.dart';
import '../../../../../core/provider/expertise_provider.dart';
import '../../../../../core/ui/widgets/ui_widgets_extentions.dart';
import 'extentions_widgets.dart';

class ServiceCardBottomSection extends ConsumerWidget {
  final Service service;
  final int currentSkillIndex;

  const ServiceCardBottomSection({
    super.key,
    required this.service,
    required this.currentSkillIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final info = ref.watch(responsiveInfoProvider);
    final expertise = ref.watch(serviceExpertiseProvider(service.id));

    if (expertise == null) {
      return Card(
        color: theme.colorScheme.surface,
        margin: EdgeInsets.all(ServiceCardHelpers.getPadding(info)),
        child: Center(
          child: ResponsiveText.bodyMedium(
            'Aucune donnée disponible',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    return Container(
      color: theme.colorScheme.surface,
      margin: EdgeInsets.all(ServiceCardHelpers.getPadding(info)),
      child: Padding(
        padding: EdgeInsets.all(ServiceCardHelpers.getPadding(info)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: ResponsiveText.titleSmall(
                'Technologies',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ServiceCardHelpers.getFontSize(
                    info,
                    small: 12,
                    medium: 14,
                    large: 16,
                  ),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              height: ServiceCardHelpers.getSpacing(
                info,
                small: 8,
                medium: 12,
                large: 16,
              ),
            ),
            Expanded(
              flex: 5,
              child: Center(
                child: _buildChartSection(expertise, theme, info),
              ),
            ),
            SizedBox(
              height: ServiceCardHelpers.getSpacing(
                info,
                small: 8,
                medium: 10,
                large: 12,
              ),
            ),
            Expanded(
              flex: 1,
              child: _buildStats(expertise, theme, info),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 1000.ms, delay: 150.ms),
    );
  }

  Widget _buildChartSection(
    ServiceExpertise expertise,
    ThemeData theme,
    ResponsiveInfo info,
  ) {
    if (info.isWatch || info.isMobile) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: ServicePieChart(
                expertise: expertise,
                currentSkillIndex: currentSkillIndex,
              ),
            ),
          ),
          SizedBox(
            height: ServiceCardHelpers.getSpacing(
              info,
              small: 8,
              medium: 10,
              large: 12,
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 5,
          child: ServiceChartLegend(expertise: expertise)
              .animate()
              .fadeIn(delay: 1000.ms, duration: 800.ms)
              .slideX(begin: -0.2),
        ),
        SizedBox(
          width: ServiceCardHelpers.getSpacing(
            info,
            small: 8,
            medium: 12,
            large: 16,
          ),
        ),
        Flexible(
          flex: 5,
          child: AspectRatio(
            aspectRatio: 1.0,
            child: ServicePieChart(
              expertise: expertise,
              currentSkillIndex: currentSkillIndex,
            )
                .animate()
                .fadeIn(delay: 1000.ms, duration: 800.ms)
                .slideX(begin: 0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(
    ServiceExpertise expertise,
    ThemeData theme,
    ResponsiveInfo info,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ServiceCardWidgets.buildStatItem(
          icon: Icons.work_outline,
          label: '${expertise.totalProjects} projets',
          color: theme.colorScheme.primary,
          info: info,
        ),
        Container(
          width: 1,
          height: ServiceCardHelpers.getSpacing(
            info,
            small: 16,
            medium: 18,
            large: 20,
          ),
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        ServiceCardWidgets.buildStatItem(
          icon: Icons.calendar_today,
          label: '${expertise.totalYearsExperience} ans',
          color: theme.colorScheme.secondary,
          info: info,
        ),
        Container(
          width: 1,
          height: ServiceCardHelpers.getSpacing(
            info,
            small: 16,
            medium: 18,
            large: 20,
          ),
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        ServiceCardWidgets.buildStatItem(
          icon: Icons.star,
          label: '${(expertise.averageLevel * 100).toInt()}%',
          color: Colors.orange,
          info: info,
        ),
      ],
    );
  }
}
