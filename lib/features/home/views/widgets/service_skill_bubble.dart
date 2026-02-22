import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';
import 'package:portefolio/features/generator/views/generator_widgets_extentions.dart';

import '../../../../../core/affichage/screen_size_detector.dart';
import '../../../../constants/tech_logos.dart';
import '../../../../core/affichage/colors_spec.dart';
import '../../../../core/provider/image_providers.dart';
import '../../../../core/ui/ui_widgets_extentions.dart';

/// Widget représentant une bulle de compétence avec icône/logo
class ServiceSkillBubble extends ConsumerWidget {
  final TechSkill skill;
  final int index;
  final bool isActive;

  const ServiceSkillBubble({
    super.key,
    required this.skill,
    required this.index,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(responsiveInfoProvider);
    final size = info.isMobile ? 50.0 : 70.0;
    final color = ColorHelpers.getColorForIndex(index);
    final String skillName = skill.name.toLowerCase();
    final String? logoPath = ref.watch(skillLogoPathProvider(skillName));
    final IconData skillIcon = getIconFromName(skillName);

    return ResponsiveBox(
      margin: const EdgeInsets.only(right: 8.0),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: isActive ? Border.all(color: Colors.white, width: 3) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ThreeDTechIcon(
            icon: skillIcon,
            logoPath: logoPath,
            color: Colors.white,
            size: size,
          ),
          Positioned(
              bottom: 4,
              child: ResponsiveText.bodySmall(
                '${skill.levelPercent}%',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: info.isMobile ? 10 : 12,
                    shadows: [
                      const Shadow(blurRadius: 4, color: Colors.black)
                    ]),
              )),
        ],
      ),
    );
  }
}
