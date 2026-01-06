import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';
import 'package:portefolio/features/parametres/themes/controller/theme_controller.dart';
import 'package:portefolio/features/parametres/themes/provider/custom_themes_provider.dart';
import 'package:portefolio/features/parametres/themes/theme/theme_data.dart';

class AdvancedThemeEditor extends ConsumerStatefulWidget {
  final BasicTheme? initialTheme;

  const AdvancedThemeEditor({super.key, this.initialTheme});

  @override
  ConsumerState<AdvancedThemeEditor> createState() =>
      _AdvancedThemeEditorState();
}

class _AdvancedThemeEditorState extends ConsumerState<AdvancedThemeEditor>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TabController _tabController;

  // Couleurs
  Color _primaryColor = const Color(0xFF00E5FF);
  Color _tertiaryColor = const Color(0xFF9C27FF);
  Color _neutralColor = const Color(0xFF000000);

  // Mode et emoji
  AppThemeMode _mode = AppThemeMode.dark;
  String _emoji = '🎨';

  // Preview en temps réel
  BasicTheme? _previewTheme;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    if (widget.initialTheme != null) {
      _primaryColor = widget.initialTheme!.primaryColor;
      _tertiaryColor = widget.initialTheme!.tertiaryColor;
      _neutralColor = widget.initialTheme!.neutralColor;
      _mode = widget.initialTheme!.mode;
      _emoji = widget.initialTheme!.emoji ?? '🎨';
      _nameController = TextEditingController(text: widget.initialTheme!.name);
    } else {
      _nameController = TextEditingController(text: 'Mon Thème');
    }

    _updatePreview();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _updatePreview() {
    setState(() {
      _previewTheme = BasicTheme(
        primaryColorValue: _primaryColor.toARGB32(),
        tertiaryColorValue: _tertiaryColor.toARGB32(),
        neutralColorValue: _neutralColor.toARGB32(),
        mode: _mode,
        name: _nameController.text.isEmpty ? 'Mon Thème' : _nameController.text,
        emoji: _emoji,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 800),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: ColorHelpers.createGlowEffect(
            color: _primaryColor,
            blurRadius: 30,
            alpha: 0.3,
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Row(
                children: [
                  // Panneau d'édition (gauche)
                  Expanded(
                    flex: 2,
                    child: _buildEditorPanel(),
                  ),
                  // Prévisualisation (droite)
                  Expanded(
                    flex: 3,
                    child: _buildPreviewPanel(),
                  ),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ResponsiveBox(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryColor.withValues(alpha: 0.2),
            _tertiaryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          ResponsiveBox(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryColor, _tertiaryColor],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: ColorHelpers.createGlowEffect(
                color: _primaryColor,
                blurRadius: 20,
              ),
            ),
            child: Center(
              child: ResponsiveText.displaySmall(_emoji,
                  style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ResponsiveText.bodySmall(
                  'Éditeur de Thème',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ResponsiveText.bodySmall(
                  'Créez votre thème personnalisé',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
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

  Widget _buildEditorPanel() {
    return ResponsiveBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: _primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: _primaryColor,
            tabs: const [
              Tab(icon: Icon(Icons.info_outline), text: 'Info'),
              Tab(icon: Icon(Icons.palette), text: 'Couleurs'),
              Tab(icon: Icon(Icons.tune), text: 'Options'),
            ],
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(),
                _buildColorsTab(),
                _buildOptionsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ResponsiveText.bodySmall(
            'Informations du thème',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Nom du thème
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nom du thème',
              prefixIcon: Icon(Icons.text_fields, color: _primaryColor),
            ),
            onChanged: (_) => _updatePreview(),
          ),
          const SizedBox(height: 24),

          // Sélection emoji
          const ResponsiveText.bodySmall(
            'Icône du thème',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildEmojiGrid(),
        ],
      ),
    );
  }

  Widget _buildEmojiGrid() {
    final emojis = [
      '🎨',
      '🌌',
      '🌈',
      '🔥',
      '💎',
      '⚡',
      '🌊',
      '🌙',
      '⭐',
      '🎭',
      '🎪',
      '🎯',
      '🚀',
      '🛸',
      '🌟',
      '✨',
      '💫',
      '🌠',
      '🔮',
      '🎆',
      '🎇',
      '🧪',
      '🔬',
      '🧬',
      '🎼',
      '🎵',
      '🎸',
      '🎹',
      '🎺',
      '🎻',
      '🥁',
      '🎧',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: emojis.map((emoji) {
        final isSelected = emoji == _emoji;
        return GestureDetector(
          onTap: () {
            setState(() => _emoji = emoji);
            _updatePreview();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected
                  ? _primaryColor.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? _primaryColor
                    : Colors.grey.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: ResponsiveText.displayMedium(emoji,
                  style: const TextStyle(fontSize: 24)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ResponsiveText.bodySmall(
            'Palette de couleurs',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          _buildColorSection(
            'Couleur Primaire',
            'Couleur principale utilisée pour les éléments interactifs',
            _primaryColor,
            (color) {
              setState(() => _primaryColor = color);
              _updatePreview();
            },
          ),
          const SizedBox(height: 24),

          _buildColorSection(
            'Couleur Tertiaire',
            'Couleur d\'accent pour les gradients et détails',
            _tertiaryColor,
            (color) {
              setState(() => _tertiaryColor = color);
              _updatePreview();
            },
          ),
          const SizedBox(height: 24),

          _buildColorSection(
            'Couleur Neutre',
            'Couleur de fond et surfaces',
            _neutralColor,
            (color) {
              setState(() => _neutralColor = color);
              _updatePreview();
            },
          ),
          const SizedBox(height: 24),

          // Palette harmonieuse suggérée
          _buildSuggestedPalette(),
        ],
      ),
    );
  }

  Widget _buildColorSection(
    String title,
    String description,
    Color color,
    ValueChanged<Color> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText.titleSmall(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        ResponsiveText.displaySmall(
          description,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),

        // Sélecteur de couleur avancé
        _buildAdvancedColorPicker(color, onChanged),
      ],
    );
  }

  Widget _buildAdvancedColorPicker(Color color, ValueChanged<Color> onChanged) {
    return Column(
      children: [
        // Aperçu de la couleur actuelle
        ResponsiveBox(
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.2), width: 2),
            boxShadow: ColorHelpers.createGlowEffect(
              color: color,
              blurRadius: 15,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ResponsiveText.bodyMedium(
                  '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                  style: TextStyle(
                    color: ColorHelpers.getContrastColor(color),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                ResponsiveText.bodySmall(
                  'RGB(${(color.r * 255.0).round() & 0xff}, ${(color.g * 255.0).round() & 0xff}, ${(color.b * 255.0).round() & 0xff})',
                  style: TextStyle(
                    color: ColorHelpers.getContrastColor(color)
                        .withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Palette de couleurs prédéfinies
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Couleurs vives
            ...ColorHelpers.chartColors
                .map((c) => _buildColorSwatch(c, onChanged)),
            // Couleurs additionnelles
            ...[
              Colors.red.shade600,
              Colors.pink.shade600,
              Colors.purple.shade600,
              Colors.deepPurple.shade600,
              Colors.indigo.shade600,
              Colors.blue.shade600,
              Colors.lightBlue.shade600,
              Colors.cyan.shade600,
              Colors.teal.shade600,
              Colors.green.shade600,
              Colors.lightGreen.shade600,
              Colors.lime.shade600,
              Colors.yellow.shade600,
              Colors.amber.shade600,
              Colors.orange.shade600,
              Colors.deepOrange.shade600,
              Colors.brown.shade600,
              Colors.grey.shade600,
              Colors.blueGrey.shade600,
              Colors.black,
              Colors.white,
            ].map((c) => _buildColorSwatch(c, onChanged)),
          ],
        ),
        const SizedBox(height: 12),

        // Variations de la couleur actuelle
        Row(
          children: [
            Expanded(
                child:
                    _buildColorVariation(color, 0.6, 'Très sombre', onChanged)),
            const SizedBox(width: 8),
            Expanded(
                child: _buildColorVariation(color, 0.8, 'Sombre', onChanged)),
            const SizedBox(width: 8),
            Expanded(
                child: _buildColorVariation(color, 1.2, 'Clair', onChanged)),
            const SizedBox(width: 8),
            Expanded(
                child:
                    _buildColorVariation(color, 1.4, 'Très clair', onChanged)),
          ],
        ),
      ],
    );
  }

  Widget _buildColorSwatch(Color color, ValueChanged<Color> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(color),
      child: ResponsiveBox(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorVariation(
    Color baseColor,
    double factor,
    String label,
    ValueChanged<Color> onChanged,
  ) {
    final variation = factor > 1
        ? ColorHelpers.lighten(baseColor, (factor - 1) * 0.5)
        : ColorHelpers.darken(baseColor, (1 - factor) * 0.5);

    return GestureDetector(
      onTap: () => onChanged(variation),
      child: Column(
        children: [
          ResponsiveBox(
            height: 40,
            decoration: BoxDecoration(
              color: variation,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
          ),
          const SizedBox(height: 4),
          ResponsiveText.bodySmall(
            label,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedPalette() {
    final harmonious = ColorHelpers.createHarmoniousPalette(_primaryColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ResponsiveText.bodySmall(
          'Couleurs harmonieuses suggérées',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: harmonious
              .map((color) => Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _primaryColor = color);
                        _updatePreview();
                      },
                      child: Container(
                        height: 60,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: ColorHelpers.createGlowEffect(
                            color: color,
                            blurRadius: 8,
                            alpha: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildOptionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ResponsiveText.bodySmall(
            'Options du thème',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Sélection du mode
          const ResponsiveText.bodySmall(
            'Mode d\'affichage',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...AppThemeMode.values.map((mode) {
            return RadioListTile<AppThemeMode>(
              value: _mode,
              secondary: RadioGroup(
                groupValue: _mode,
                onChanged: (value) {
                  setState(() => _mode = value!);
                  _updatePreview();
                },
                child: AspectRatio(aspectRatio: 0.8, child: Container()),
              ),
              title: ResponsiveText.bodySmall(_getModeLabel(mode)),
              subtitle: ResponsiveText.displaySmall(_getModeDescription(mode)),
              activeColor: _primaryColor,
            );
          }),
        ],
      ),
    );
  }

  String _getModeLabel(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.light => 'Clair',
      AppThemeMode.dark => 'Sombre',
      AppThemeMode.system => 'Système',
      AppThemeMode.custom => 'Personnalisé',
    };
  }

  String _getModeDescription(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.light => 'Interface claire avec fond blanc',
      AppThemeMode.dark => 'Interface sombre avec fond noir',
      AppThemeMode.system => 'Suit les paramètres du système',
      AppThemeMode.custom => 'Configuration personnalisée',
    };
  }

  Widget _buildPreviewPanel() {
    if (_previewTheme == null) return const SizedBox();

    return Theme(
      data: _previewTheme!.toThemeData(),
      child: Builder(
        builder: (context) => ResponsiveBox(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText.bodySmall(
                  'Prévisualisation',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                _buildPreviewAppBar(context),
                const SizedBox(height: 16),
                _buildPreviewCard(context),
                const SizedBox(height: 16),
                _buildPreviewButtons(context),
                const SizedBox(height: 16),
                _buildPreviewTextField(context),
                const SizedBox(height: 16),
                _buildPreviewChips(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewAppBar(BuildContext context) {
    return Card(
      child: ResponsiveBox(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.menu, color: _primaryColor),
            const SizedBox(width: 16),
            ResponsiveText.bodySmall('Application',
                style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            Icon(Icons.search, color: _primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _primaryColor,
                  child: ResponsiveText.bodySmall(_emoji,
                      style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ResponsiveText.bodySmall('Titre de la carte',
                          style: Theme.of(context).textTheme.titleMedium),
                      ResponsiveText.bodySmall('Sous-titre',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ResponsiveText.displaySmall(
              'Ceci est un exemple de carte avec le thème appliqué. '
              'Les couleurs et styles sont automatiquement ajustés.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewButtons(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ResponsiveButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.check),
          label: 'Elevated',
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.favorite_border),
          label: const ResponsiveText.bodySmall('Outlined'),
        ),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.info_outline),
          label: const ResponsiveText.bodySmall('Text'),
        ),
      ],
    );
  }

  Widget _buildPreviewTextField(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Champ de saisie',
        hintText: 'Tapez quelque chose...',
        prefixIcon: Icon(Icons.edit, color: _primaryColor),
      ),
    );
  }

  Widget _buildPreviewChips(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        Chip(
            label: const ResponsiveText.bodySmall('Tag 1'),
            backgroundColor: _primaryColor.withValues(alpha: 0.2)),
        Chip(
            label: const ResponsiveText.bodySmall('Tag 2'),
            backgroundColor: _tertiaryColor.withValues(alpha: 0.2)),
        Chip(
            label: const ResponsiveText.bodySmall('Tag 3'),
            backgroundColor: _primaryColor.withValues(alpha: 0.1)),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              label: const ResponsiveText.bodySmall('Annuler'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ResponsiveButton.icon(
              onPressed: _saveTheme,
              icon: const Icon(Icons.save),
              label: 'Enregistrer',
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ResponsiveButton.icon(
              onPressed: _applyTheme,
              icon: const Icon(Icons.check_circle),
              label: 'Appliquer',
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveTheme() {
    if (_previewTheme == null) return;

    ref.read(customThemesProvider.notifier).addTheme(_previewTheme!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ResponsiveText.bodySmall(
            'Thème "${_previewTheme!.name}" enregistré !'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  void _applyTheme() {
    if (_previewTheme == null) return;

    ref.read(themeControllerProvider.notifier).applyTheme(_previewTheme!);
    ref.read(customThemesProvider.notifier).addTheme(_previewTheme!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ResponsiveText.bodySmall(
            'Thème "${_previewTheme!.name}" appliqué !'),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }
}
