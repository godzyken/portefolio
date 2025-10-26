import 'package:flutter/material.dart';

InputDecoration themedDecoration(BuildContext context,
    {required String label,
    String? hint,
    IconData? icon,
    bool alignLabelWithHint = false}) {
  final theme = Theme.of(context);
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon:
        icon != null ? Icon(icon, color: theme.colorScheme.primary) : null,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.2))),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2)),
    filled: true,
    fillColor: theme.colorScheme.surface,
    alignLabelWithHint: alignLabelWithHint,
  );
}
