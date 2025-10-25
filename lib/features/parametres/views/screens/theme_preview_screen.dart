import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        title: const Text('Galerie de Thèmes'),
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
          SizedBox(
            width: 280,
            child: ListView.builder(
              itemCount: availableThemes.length,
              itemBuilder: (context, index) {
                final theme = availableThemes[index];
                final isSelected = selectedIndex == index;
                final isCurrent =
                    theme.primaryColorValue == currentTheme.primaryColorValue;

                return Container(
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
                    leading: Container(
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
                        child: Text(
                          theme.emoji ?? '🎨',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    title: Text(
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
                        const SizedBox(width: 8),
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
            Text(
              'Prévisualisation',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              theme.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: theme.primaryColor,
                  ),
            ),
            const SizedBox(height: 32),

            // Cards preview
            Text(
              'Cards',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
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
                          const SizedBox(height: 8),
                          Text(
                            'Développement',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Applications modernes et performantes',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
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
                          const SizedBox(height: 8),
                          Text(
                            'Design',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
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
            const SizedBox(height: 32),

            // Buttons preview
            Text(
              'Boutons',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.save),
                  label: const Text('Enregistrer'),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.send),
                  label: const Text('Envoyer'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.cancel),
                  label: const Text('Annuler'),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.info),
                  label: const Text('Plus d\'infos'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Input preview
            Text(
              'Champs de saisie',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Nom',
                hintText: 'Entrez votre nom',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'exemple@email.com',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 32),

            // Chips preview
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: const Text('Flutter'),
                  avatar: const Icon(Icons.flutter_dash, size: 18),
                ),
                Chip(
                  label: const Text('React'),
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
                ),
                Chip(
                  label: const Text('Node.js'),
                  onDeleted: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Color palette
            Text(
              'Palette de couleurs',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildColorCard('Primary', theme.primaryColor),
                const SizedBox(width: 16),
                _buildColorCard('Tertiary', theme.tertiaryColor),
                const SizedBox(width: 16),
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
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorDot(Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
      ),
    );
  }
}
