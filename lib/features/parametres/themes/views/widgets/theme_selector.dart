import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';

import '../../../../../core/ui/widgets/responsive_text.dart';
import '../../controller/theme_controller.dart';
import '../../theme/theme_data.dart';

class ThemeSelector extends ConsumerStatefulWidget {
  const ThemeSelector({super.key});

  @override
  ConsumerState<ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends ConsumerState<ThemeSelector> {
  late BasicTheme _previewTheme;

  @override
  void initState() {
    super.initState();
    previewTheme();
  }

  Future<void> previewTheme() async {
    _previewTheme = ref.read(themeControllerProvider);
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final current = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);

    return Theme(
        data: _previewTheme.toThemeData(),
        child: buildWrap(current, controller));
  }

  ResponsiveBox buildWrap(BasicTheme current, ThemeController controller) {
    final info = ref.watch(responsiveInfoProvider);
    return ResponsiveBox(
      height: info.size.height * 0.7,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: List.generate(availableThemes.length, (index) {
            final theme = availableThemes[index];
            final isSelected = theme.primaryColor == current.primaryColor;

            return GestureDetector(
              onTap: () => controller.applyTheme(theme),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  border: Border.all(
                    color: isSelected ? theme.primaryColor : Colors.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ResponsiveBox(
                  padding: const EdgeInsets.all(8),
                  paddingSize: ResponsiveSpacing.s,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.primaryColor,
                        child: Text(theme.emoji ?? '🎨'),
                      ),
                      const ResponsiveBox(paddingSize: ResponsiveSpacing.s),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(theme.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 23)),
                            const ResponsiveBox(
                                paddingSize: ResponsiveSpacing.xs),
                            Row(
                              children: [
                                _colorDot(theme.primaryColor),
                                _colorDot(theme.tertiaryColor),
                                _colorDot(theme.neutralColor),
                                const ResponsiveBox(
                                    paddingSize: ResponsiveSpacing.s),
                                ResponsiveText.bodyMedium(
                                  'Mode: ${theme.mode.name}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const ResponsiveBox(paddingSize: ResponsiveSpacing.s),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _previewTheme = theme;
                              });
                            },
                            child: const ResponsiveText.headlineMedium(
                                'Prévisualiser'),
                          ),
                          ResponsiveButton(
                            onPressed: () {
                              controller.applyTheme(theme);
                              Navigator.of(context).pop();
                            },
                            child: const ResponsiveText.headlineMedium(
                                'Appliquer'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _colorDot(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: CircleAvatar(
        backgroundColor: color,
        radius: 8,
      ),
    );
  }
}
