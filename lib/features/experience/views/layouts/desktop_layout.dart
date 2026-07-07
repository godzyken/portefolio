import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';

import '../widgets/contexte.dart';
import '../widgets/exp_footer_cta.dart';
import '../widgets/exp_image.dart';
import '../widgets/exp_periode.dart';
import '../widgets/exp_poste_entreprise.dart';
import '../widgets/exp_resultats.dart';
import '../widgets/exp_tags.dart';
import '../widgets/exp_top_row.dart';

class DesktopLayout extends ConsumerStatefulWidget {
  const DesktopLayout({super.key, required this.experience});
  final Experience experience;
  @override
  ConsumerState<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends ConsumerState<DesktopLayout> {
  @override
  Widget build(BuildContext context) {
    final pO = widget.experience;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpTopRow(
            exp: pO,
          ),
          const SizedBox(height: 18),
          ExpPosteEntreprise(
            exp: pO,
          ),
          const SizedBox(height: 12),
          ExpPeriode(exp: pO),
          const SizedBox(height: 24),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 1400),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Contexte(exp: pO, maxLines: 8),
                        const SizedBox(height: 24),
                        ExpTags(exp: pO),
                        const SizedBox(height: 24),
                        ExpResultats(exp: pO),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Flexible(
                    flex: 4,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 420,
                        ),
                        child: ExpImage(exp: pO),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ExpFooterCta(),
        ],
      ),
    );
  }
}
