import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/parametres/themes/controller/theme_controller.dart';
import 'package:portefolio/features/parametres/themes/provider/custom_themes_provider.dart';
import 'package:portefolio/features/parametres/themes/theme/theme_data.dart';
import 'package:portefolio/features/parametres/themes/views/widgets/advanced_theme_editor.dart';
import 'package:portefolio/features/parametres/themes/views/widgets/quick_color_palette.dart';
import 'package:portefolio/features/parametres/themes/views/widgets/theme_comparison.dart';
import 'package:portefolio/features/parametres/themes/views/widgets/theme_selector.dart';

import '../../../../../core/ui/widgets/responsive_text.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeControllerProvider);
    final customThemes = ref.watch(customThemesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres de Thème'),
        actions: [
          // Bouton pour comparer des thèmes
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            tooltip: 'Comparer des thèmes',
            onPressed: () => _showThemeComparison(context, currentTheme),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ═══════════════════════════════════════════════════════════════
          // Thème actuel
          // ═══════════════════════════════════════════════════════════════
          _buildCurrentThemeSection(context, currentTheme),
          const SizedBox(height: 24),

          // ═══════════════════════════════════════════════════════════════
          // Actions rapides
          // ═══════════════════════════════════════════════════════════════
          _buildQuickActionsSection(context, ref),
          const SizedBox(height: 24),

          // ═══════════════════════════════════════════════════════════════
          // Thèmes personnalisés
          // ═══════════════════════════════════════════════════════════════
          _buildCustomThemesSection(context, customThemes, ref),
        ],
      ),
    );
  }

  Widget _buildCurrentThemeSection(BuildContext context, BasicTheme theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thème actuel',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.primaryColor, theme.tertiaryColor],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      theme.emoji ?? '🎨',
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        theme.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mode: ${theme.mode.name}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildColorChip(theme.primaryColor, 'Primaire'),
                          const SizedBox(width: 8),
                          _buildColorChip(theme.tertiaryColor, 'Tertiaire'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions rapides',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ResponsiveButton.icon(
                    onPressed: () => _showThemeSelector(context),
                    icon: const Icon(Icons.palette),
                    label: 'Changer de thème',
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ResponsiveButton.icon(
                    onPressed: () => _showThemeEditor(context),
                    icon: const Icon(Icons.add),
                    label: 'Créer un thème',
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(themeControllerProvider.notifier).toggleBrightness();
              },
              icon: const Icon(Icons.brightness_6),
              label: const Text('Basculer Clair/Sombre'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomThemesSection(
    BuildContext context,
    List<BasicTheme> themes,
    WidgetRef ref,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mes thèmes personnalisés',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${themes.length} thème(s)',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (themes.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.palette_outlined,
                        size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Aucun thème personnalisé',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else
              ...themes
                  .map((theme) => _buildThemeListTile(context, theme, ref)),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeListTile(
    BuildContext context,
    BasicTheme theme,
    WidgetRef ref,
  ) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.primaryColor, theme.tertiaryColor],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child:
              Text(theme.emoji ?? '🎨', style: const TextStyle(fontSize: 20)),
        ),
      ),
      title: Text(theme.name),
      subtitle: Text(theme.mode.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showThemeEditor(context, initialTheme: theme),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              ref.read(themeControllerProvider.notifier).applyTheme(theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorChip(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          const ThemeSelector(), // Widget from theme_selector.dart
    );
  }

  void _showThemeEditor(BuildContext context, {BasicTheme? initialTheme}) {
    showDialog(
      context: context,
      builder: (context) => AdvancedThemeEditor(
        initialTheme: initialTheme,
      ),
    );
  }

  void _showThemeComparison(BuildContext context, BasicTheme currentTheme) {
    // Afficher d'abord une liste pour choisir le thème à comparer
    showDialog(
      context: context,
      builder: (context) => QuickCompareButton(
        currentTheme: currentTheme,
        availableThemes: availableThemes,
      ),
    );
  }
}

/// Bouton flottant pour changer rapidement de thème
class FloatingThemeButton extends ConsumerWidget {
  const FloatingThemeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeControllerProvider);

    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const ThemeSelector(),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.primaryColor, theme.tertiaryColor],
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child:
              Text(theme.emoji ?? '🎨', style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}

/// Widget de sélection de couleur simple
class SimpleColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;
  final String label;

  const SimpleColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
    required this.label,
  });

  @override
  State<SimpleColorPicker> createState() => _SimpleColorPickerState();
}

class _SimpleColorPickerState extends State<SimpleColorPicker> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        QuickColorPalette(
          initialColor: widget.initialColor,
          onColorChanged: widget.onColorChanged,
        ),
      ],
    );
  }
}
