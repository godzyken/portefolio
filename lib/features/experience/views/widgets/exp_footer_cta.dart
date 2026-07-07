import 'package:flutter/material.dart';

import '../../../../core/affichage/colors_spec.dart';
import '../../../../core/ui/widgets/responsive_text.dart';

class ExpFooterCta extends StatelessWidget {
  const ExpFooterCta({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ResponsiveText.headlineSmall(
          'Voir détails',
          style: TextStyle(
            color: ColorHelpers.cyan.withValues(alpha: 0.7),
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.arrow_forward_ios, size: 10, color: ColorHelpers.cyan),
      ],
    );
  }
}
