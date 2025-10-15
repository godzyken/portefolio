import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controller/theme_controller.dart';
import '../../theme/theme_data.dart';

class CheeseThemePicker extends ConsumerStatefulWidget {
  const CheeseThemePicker({super.key});

  @override
  ConsumerState<CheeseThemePicker> createState() => _CheeseThemePickerState();
}

class _CheeseThemePickerState extends ConsumerState<CheeseThemePicker>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnim;
  bool expanded = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    scaleAnim = CurvedAnimation(parent: controller, curve: Curves.easeOutBack);
  }

  void toggle() {
    setState(() {
      expanded = !expanded;
      if (expanded) {
        controller.forward();
      } else {
        controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeControllerProvider);
    final notifier = ref.read(themeControllerProvider.notifier);

    const radius = 80.0;

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (int i = 0; i < availableThemes.length; i++)
            AnimatedBuilder(
              animation: controller,
              builder: (_, __) {
                final angle = (2 * pi / availableThemes.length) * i;
                final dx = cos(angle) * radius * scaleAnim.value;
                final dy = sin(angle) * radius * scaleAnim.value;

                return Positioned(
                  left: 100 + dx - 20,
                  top: 100 + dy - 20,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: scaleAnim,
                        child: Tooltip(
                          message: "Thème ${i + 1}",
                          child: GestureDetector(
                            onTap: () {
                              notifier.applyTheme(availableThemes[i]);
                              toggle();
                            },
                            child: Material(
                              elevation: 4,
                              shape: const CircleBorder(),
                              color: Color(
                                availableThemes[i].primaryColorValue,
                              ),
                              child: const SizedBox(width: 40, height: 40),
                            ),
                          ),
                        ),
                      ),
                      if (scaleAnim.value > 0.5)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "T${i + 1}",
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          // Toggle Light / Dark / System
          Positioned(
            bottom: 10,
            child: IconButton(
              icon: switch (currentTheme.mode) {
                AppThemeMode.light => const Icon(Icons.light_mode),
                AppThemeMode.dark => const Icon(Icons.dark_mode),
                AppThemeMode.system => const Icon(Icons.brightness_auto),
                AppThemeMode.custom => const Icon(Icons.palette),
              },
              tooltip: "Changer mode clair/sombre/système",
              onPressed: notifier.toggleBrightness,
            ),
          ),
          // FAB centrale
          FloatingActionButton.small(
            heroTag: 'cheese-toggle',
            onPressed: toggle,
            child: Icon(expanded ? Icons.close : Icons.palette),
          ),
        ],
      ),
    );
  }
}
