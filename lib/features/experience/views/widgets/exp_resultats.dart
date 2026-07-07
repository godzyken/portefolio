import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/affichage/colors_spec.dart';
import '../../../../core/ui/widgets/responsive_text.dart';
import '../../data/exp_data_extentions.dart';

class ExpResultats extends ConsumerWidget {
  const ExpResultats({super.key, required this.exp});
  final Experience exp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultats = exp.resultats;
    if (resultats.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_outline,
            size: 13, color: ColorHelpers.cyan.withValues(alpha: 0.7)),
        const SizedBox(width: 6),
        Expanded(
          child: ResponsiveText.displaySmall(
            resultats.first,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: ColorHelpers.cyan.withValues(alpha: 0.8),
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
