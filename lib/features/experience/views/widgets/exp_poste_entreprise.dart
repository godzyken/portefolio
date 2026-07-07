import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';

import '../../../../core/affichage/colors_spec.dart';

class ExpPosteEntreprise extends ConsumerWidget {
  final Experience exp;

  const ExpPosteEntreprise({super.key, required this.exp});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Poste (titre principal)
        ResponsiveText.titleSmall(
          exp.poste,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: ColorHelpers.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        // Entreprise avec dot magenta
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: ColorHelpers.magenta,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ColorHelpers.magenta.withValues(alpha: 0.6),
                    blurRadius: 6,
                  )
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ResponsiveText.headlineMedium(
                exp.entreprise,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ColorHelpers.magenta,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
