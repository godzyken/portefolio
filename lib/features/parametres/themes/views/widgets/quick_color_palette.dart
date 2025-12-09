import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';

/// Widget de sélection rapide de couleur avec palettes prédéfinies
class QuickColorPalette extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;
  final String? label;

  const QuickColorPalette({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
    this.label,
  });

  @override
  State<QuickColorPalette> createState() => _QuickColorPaletteState();
}

class _QuickColorPaletteState extends State<QuickColorPalette>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedColor = widget.initialColor;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
        ],

        // Aperçu de la couleur sélectionnée
        _buildColorPreview(),
        const SizedBox(height: 16),

        // Tabs pour différentes palettes
        TabBar(
          controller: _tabController,
          labelColor: _selectedColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: _selectedColor,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Vibrants'),
            Tab(text: 'Pastels'),
            Tab(text: 'Sombres'),
            Tab(text: 'Personnalisé'),
          ],
        ),
        const SizedBox(height: 16),

        // Contenu des palettes
        SizedBox(
          height: 200,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildVibrantPalette(),
              _buildPastelPalette(),
              _buildDarkPalette(),
              _buildCustomPalette(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorPreview() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _selectedColor,
            ColorHelpers.darken(_selectedColor, 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: ColorHelpers.createGlowEffect(
          color: _selectedColor,
          blurRadius: 20,
          alpha: 0.4,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '#${_selectedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
              style: TextStyle(
                color: ColorHelpers.getContrastColor(_selectedColor),
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'RGB(${(_selectedColor.r * 255.0).round() & 0xff}, ${(_selectedColor.g * 255.0).round() & 0xff}, ${(_selectedColor.b * 255.0).round() & 0xff})',
              style: TextStyle(
                color: ColorHelpers.getContrastColor(_selectedColor)
                    .withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVibrantPalette() {
    final colors = [
      const Color(0xFFFF006E), // Rose néon
      const Color(0xFFFF4500), // Orange vif
      const Color(0xFFFB5607), // Orange brûlé
      const Color(0xFFFFBE0B), // Jaune or
      const Color(0xFF00F5FF), // Cyan électrique
      const Color(0xFF00E5FF), // Cyan néon
      const Color(0xFF3A86FF), // Bleu royal
      const Color(0xFF8338EC), // Violet vibrant
      const Color(0xFFE01E00), // Rouge vif
      const Color(0xFF00FF41), // Vert Matrix
      const Color(0xFF00E676), // Vert émeraude
      const Color(0xFFFF1744), // Rouge néon
      const Color(0xFFFF4081), // Rose accent
      const Color(0xFFE040FB), // Violet néon
      const Color(0xFF7C4DFF), // Indigo deep
      const Color(0xFF536DFE), // Indigo
    ];

    return _buildColorGrid(colors);
  }

  Widget _buildPastelPalette() {
    final colors = [
      const Color(0xFFFFB3BA), // Rose pastel
      const Color(0xFFFFDFBA), // Pêche pastel
      const Color(0xFFFFFFBA), // Jaune pastel
      const Color(0xFFBAFFC9), // Vert pastel
      const Color(0xFFBAE1FF), // Bleu pastel
      const Color(0xFFE7BAFF), // Violet pastel
      const Color(0xFFFF8FB1), // Rose doux
      const Color(0xFFFFC8A0), // Orange doux
      const Color(0xFFFFF6A0), // Jaune doux
      const Color(0xFFA0FFB8), // Vert menthe
      const Color(0xFFA0D8FF), // Bleu ciel
      const Color(0xFFD8A0FF), // Lavande
      const Color(0xFFFFADC6), // Rose bonbon
      const Color(0xFFFFD4B3), // Corail
      const Color(0xFFFFF9C4), // Crème
      const Color(0xFFC4FFD4), // Vert clair
    ];

    return _buildColorGrid(colors);
  }

  Widget _buildDarkPalette() {
    final colors = [
      const Color(0xFF1A1A1A), // Noir doux
      const Color(0xFF2A2A2A), // Gris anthracite
      const Color(0xFF0A0A0A), // Noir profond
      const Color(0xFF1F1F1F), // Noir charbon
      const Color(0xFF0F0F23), // Bleu nuit
      const Color(0xFF1C0F23), // Violet sombre
      const Color(0xFF23140F), // Brun sombre
      const Color(0xFF0F231C), // Vert sombre
      const Color(0xFF581C87), // Violet profond
      const Color(0xFF4A148C), // Violet très sombre
      const Color(0xFF1A237E), // Indigo foncé
      const Color(0xFF004D40), // Teal sombre
      const Color(0xFF1B5E20), // Vert forêt
      const Color(0xFF827717), // Olive
      const Color(0xFFE65100), // Orange foncé
      const Color(0xFFBF360C), // Rouge foncé
    ];

    return _buildColorGrid(colors);
  }

  Widget _buildCustomPalette() {
    // Palette harmonieuse basée sur la couleur sélectionnée
    final harmonious =
        ColorHelpers.createHarmoniousPalette(_selectedColor, count: 8);

    // Variations de luminosité
    final variations = [
      ColorHelpers.darken(_selectedColor, 0.4),
      ColorHelpers.darken(_selectedColor, 0.3),
      ColorHelpers.darken(_selectedColor, 0.2),
      ColorHelpers.darken(_selectedColor, 0.1),
      _selectedColor,
      ColorHelpers.lighten(_selectedColor, 0.1),
      ColorHelpers.lighten(_selectedColor, 0.2),
      ColorHelpers.lighten(_selectedColor, 0.3),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Couleurs harmonieuses',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildColorGrid(harmonious),
          const SizedBox(height: 16),
          const Text(
            'Variations de luminosité',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildColorGrid(variations),
        ],
      ),
    );
  }

  Widget _buildColorGrid(List<Color> colors) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final color = colors[index];
        final isSelected = color.toARGB32() == _selectedColor.toARGB32();

        return GestureDetector(
          onTap: () {
            setState(() => _selectedColor = color);
            widget.onColorChanged(color);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.2),
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? ColorHelpers.createGlowEffect(
                      color: color,
                      blurRadius: 12,
                      alpha: 0.6,
                    )
                  : [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
        );
      },
    );
  }
}

/// Widget compact pour afficher une couleur avec possibilité de modification
class ColorDisplayButton extends StatelessWidget {
  final Color color;
  final String label;
  final VoidCallback onTap;

  const ColorDisplayButton({
    super.key,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              ColorHelpers.darken(color, 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: ColorHelpers.createGlowEffect(
            color: color,
            blurRadius: 15,
            alpha: 0.3,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: ColorHelpers.getContrastColor(color),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                    style: TextStyle(
                      color: ColorHelpers.getContrastColor(color)
                          .withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit,
              color: ColorHelpers.getContrastColor(color),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
