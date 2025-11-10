/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

import '../../themes/controller/theme_controller.dart';
import '../../themes/theme/theme_data.dart';

class ThemePreviewScreen extends ConsumerStatefulWidget {
  const ThemePreviewScreen({super.key});

  @override
  ConsumerState<ThemePreviewScreen> createState() => _ThemePreviewScreenState();
}

class _ThemePreviewScreenState extends ConsumerState<ThemePreviewScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveText('Galerie de Thèmes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Appliquer le thème sélectionné',
            onPressed: () {
              controller.applyTheme(availableThemes[selectedIndex]);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Liste des thèmes à gauche
          ResponsiveBox(
            width: 280,
            child: ListView.builder(
              itemCount: availableThemes.length,
              itemBuilder: (context, index) {
                final theme = availableThemes[index];
                final isSelected = selectedIndex == index;
                final isCurrent =
                    theme.primaryColorValue == currentTheme.primaryColorValue;

                return ResponsiveBox(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.primaryColor.withValues(alpha: 0.1)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected ? theme.primaryColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    leading: ResponsiveBox(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      theme.primaryColor.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: ResponsiveText.bodySmall(
                          theme.emoji ?? '🎨',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    title: ResponsiveText(
                      theme.name,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        _colorDot(Color(theme.primaryColorValue)),
                        _colorDot(Color(theme.tertiaryColorValue)),
                        _colorDot(Color(theme.neutralColorValue)),
                        const ResponsiveBox(
                          paddingSize: ResponsiveSpacing.m,
                        ),
                        if (isCurrent)
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          ),
                      ],
                    ),
                    onTap: () => setState(() => selectedIndex = index),
                  ),
                );
              },
            ),
          ),

          // Prévisualisation à droite
          Expanded(
            child: Theme(
              data: availableThemes[selectedIndex].toThemeData(),
              child: _buildPreview(availableThemes[selectedIndex]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(BasicTheme theme) {
    return Container(
      color: theme.neutralColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            ResponsiveText(
              'Prévisualisation',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const ResponsiveBox(
              paddingSize: ResponsiveSpacing.s,
            ),
            ResponsiveText(
              theme.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: theme.primaryColor,
                  ),
            ),
            const ResponsiveBox(
              paddingSize: ResponsiveSpacing.xl,
            ),

            // Cards preview
            ResponsiveText(
              'Cards',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const ResponsiveBox(
              paddingSize: ResponsiveSpacing.m,
            ),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.code,
                            size: 32,
                            color: theme.primaryColor,
                          ),
                          const ResponsiveBox(
                            paddingSize: ResponsiveSpacing.s,
                          ),
                          ResponsiveText(
                            'Développement',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const ResponsiveBox(
                            paddingSize: ResponsiveSpacing.xs,
                          ),
                          ResponsiveText(
                            'Applications modernes et performantes',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const ResponsiveBox(
                  paddingSize: ResponsiveSpacing.m,
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.design_services,
                            size: 32,
                            color: theme.primaryColor,
                          ),
                          const ResponsiveBox(
                            paddingSize: ResponsiveSpacing.m,
                          ),
                          ResponsiveText(
                            'Design',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const ResponsiveBox(
                            paddingSize: ResponsiveSpacing.xs,
                          ),
                          ResponsiveText(
                            'Interfaces élégantes et intuitives',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const ResponsiveBox(
              paddingSize: ResponsiveSpacing.xl,
            ),

            // Buttons preview
            ResponsiveText(
              'Boutons',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const ResponsiveBox(
              paddingSize: ResponsiveSpacing.m,
            ),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.save),
                  label: const ResponsiveText('Enregistrer'),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.send),
                  label: const ResponsiveText('Envoyer'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.cancel),
                  label: const ResponsiveText('Annuler'),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.info),
                  label: const ResponsiveText('Plus d\'infos'),
                ),
              ],
            ),
            const ResponsiveBox(
              paddingSize: ResponsiveSpacing.l,
            ),

            // Input preview
            ResponsiveText(
              'Champs de saisie',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const ResponsiveBox(
              paddingSize: ResponsiveSpacing.m,
            ),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Nom',
                hintText: 'Entrez votre nom',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const ResponsiveBox(
              paddingSize: ResponsiveSpacing.m,
            ),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'exemple@email.com',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const ResponsiveBox(
              paddingSize: ResponsiveSpacing.l,
            ),
            // Chips preview
            ResponsiveText(
              'Tags',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const ResponsiveBox(
              paddingSize: ResponsiveSpacing.m,
            ),

            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: const ResponsiveText('Flutter'),
                  avatar: const Icon(Icons.flutter_dash, size: 18),
                ),
                Chip(
                  label: const ResponsiveText('React'),
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
                ),
                Chip(
                  label: const ResponsiveText('Node.js'),
                  onDeleted: () {},
                ),
              ],
            ),
            const ResponsiveBox(
              paddingSize: ResponsiveSpacing.l,
            ),
            // Color palette
            ResponsiveText(
              'Palette de couleurs',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const ResponsiveBox(
              paddingSize: ResponsiveSpacing.m,
            ),
            Row(
              children: [
                _buildColorCard('Primary', theme.primaryColor),
                const ResponsiveBox(
                  paddingSize: ResponsiveSpacing.m,
                ),
                _buildColorCard('Tertiary', theme.tertiaryColor),
                const ResponsiveBox(
                  paddingSize: ResponsiveSpacing.m,
                ),
                _buildColorCard('Neutral', theme.neutralColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorCard(String label, Color color) {
    return Expanded(
      child: ResponsiveBox(
        paddingSize: ResponsiveSpacing.m,
        marginSize: ResponsiveSpacing.m,
        child: Column(
          children: [
            ResponsiveBox(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const ResponsiveBox(
              paddingSize: ResponsiveSpacing.s,
            ),
            ResponsiveText(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            ResponsiveText(
              '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
              style: TextStyle(
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorDot(Color color) {
    return ResponsiveBox(
      paddingSize: ResponsiveSpacing.xs,
      marginSize: ResponsiveSpacing.xs,
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
    );
  }
}
*/
