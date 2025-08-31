import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controller/theme_controller.dart';
import '../../theme/theme_data.dart';
import 'color_picker_tile.dart';

class ThemeEditorDialog extends ConsumerStatefulWidget {
  const ThemeEditorDialog(this.theme, this.name, this.emoji, {super.key});
  final BasicTheme? theme;
  final String? name;
  final String? emoji;

  @override
  ConsumerState<ThemeEditorDialog> createState() => _ThemeEditorDialogState();
}

class _ThemeEditorDialogState extends ConsumerState<ThemeEditorDialog> {
  Color primary = const Color(0xFF356859);
  Color tertiary = const Color(0xff8a776d);
  Color neutral = const Color(0xFF7ECA64);
  late TextEditingController _nameController;
  String emoji = '🎨';

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.name ?? widget.theme?.name ?? '');
    if (widget.theme != null) {
      primary = Color(widget.theme!.primaryColorValue);
      tertiary = Color(widget.theme!.tertiaryColorValue);
      neutral = Color(widget.theme!.neutralColorValue);
    }
    emoji = widget.theme?.name ?? '🎨';
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(themeControllerProvider.notifier);

    return AlertDialog(
      title: const Text("Créer un thème personnalisé"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Nom du thème",
            ),
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            items: ['🎨', '🧀', '🌈', '🧠', '🚀', '🍕'].map((e) {
              return DropdownMenuItem(value: e, child: Text(e));
            }).toList(),
            onChanged: (e) => setState(() => emoji = e!),
          ),
          const SizedBox(height: 8),
          ColorPickerTile(
            label: "Couleur principale",
            initial: primary,
            onChanged: (c) => setState(() => primary = c),
          ),
          ColorPickerTile(
            label: "Tertiaire",
            initial: tertiary,
            onChanged: (c) => setState(() => tertiary = c),
          ),
          ColorPickerTile(
            label: "Neutre (surface)",
            initial: neutral,
            onChanged: (c) => setState(() => neutral = c),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: () {
            notifier.applyTheme(
              BasicTheme(
                primaryColorValue: primary.toARGB32(),
                tertiaryColorValue: tertiary.toARGB32(),
                neutralColorValue: neutral.toARGB32(),
                mode: AppThemeMode.custom,
                name: "Custom",
              ),
            );
            Navigator.pop(context);
          },
          child: const Text("Appliquer"),
        ),
      ],
    );
  }
}
