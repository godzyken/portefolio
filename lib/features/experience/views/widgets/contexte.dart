import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

import '../../../../core/affichage/colors_spec.dart';
import '../../data/experiences_data.dart';

class Contexte extends ConsumerWidget {
  const Contexte({super.key, required this.exp, this.maxLines = 3});
  final Experience exp;
  final int maxLines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (exp.contexte.isEmpty) {
      return const SizedBox.shrink();
    }
    return ResponsiveText.bodySmall(
      exp.contexte,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: ColorHelpers.textSecondary.withValues(alpha: 0.85),
        fontSize: 12,
        height: 1.6,
      ),
    );
  }
}
