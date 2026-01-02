import 'package:flutter/material.dart';
import 'package:portefolio/features/generator/views/generator_widgets_extentions.dart';

/// Widget pour afficher un badge 3D
class ExperienceIcon3D extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double padding;

  const ExperienceIcon3D({
    super.key,
    required this.icon,
    required this.color,
    this.size = 24.0,
    this.padding = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final double containerSize = size + padding * 2;

    return ThreeDTechIcon(icon: icon, size: containerSize, color: color);
  }
}
