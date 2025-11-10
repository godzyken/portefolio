/*
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controller/theme_controller.dart';
import '../../theme/theme_data.dart';

class ThemePaletteButton extends ConsumerStatefulWidget {
  const ThemePaletteButton({super.key});

  @override
  ConsumerState<ThemePaletteButton> createState() => _ThemePaletteButtonState();
}

class _ThemePaletteButtonState extends ConsumerState<ThemePaletteButton>
    with SingleTickerProviderStateMixin {
  bool isOpen = false;
  late AnimationController controller;

  final List<BasicTheme> themes = [
    const BasicTheme(
      mode: AppThemeMode.system,
      primaryColorValue: 0xFF356859,
      tertiaryColorValue: 0xFFF8A776,
      neutralColorValue: 0xFF37966F,
    ),
    const BasicTheme(
      mode: AppThemeMode.light,
      primaryColorValue: 0xFF388887,
      tertiaryColorValue: 0xFFF88876,
      neutralColorValue: 0xFF34436F,
    ),
    const BasicTheme(
      mode: AppThemeMode.dark,
      primaryColorValue: 0xFF921859,
      tertiaryColorValue: 0xFFF2A226,
      neutralColorValue: 0xFF37989F,
    )
  ];

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  void toggle() {
    setState(() => isOpen = !isOpen);
    isOpen ? controller.forward() : controller.reverse();
  }

  void applyTheme(BasicTheme theme) {
    ref.read(themeControllerProvider.notifier).applyTheme(theme);
    toggle(); // referme le menu
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        ...List.generate(themes.length, (i) {
          final angle = (i / themes.length) * pi / 2; // 90° spread
          const radius = 100.0;

          return AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final offset = Offset(
                cos(angle) * radius * controller.value,
                -sin(angle) * radius * controller.value,
              );
              return Positioned(
                bottom: 16 + offset.dy,
                right: 16 + offset.dx,
                child: Opacity(
                  opacity: controller.value,
                  child: GestureDetector(
                    onTap: () => applyTheme(themes[i]),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: themes[i].primaryColor,
                    ),
                  ),
                ),
              );
            },
          );
        }),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FloatingActionButton(
            onPressed: toggle,
            child: const Icon(Icons.palette),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
*/
