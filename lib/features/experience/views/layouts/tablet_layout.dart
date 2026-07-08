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

class TabletLayout extends ConsumerStatefulWidget {
  const TabletLayout({super.key, required this.experience});
  final Experience experience;
  @override
  ConsumerState<TabletLayout> createState() => _TabletLayoutState();
}

class _TabletLayoutState extends ConsumerState<TabletLayout> {
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
          const SizedBox(height: 16),
          ExpPosteEntreprise(
            exp: pO,
          ),
          const SizedBox(height: 12),
          ExpPeriode(
            exp: pO,
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Contexte(exp: pO, maxLines: 5),
                    const SizedBox(height: 20),
                    ExpTags(
                      exp: pO,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 4,
                child: ExpImage(
                  exp: pO,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ExpResultats(
            exp: pO,
          ),
          const SizedBox(height: 16),
          const ExpFooterCta(),
        ],
      ),
    );
  }
}
