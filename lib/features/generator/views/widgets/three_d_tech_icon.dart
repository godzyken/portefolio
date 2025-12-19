import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/tech_logos.dart';
import '../../../../core/provider/image_providers.dart';
import '../../../../core/ui/widgets/smart_image.dart';

class ThreeDTechIcon extends ConsumerWidget {
  final IconData? icon;
  final String? logoPath;
  final Color color;
  final double size;

  const ThreeDTechIcon({
    super.key,
    this.icon,
    this.logoPath,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String skillName = logoPath!.toLowerCase();
    final String? path = ref.watch(skillLogoPathProvider(skillName));
    final IconData skillIcon = getIconFromName(skillName);

    return Transform(
      // Applique une légère perspective et rotation
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.002) // Perspective
        ..rotateX(-0.1)
        ..rotateY(0.2),
      alignment: Alignment.center,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.4), // Reflet de brillance
              color.withValues(alpha: 0.2),
            ],
          ),
          boxShadow: [
            // Ombre portée pour l'effet de profondeur
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(-2, 4),
            ),
            // Glow interne
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              spreadRadius: -2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: logoPath != null
              ? SmartImage(
                  path: path!,
                  width: size * 0.45,
                  height: size * 0.45,
                  fit: BoxFit.contain,
                  enableShimmer: false,
                  useCache: true,
                  fallbackIcon: skillIcon,
                  fallbackColor: Colors.white,
                )
              : Icon(
                  icon,
                  size: size * 0.6,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}
