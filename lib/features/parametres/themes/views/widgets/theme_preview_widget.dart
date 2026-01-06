import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/features/parametres/themes/theme/theme_data.dart';

import '../../../../../core/ui/widgets/responsive_text.dart';

class ThemePreviewWidget extends StatelessWidget {
  final BasicTheme theme;
  final VoidCallback? onApply;

  const ThemePreviewWidget({
    super.key,
    required this.theme,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme.toThemeData(),
      child: Builder(
        builder: (context) => Container(
          height: 400,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.primaryColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              // AppBar preview
              _buildAppBarPreview(context),

              // Content preview
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCardPreview(context),
                      const SizedBox(height: 16),
                      _buildButtonsPreview(context),
                      const SizedBox(height: 16),
                      _buildTextFieldPreview(context),
                    ],
                  ),
                ),
              ),

              // Bottom actions
              if (onApply != null) _buildBottomActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarPreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.menu,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          const SizedBox(width: 16),
          Text(
            'Aperçu du thème',
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
          const Spacer(),
          Icon(
            Icons.search,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.more_vert,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ],
      ),
    );
  }

  Widget _buildCardPreview(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.primaryColor,
                  child: Text(
                    theme.emoji ?? '🎨',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        theme.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Exemple de carte avec ce thème',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Ce texte utilise le style bodyLarge du thème. '
              'Les couleurs et la typographie sont appliquées automatiquement.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonsPreview(BuildContext context) {
    return Row(
      children: [
        ResponsiveButton(
          onPressed: () {},
          child: const Text('Elevated'),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () {},
          child: const Text('Outlined'),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () {},
          child: const Text('Text'),
        ),
        const Spacer(),
        FloatingActionButton(
          mini: true,
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _buildTextFieldPreview(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Exemple de champ',
        hintText: 'Entrez du texte...',
        prefixIcon: Icon(
          Icons.edit,
          color: theme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
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
          // Palette de couleurs
          Expanded(
            child: Row(
              children: [
                _buildColorIndicator(theme.primaryColor, 'Primaire'),
                const SizedBox(width: 8),
                _buildColorIndicator(theme.tertiaryColor, 'Tertiaire'),
                const SizedBox(width: 8),
                _buildColorIndicator(theme.neutralColor, 'Neutre'),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ResponsiveButton.icon(
            onPressed: onApply,
            icon: const Icon(Icons.check),
            label: 'Appliquer',
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorIndicator(Color color, String label) {
    return Tooltip(
      message: label,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: ColorHelpers.createGlowEffect(
            color: color,
            blurRadius: 8,
            spreadRadius: 0,
            alpha: 0.3,
          ),
        ),
      ),
    );
  }
}

// Widget compact pour la sélection rapide
class CompactThemeCard extends StatelessWidget {
  final BasicTheme theme;
  final bool isSelected;
  final VoidCallback? onTap;

  const CompactThemeCard({
    super.key,
    required this.theme,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor.withValues(alpha: 0.15),
              theme.tertiaryColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? ColorHelpers.createGlowEffect(
                  color: theme.primaryColor,
                  blurRadius: 12,
                  spreadRadius: 0,
                )
              : null,
        ),
        child: Row(
          children: [
            Text(
              theme.emoji ?? '🎨',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildMiniColorDot(theme.primaryColor),
                      const SizedBox(width: 4),
                      _buildMiniColorDot(theme.tertiaryColor),
                      const SizedBox(width: 4),
                      _buildMiniColorDot(theme.neutralColor),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniColorDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
    );
  }
}
