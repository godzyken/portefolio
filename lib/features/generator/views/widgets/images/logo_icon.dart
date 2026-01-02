import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';

import '../three_d_tech_icon.dart';

/// Chip technologique 3D
class ExperienceTechChip extends ConsumerWidget {
  final String tech;
  final Color primaryColor;
  final ThemeData theme;

  const ExperienceTechChip({
    super.key,
    required this.tech,
    required this.primaryColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(responsiveInfoProvider);
    // Logo et icône de fallback gérés dans le widget
    return ThreeDTechIcon(
      logoPath: tech,
      color: primaryColor,
      size: info.isMobile ? 36 : 48,
    );
  }
}
