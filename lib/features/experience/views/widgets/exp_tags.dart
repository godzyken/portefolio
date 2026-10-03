import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';
import 'package:portefolio/features/generator/views/widgets/three_d_tech_icon.dart';

import '../../../../core/affichage/colors_spec.dart';
import '../../../../core/ui/widgets/responsive_text.dart';

class ExpTags extends ConsumerWidget {
  const ExpTags({super.key, required this.exp});
  final Experience exp;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = exp.tags;
    if (tags.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.take(8).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: ColorHelpers.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: ColorHelpers.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ThreeDTechIcon(
                logoPath: tag,
                color: ColorHelpers.cyan,
                size: 16,
              ),
              const SizedBox(width: 6),
              ResponsiveText.bodySmall(
                tag,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
