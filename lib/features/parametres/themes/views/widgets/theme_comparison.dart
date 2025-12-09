import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/features/parametres/themes/theme/theme_data.dart';

/// Widget pour comparer deux thèmes côte à côte
class ThemeComparison extends StatelessWidget {
  final BasicTheme theme1;
  final BasicTheme theme2;
  final VoidCallback? onApplyTheme1;
  final VoidCallback? onApplyTheme2;

  const ThemeComparison({
    super.key,
    required this.theme1,
    required this.theme2,
    this.onApplyTheme1,
    this.onApplyTheme2,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 800),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildThemePreview(context, theme1, true)),
                  Container(
                      width: 2, color: Colors.grey.withValues(alpha: 0.3)),
                  Expanded(child: _buildThemePreview(context, theme2, false)),
                ],
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          const Icon(Icons.compare_arrows, size: 32),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comparaison de thèmes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Comparez visuellement deux thèmes côte à côte',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
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

  Widget _buildThemePreview(
      BuildContext context, BasicTheme theme, bool isLeft) {
    return Theme(
      data: theme.toThemeData(),
      child: Builder(
        builder: (themeContext) => Container(
          decoration: BoxDecoration(
            color: Theme.of(themeContext).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              bottomLeft: isLeft ? const Radius.circular(24) : Radius.zero,
              bottomRight: !isLeft ? const Radius.circular(24) : Radius.zero,
            ),
          ),
          child: Column(
            children: [
              // En-tête du thème
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor.withValues(alpha: 0.2),
                      theme.tertiaryColor.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.primaryColor, theme.tertiaryColor],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: ColorHelpers.createGlowEffect(
                          color: theme.primaryColor,
                          blurRadius: 15,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          theme.emoji ?? '🎨',
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      theme.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildColorDot(theme.primaryColor),
                        const SizedBox(width: 6),
                        _buildColorDot(theme.tertiaryColor),
                        const SizedBox(width: 6),
                        _buildColorDot(theme.neutralColor),
                      ],
                    ),
                  ],
                ),
              ),

              // Contenu de prévisualisation
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(themeContext, 'AppBar'),
                      const SizedBox(height: 8),
                      _buildAppBarPreview(themeContext, theme),
                      const SizedBox(height: 16),
                      _buildSectionTitle(themeContext, 'Cards'),
                      const SizedBox(height: 8),
                      _buildCardPreview(themeContext, theme),
                      const SizedBox(height: 16),
                      _buildSectionTitle(themeContext, 'Boutons'),
                      const SizedBox(height: 8),
                      _buildButtonsPreview(themeContext),
                      const SizedBox(height: 16),
                      _buildSectionTitle(themeContext, 'Champs de saisie'),
                      const SizedBox(height: 8),
                      _buildTextFieldPreview(themeContext, theme),
                      const SizedBox(height: 16),
                      _buildSectionTitle(themeContext, 'Chips & Tags'),
                      const SizedBox(height: 8),
                      _buildChipsPreview(themeContext, theme),
                    ],
                  ),
                ),
              ),

              // Bouton d'action
              if (isLeft ? onApplyTheme1 != null : onApplyTheme2 != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: isLeft ? onApplyTheme1 : onApplyTheme2,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Appliquer ce thème'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor:
                          ColorHelpers.getContrastColor(theme.primaryColor),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
    );
  }

  Widget _buildAppBarPreview(BuildContext context, BasicTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.menu, color: theme.primaryColor),
          const SizedBox(width: 16),
          const Expanded(child: Text('Mon Application')),
          Icon(Icons.search, color: theme.primaryColor),
        ],
      ),
    );
  }

  Widget _buildCardPreview(BuildContext context, BasicTheme theme) {
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
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Titre de carte',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Sous-titre', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Exemple de texte dans une carte avec ce thème.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonsPreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {},
          child: const Text('Elevated Button'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () {},
          child: const Text('Outlined Button'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {},
          child: const Text('Text Button'),
        ),
      ],
    );
  }

  Widget _buildTextFieldPreview(BuildContext context, BasicTheme theme) {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Champ de saisie',
        hintText: 'Tapez ici...',
        prefixIcon: Icon(Icons.edit, color: theme.primaryColor),
      ),
    );
  }

  Widget _buildChipsPreview(BuildContext context, BasicTheme theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Chip(
          label: const Text('Tag 1'),
          backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
        ),
        Chip(
          label: const Text('Tag 2'),
          backgroundColor: theme.tertiaryColor.withValues(alpha: 0.2),
        ),
        Chip(
          avatar: Icon(Icons.star, size: 16, color: theme.primaryColor),
          label: const Text('Tag 3'),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Info comparaison
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Astuce',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Comparez les couleurs, les contrastes et l\'harmonie générale',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

/// Widget pour lancer une comparaison rapide
class QuickCompareButton extends StatelessWidget {
  final BasicTheme currentTheme;
  final List<BasicTheme> availableThemes;

  const QuickCompareButton({
    super.key,
    required this.currentTheme,
    required this.availableThemes,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.compare_arrows),
      tooltip: 'Comparer avec un autre thème',
      onPressed: () => _showComparisonDialog(context),
    );
  }

  void _showComparisonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Comparer avec...',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sélectionnez un thème à comparer',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: availableThemes.length,
                  itemBuilder: (context, index) {
                    final theme = availableThemes[index];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [theme.primaryColor, theme.tertiaryColor],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(theme.emoji ?? '🎨'),
                        ),
                      ),
                      title: Text(theme.name),
                      subtitle: Text(theme.mode.name),
                      onTap: () {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (ctx) => ThemeComparison(
                            theme1: currentTheme,
                            theme2: theme,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
