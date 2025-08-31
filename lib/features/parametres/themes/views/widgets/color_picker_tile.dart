import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
      title: Text(label),
      trailing: GestureDetector(
        onTap: () async {
          final color = await showDialog<Color>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Sélectionnez $label'),
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
