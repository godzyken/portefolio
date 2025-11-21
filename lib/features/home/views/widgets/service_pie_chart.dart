import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';

import '../../../../../core/affichage/screen_size_detector.dart';
import '../../../../../core/ui/widgets/ui_widgets_extentions.dart';
import 'service_card_helpers.dart';

class ServicePieChart extends ConsumerWidget {
  final ServiceExpertise expertise;
  final int currentSkillIndex;

  const ServicePieChart({
    super.key,
    required this.expertise,
    required this.currentSkillIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final info = ref.watch(responsiveInfoProvider);
    final skills = expertise.topSkills.take(5).toList();
    final colors = ServiceCardHelpers.getChartColors();

    return Stack(
      alignment: Alignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 360),
          duration: 1500.ms,
          curve: Curves.easeInOut,
          builder: (context, rotation, child) {
            return PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: ServiceCardHelpers.getCenterRadius(info),
                startDegreeOffset: rotation,
                sections: skills.asMap().entries.map((entry) {
                  final index = entry.key;
                  final skill = entry.value;

                  return PieChartSectionData(
                    color: colors[index % colors.length],
                    value: skill.level * 100,
                    title: ServiceCardHelpers.shouldShowTitle(info)
                        ? '${skill.levelPercent}%'
                        : '',
                    radius: ServiceCardHelpers.getRadius(info),
                    titleStyle: TextStyle(
                      fontSize: ServiceCardHelpers.getFontSize(
                        info,
                        small: 8,
                        medium: 10,
                        large: 11,
                      ),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
        _buildCenterLegend(skills, theme, info),
      ],
    );
  }

  Widget _buildCenterLegend(
    List<TechSkill> skills,
    ThemeData theme,
    ResponsiveInfo info,
  ) {
    if (skills.isEmpty) return const SizedBox.shrink();

    final skill = skills[currentSkillIndex];
    final fontSize = ServiceCardHelpers.getFontSize(
      info,
      small: 9,
      medium: 10,
      large: 12,
    );
    final size = ServiceCardHelpers.getCenterRadius(info) * 2;

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ResponsiveText.bodySmall(
              'Top ${skills.length} Skills',
              style: TextStyle(
                fontSize: fontSize * 0.7,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: fontSize * 1.5,
              child: AnimatedSwitcher(
                duration: 900.ms,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final slideAnimation = Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(animation);

                  return SlideTransition(
                    position: slideAnimation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: ResponsiveText.bodyMedium(
                  skill.name,
                  key: ValueKey(skill.name),
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
