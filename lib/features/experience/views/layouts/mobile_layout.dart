import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../generator/data/extention_models.dart';
import '../widgets/contexte.dart';
import '../widgets/exp_footer_cta.dart';
import '../widgets/exp_image.dart';
import '../widgets/exp_periode.dart';
import '../widgets/exp_poste_entreprise.dart';
import '../widgets/exp_resultats.dart';
import '../widgets/exp_tags.dart';
import '../widgets/exp_top_row.dart';

class MobileLayout extends ConsumerStatefulWidget {
  const MobileLayout({super.key, required this.experience});
  final Experience experience;
  @override
  ConsumerState<MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends ConsumerState<MobileLayout> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpTopRow(exp: widget.experience),
          const SizedBox(height: 14),
          ExpPosteEntreprise(exp: widget.experience),
          const SizedBox(height: 12),
          ExpPeriode(
            exp: widget.experience,
          ),
          const SizedBox(height: 16),
          Contexte(exp: widget.experience, maxLines: 3),
          const SizedBox(height: 14),
          ExpImage(exp: widget.experience),
          const SizedBox(height: 16),
          ExpTags(
            exp: widget.experience,
          ),
          const SizedBox(height: 16),
          ExpResultats(
            exp: widget.experience,
          ),
          const SizedBox(height: 12),
          const ExpFooterCta(),
        ],
      ),
    );
  }
}
