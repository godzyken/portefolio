import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

class ColorPickerTile extends StatelessWidget {
  final String label;
  final Color initial;
  final ValueChanged<Color> onChanged;

  const ColorPickerTile({
    super.key,
    required this.label,
    required this.initial,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: ResponsiveText.bodySmall(label),
      trailing: GestureDetector(
        onTap: () async {
          final color = await showDialog<Color>(
            context: context,
            builder: (context) => AlertDialog(
              title: ResponsiveText.displayMedium('Sélectionnez $label'),
              content: SingleChildScrollView(
                child: BlockPicker(
                  pickerColor: initial,
                  onColorChanged: onChanged,
                ),
              ),
            ),
          );
          if (color != null) onChanged(color);
        },
        child: CircleAvatar(backgroundColor: initial),
      ),
    );
  }
}
