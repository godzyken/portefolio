import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NameFormField extends ConsumerWidget {
  final String? initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final String labelText;
  final String hintText;

  const NameFormField({
    super.key,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.validator,
    this.labelText = 'Nom complet',
    this.hintText = 'Jean Dupont',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return TextFormField(
      initialValue: controller == null ? initialValue : null,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon:
            Icon(Icons.person_outline, color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.name],
      onChanged: onChanged,
      validator:
          validator ?? (val) => val == null || val.isEmpty ? 'Requis' : null,
    );
  }
}

class EmailFormField extends ConsumerWidget {
  final String? initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final String labelText;
  final String hintText;

  const EmailFormField({
    super.key,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.validator,
    this.labelText = 'Email',
    this.hintText = 'contact@exemple.com',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return TextFormField(
      initialValue: controller == null ? initialValue : null,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon:
            Icon(Icons.alternate_email, color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      onChanged: onChanged,
      validator: validator ?? _defaultEmailValidator,
    );
  }

  static String? _defaultEmailValidator(String? val) {
    if (val == null || val.isEmpty) return 'L\'email est requis';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) {
      return 'Format d\'email invalide';
    }
    return null;
  }
}

class MessageFormField extends ConsumerWidget {
  final String? initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final String labelText;
  final String hintText;
  final int maxLines;

  const MessageFormField({
    super.key,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.validator,
    this.labelText = 'Message',
    this.hintText = 'Décrivez votre projet...',
    this.maxLines = 3,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return TextFormField(
      initialValue: controller == null ? initialValue : null,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: (maxLines * 20.0)),
          child:
              Icon(Icons.chat_bubble_outline, color: theme.colorScheme.primary),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        alignLabelWithHint: true,
      ),
      maxLines: maxLines,
      textInputAction: TextInputAction.newline,
      onChanged: onChanged,
      validator:
          validator ?? (val) => val == null || val.isEmpty ? 'Requis' : null,
    );
  }
}
