import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';

import '../../../../../core/ui/widgets/responsive_text.dart';
import '../../controller/theme_controller.dart';
import '../../provider/custom_themes_provider.dart';
import '../../theme/theme_data.dart';

class ThemeSelector extends ConsumerStatefulWidget {
  const ThemeSelector({super.key});

  @override
  ConsumerState<ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends ConsumerState<ThemeSelector>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BasicTheme? _previewTheme;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _previewTheme = ref.read(themeControllerProvider);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final current = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);
    final customThemes = ref.watch(customThemesProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ResponsiveBox(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: ColorHelpers.createGlowEffect(
                color: current.primaryColor,
                blurRadius: 30,
                spreadRadius: 0,
                alpha: 0.3)),
        child: Column(
          children: [
            _buildHeader(current),

            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: current.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: current.primaryColor,
              tabs: const [
                Tab(icon: Icon(Icons.palette), text: 'Thèmes prédéfinis'),
                Tab(icon: Icon(Icons.brush), text: 'Mes thèmes'),
              ],
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildThemeGrid(availableThemes, current, controller),
                  _buildCustomThemesGrid(customThemes, current, controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BasicTheme current) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            current.primaryColor.withValues(alpha: 0.2),
            current.tertiaryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          // Aperçu actuel
          ResponsiveBox(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [current.primaryColor, current.tertiaryColor],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: ColorHelpers.createGlowEffect(
                color: current.primaryColor,
                blurRadius: 20,
              ),
            ),
            child: Center(
              child: Text(
                current.emoji ?? '🎨',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText.bodySmall(
                  current.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ResponsiveText.bodySmall(
                  'Mode: ${current.mode.name}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildColorChip(current.primaryColor, 'Primaire'),
                    const SizedBox(width: 8),
                    _buildColorChip(current.tertiaryColor, 'Tertiaire'),
                    const SizedBox(width: 8),
                    _buildColorChip(current.neutralColor, 'Neutre'),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorChip(Color color, String label) {
    return Tooltip(
      message: label,
      child: ResponsiveBox(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeGrid(
    List<BasicTheme> themes,
    BasicTheme current,
    ThemeController controller,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final theme = themes[index];
        final isSelected = theme.primaryColor == current.primaryColor &&
            theme.name == current.name;

        return _buildThemeCard(theme, isSelected, controller);
      },
    );
  }

  Widget _buildCustomThemesGrid(
    List<BasicTheme> themes,
    BasicTheme current,
    ThemeController controller,
  ) {
    return Column(
      children: [
        ResponsiveBox(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {
              // Ouvrir le dialog de création
              // showDialog(context: context, builder: (_) => ThemeEditorDialog())
            },
            icon: const Icon(Icons.add),
            label: const ResponsiveText.bodySmall('Créer un nouveau thème'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ),
        Expanded(
          child: themes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      ResponsiveText.bodySmall(
                        'Aucun thème personnalisé',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ResponsiveText.titleSmall(
                        'Créez votre premier thème !',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: themes.length,
                  itemBuilder: (context, index) {
                    final theme = themes[index];
                    final isSelected =
                        theme.primaryColor == current.primaryColor &&
                            theme.name == current.name;

                    return _buildThemeCard(
                      theme,
                      isSelected,
                      controller,
                      showDelete: true,
                      onDelete: () {
                        ref
                            .read(customThemesProvider.notifier)
                            .deleteTheme(index);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildThemeCard(
    BasicTheme theme,
    bool isSelected,
    ThemeController controller, {
    bool showDelete = false,
    VoidCallback? onDelete,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _previewTheme = theme;
            });
          },
          onDoubleTap: () {
            controller.applyTheme(theme);
            Navigator.of(context).pop();
          },
          borderRadius: BorderRadius.circular(16),
          child: ResponsiveBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor.withValues(alpha: 0.2),
                  theme.tertiaryColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? theme.primaryColor
                    : Colors.grey.withValues(alpha: 0.3),
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? ColorHelpers.createGlowEffect(
                      color: theme.primaryColor,
                      blurRadius: 15,
                      spreadRadius: 0,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                // Contenu principal
                ResponsiveBox(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Emoji et nom
                      Row(
                        children: [
                          Text(
                            theme.emoji ?? '🎨',
                            style: const TextStyle(fontSize: 32),
                          ),
                          if (isSelected) ...[
                            const Spacer(),
                            ResponsiveBox(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      ResponsiveText.bodySmall(
                        theme.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      // Palette de couleurs
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildSmallColorDot(theme.primaryColor),
                          const SizedBox(width: 4),
                          _buildSmallColorDot(theme.tertiaryColor),
                          const SizedBox(width: 4),
                          _buildSmallColorDot(theme.neutralColor),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Mode
                      ResponsiveBox(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          theme.mode.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bouton supprimer pour thèmes custom
                if (showDelete)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: Colors.red,
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallColorDot(Color color) {
    return ResponsiveBox(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
