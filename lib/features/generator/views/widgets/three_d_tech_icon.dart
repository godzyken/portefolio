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
    if (logoPath == null || logoPath!.isEmpty) {
      return Icon(icon ?? Icons.code, size: size, color: color);
    }

    // Récupère le logo depuis le provider
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
            tileMode: TileMode.mirror,
            colors: [
              Colors.white.withValues(alpha: 0.8), // Reflet de brillance
              color.withValues(alpha: 0.2),
            ],
          ),
          boxShadow: [
            // Effet Néon (Glow)
            BoxShadow(
              color: color.withValues(alpha: 0.6),
              blurRadius: 12,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black26,
              offset: const Offset(2, 4),
              blurRadius: 5,
            ),
          ],
        ),
        child: Center(
            child: path != null && path.isNotEmpty
                ? SmartImage(
                    path: path,
                    width: size * 0.45,
                    height: size * 0.45,
                    fit: BoxFit.contain,
                    enableShimmer: false,
                    useCache: true,
                    fallbackIcon: skillIcon,
                    fallbackColor: Colors.white,
                  )
                : Icon(skillIcon, size: size * 0.45, color: Colors.white)),
      ),
    );
  }
}
