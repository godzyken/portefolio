import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/projets/providers/projet_providers.dart';

import '../caracter_widget.dart';

/// Avatar réactif qui s'adapte à la section active du Command Center
class ReactiveRiveAvatar extends ConsumerWidget {
  const ReactiveRiveAvatar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSection = ref.watch(activeSectionProvider);

    // On peut associer un effet visuel ou une posture selon la section active
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 230,
          height: 310,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Effet de halo néon derrière l'avatar
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _getGlowColor(activeSection).withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const CharacterViewer(),
            ],
          ),
        ),
      ],
    );
  }

  Color _getGlowColor(String sectionId) {
    switch (sectionId) {
      case 'hero':
        return const Color(0xFF00E5FF); // Cyan
      case 'tech':
        return const Color(0xFF7C4DFF); // Violet
      case 'architecture':
        return const Color(0xFF00E676); // Vert
      case 'results':
        return const Color(0xFFFF007F); // Magenta
      default:
        return const Color(0xFF00E5FF);
    }
  }
}
