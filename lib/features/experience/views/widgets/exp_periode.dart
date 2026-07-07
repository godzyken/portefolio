import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:portefolio/features/experience/data/exp_data_extentions.dart';

import '../../../../core/affichage/colors_spec.dart';

class ExpPeriode extends ConsumerWidget {
  final Experience exp;

  const ExpPeriode({super.key, required this.exp});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (exp.periode.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        const Icon(Icons.schedule_outlined,
            size: 12, color: ColorHelpers.textSecondary),
        const SizedBox(width: 6),
        ResponsiveText.bodySmall(
          exp.periode,
          style: const TextStyle(
            color: ColorHelpers.textSecondary,
            fontSize: 12,
            fontFamily: 'monospace',
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
