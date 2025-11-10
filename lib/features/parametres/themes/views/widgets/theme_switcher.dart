/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/affichage/screen_size_detector.dart';
import '../../controller/theme_controller.dart';
import '../../theme/theme_data.dart';

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeController = ref.read(themeControllerProvider.notifier);
    final current = ref.watch(themeControllerProvider);
    final info = ref.watch(responsiveInfoProvider);
    if (info.size.width < 500) {
      // Mode compact : on peut changer le thème par défaut
      themeController.applyTheme(
        BasicTheme(
          mode: AppThemeMode.system,
          primaryColorValue: current.primaryColor.toARGB32(),
          tertiaryColorValue: current.tertiaryColor.toARGB32(),
          neutralColorValue: current.neutralColor.toARGB32(),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: () => themeController.toggleBrightness(),
      icon: const Icon(Icons.brightness_6),
      label: const Text("Changer le mode"),
      style: ElevatedButton.styleFrom(
        backgroundColor: current.tertiaryColor,
        foregroundColor: current.primaryColor,
      ),
    );
  }
}
*/
