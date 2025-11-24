import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/provider/image_providers.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';
import 'package:portefolio/features/home/views/widgets/extentions_widgets.dart';

import '../../../../../constants/tech_logos.dart';
import '../../../../../core/affichage/screen_size_detector.dart';
import '../../../../../core/ui/widgets/ui_widgets_extentions.dart';

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
    final color = ServiceCardHelpers.getColorForIndex(index);

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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSkillIcon(ref, size, info),
          ResponsiveText.bodySmall(
            '${skill.levelPercent}%',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: info.isMobile ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillIcon(WidgetRef ref, double size, ResponsiveInfo info) {
    final String skillName = skill.name.toLowerCase();
    final String? logoPath = ref.watch(skillLogoPathProvider(skillName));
    final IconData skillIcon = getIconFromName(skillName);

    if (logoPath != null) {
      return SmartImage(
        path: logoPath,
        width: size * 0.45,
        height: size * 0.45,
        fit: BoxFit.contain,
        enableShimmer: false,
        useCache: true,
        fallbackIcon: skillIcon,
        fallbackColor: Colors.white,
      );
    }

    return Icon(
      skillIcon,
      size: size * 0.45,
      color: Colors.white,
    );
  }
}
