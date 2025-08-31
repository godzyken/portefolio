import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controller/theme_controller.dart';
import '../../theme/theme_data.dart';

class ThemePaletteCheese extends ConsumerWidget {
  const ThemePaletteCheese({super.key});

  final List<BasicTheme> themes = const [
    BasicTheme(
      mode: AppThemeMode.system,
      primaryColorValue: 0xFF356859,
      tertiaryColorValue: 0xFFF8A776,
      neutralColorValue: 0xFF37966F,
    ),
    BasicTheme(
      mode: AppThemeMode.light,
      primaryColorValue: 0xFF388887,
      tertiaryColorValue: 0xFFF88876,
      neutralColorValue: 0xFF34436F,
    ),
    BasicTheme(
      mode: AppThemeMode.dark,
      primaryColorValue: 0xFF921859,
      tertiaryColorValue: 0xFFF2A226,
      neutralColorValue: 0xFF37989F,
    )
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeControllerProvider);

    return Wrap(
      spacing: 12,
      children: themes.map((theme) {
        final isSelected = theme.primaryColor == currentTheme.primaryColor &&
            theme.mode == currentTheme.mode;

        return GestureDetector(
          onTap: () {
            ref.read(themeControllerProvider.notifier).applyTheme(theme);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isSelected ? 40 : 32,
            height: isSelected ? 40 : 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.primaryColor,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey,
                width: isSelected ? 3 : 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
