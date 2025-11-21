import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';

import '../../../../../core/affichage/screen_size_detector.dart';
import '../../../../../core/ui/widgets/ui_widgets_extentions.dart';
import 'service_card_helpers.dart';

class ServiceChartLegend extends ConsumerWidget {
  final ServiceExpertise expertise;

  const ServiceChartLegend({
    super.key,
    required this.expertise,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final info = ref.watch(responsiveInfoProvider);
    final skills = expertise.topSkills.take(5).toList();
    final fontSize = ServiceCardHelpers.getFontSize(
      info,
      small: 9,
      medium: 10,
      large: 11,
    );
    final colors = ServiceCardHelpers.getChartColors();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: skills.asMap().entries.map((entry) {
        final index = entry.key;
        final skill = entry.value;

        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: ServiceCardHelpers.getSpacing(
              info,
              small: 2,
              medium: 3,
              large: 4,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: ServiceCardHelpers.getSpacing(
                  info,
                  small: 8,
                  medium: 10,
                  large: 12,
                ),
                height: ServiceCardHelpers.getSpacing(
                  info,
                  small: 8,
                  medium: 10,
                  large: 12,
                ),
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(
                width: ServiceCardHelpers.getSpacing(
                  info,
                  small: 4,
                  medium: 6,
                  large: 8,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ResponsiveText.bodySmall(
                      skill.name,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    ResponsiveText.bodySmall(
                      '${skill.levelPercent}% • ${skill.projectCount} projets',
                      style: TextStyle(
                        fontSize: fontSize - 1,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
