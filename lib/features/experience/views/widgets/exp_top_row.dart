import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';

import '../../../../core/affichage/colors_spec.dart';
import '../../../../core/affichage/tech_maturity_framework.dart';
import '../../../../core/ui/widgets/responsive_text.dart';
import '../../../../core/ui/widgets/smart_image.dart';

class ExpTopRow extends ConsumerWidget {
  final Experience exp;

  const ExpTopRow({super.key, required this.exp});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maturity = exp.analyzeMaturity();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Logo entreprise
            if (exp.logo.isNotEmpty)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorHelpers.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: SmartImage(
                    path: exp.logo,
                    fit: BoxFit.contain,
                    enableShimmer: true,
                    autoPreload: true,
                    colorBlendMode: BlendMode.colorBurn,
                  ),
                ),
              ),

            const SizedBox(width: 12),

            // ID de l'expérience (style monospace)
            ResponsiveText(
              '#${exp.id}',
              style: TextStyle(
                color: ColorHelpers.cyan.withValues(alpha: 0.5),
                fontSize: 11,
                fontFamily: 'monospace',
                letterSpacing: 1,
              ),
            ),

            const Spacer(),

            // Badge lien projet si disponible
            if (exp.lienProjet.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ColorHelpers.magenta.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: ColorHelpers.magenta.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.link_outlined,
                        size: 10, color: ColorHelpers.magenta),
                    SizedBox(width: 4),
                    ResponsiveText(
                      'PROJET',
                      style: TextStyle(
                        color: ColorHelpers.magenta,
                        fontSize: 9,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (maturity.isNotEmpty) ...[
          const SizedBox(height: 12),
          TechMaturityRadar(scores: maturity, compact: true),
        ],
      ],
    );
  }
}
