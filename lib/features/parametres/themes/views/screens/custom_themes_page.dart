import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controller/theme_controller.dart';
import '../../provider/custom_themes_provider.dart';
import '../widgets/theme_editor_diaog.dart';

class CustomThemesPage extends ConsumerWidget {
  const CustomThemesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customThemes = ref.watch(customThemesProvider);
    final themeNotifier = ref.read(themeControllerProvider.notifier);
    final customNotifier = ref.read(customThemesProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text("Thèmes personnalisés")),
      body: customThemes.isEmpty
          ? const Center(child: Text("Aucun thème personnalisé."))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, _) => const Divider(),
              itemCount: customThemes.length,
              itemBuilder: (_, i) {
                final theme = customThemes[i];
                return ListTile(
                  leading: Text(
                    theme.emoji ?? "🎨",
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(theme.name),
                  subtitle: Row(
                    children: [
                      _buildColorCircle(theme.primaryColor),
                      _buildColorCircle(theme.tertiaryColor),
                      _buildColorCircle(theme.neutralColor),
                    ],
                  ),
                  trailing: SizedBox.shrink(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: "Appliquer ce thème",
                          icon: const Icon(Icons.check_circle_outline),
                          onPressed: () => themeNotifier.applyTheme(theme),
                        ),
                        IconButton(
                          tooltip: "Modifier",
                          icon: const Icon(Icons.edit),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => ThemeEditorDialog(
                              theme,
                              theme.name,
                              theme.emoji,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: "Supprimer",
                          icon: const Icon(Icons.delete),
                          onPressed: () => customNotifier.deleteTheme(i),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const ThemeEditorDialog(null, null, null),
        ),
        label: const Text("Nouveau thème"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildColorCircle(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: CircleAvatar(radius: 10, backgroundColor: color),
    );
  }
}
