import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controller/theme_controller.dart';
import '../../theme/theme_data.dart'; // adapte le chemin

class AnimatedThemeSwitcherButton extends ConsumerWidget {
  const AnimatedThemeSwitcherButton({super.key});

  IconData _getIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.wb_sunny_rounded;
      case AppThemeMode.dark:
        return Icons.nightlight_round;
      case AppThemeMode.system:
        return Icons.settings;
      case AppThemeMode.custom:
        return Icons.palette;
    }
  }

  Color _getColor(BuildContext context, AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Colors.amber;
      case AppThemeMode.dark:
        return Colors.deepPurple;
      case AppThemeMode.system:
        return Theme.of(context).colorScheme.primary;
      case AppThemeMode.custom:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider).mode;
    final icon = _getIcon(mode);
    final color = _getColor(context, mode);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha((255 * 0.1).toInt()),
        border: Border.all(color: color, width: 2),
      ),
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            icon,
            key: ValueKey(mode),
            color: color,
          ),
        ),
        tooltip: 'Changer le thème',
        onPressed: () {
          ref.read(themeControllerProvider.notifier).toggleBrightness();
        },
      ),
    );
  }
}
