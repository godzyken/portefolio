import 'package:flutter/material.dart';

import '../../../../../core/ui/ui_widgets_extentions.dart';

/// Section générique pour objectifs/missions/résultats
class ExperienceListSection extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String title;
  final List<String> items;

  const ExperienceListSection({
    super.key,
    required this.theme,
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return SectionBuilder.simple(
      title: title,
      icon: icon,
      accentColor: theme.colorScheme.primary,
      child: BulletListBuilder.circles(
        items: items,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
