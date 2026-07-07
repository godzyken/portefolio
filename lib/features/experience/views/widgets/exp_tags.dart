import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';

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
      spacing: 6,
      runSpacing: 6,
      children: tags.take(6).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: ColorHelpers.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: ColorHelpers.border),
          ),
          child: ResponsiveText.bodySmall(
            tag,
            style: const TextStyle(
              color: ColorHelpers.textSecondary,
              fontSize: 10,
              letterSpacing: 0.3,
            ),
          ),
        );
      }).toList(),
    );
  }
}
