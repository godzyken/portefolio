import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../model/state/contact_form_state.dart';
import '../../providers/contact_form_provider.dart';

class ContactForm extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final ContactFormState formState;
  final ResponsiveInfo info;

  const ContactForm({
    super.key,
    required this.formKey,
    required this.formState,
    required this.info,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final horizontalPadding = info.isDesktop
        ? info.size.width * 0.25
        : info.isMobile
            ? 24.0
            : 64.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 32,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        padding: EdgeInsets.all(info.isMobile ? 24 : 40),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 30,
              spreadRadius: 10,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: _buildContactForm(formState, info, theme, ref),
      ),
    );
  }

  /// 📝 Formulaire de contact ultra-moderne
  Widget _buildContactForm(
    ContactFormState formState,
    ResponsiveInfo info,
    ThemeData theme,
    WidgetRef ref,
  ) {
    final horizontalPadding = info.isDesktop
        ? info.size.width * 0.25
        : info.isMobile
            ? 24.0
            : 64.0;

    final notifier = ref.read(contactFormProvider.notifier);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 32,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        padding: EdgeInsets.all(info.isMobile ? 24 : 40),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 30,
              spreadRadius: 10,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFieldWithAnimation(
                  delay: 100,
                  child: _NameField(
                      initial: formState.name, onChanged: notifier.updateName),
                ),
                const SizedBox(height: 20),
                _buildFieldWithAnimation(
                  delay: 200,
                  child: _EmailField(
                      initial: formState.email,
                      onChanged: notifier.updateEmail),
                ),
                const SizedBox(height: 20),
                _buildFieldWithAnimation(
                  delay: 300,
                  child: _MessageField(
                      initial: formState.message,
                      onChanged: notifier.updateMessage),
                ),
                const SizedBox(height: 32),
                _buildFieldWithAnimation(
                  delay: 400,
                  child: _SubmitRow(
                    isSubmitting: formState.status == SubmitStatus.loading,
                    onEmail: () async {
                      if (formKey.currentState!.validate()) {
                        await notifier.submit(Channel.email);
                      }
                    },
                    onWhatsApp: () async {
                      if (formKey.currentState!.validate()) {
                        await notifier.submit(Channel.whatsapp);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper pour animer les champs
  Widget _buildFieldWithAnimation({
    required int delay,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CHAMPS DU FORMULAIRE (styles premium)
// ══════════════════════════════════════════════════════════════════════════════

class _NameField extends ConsumerWidget {
  final String initial;
  final ValueChanged<String> onChanged;

  const _NameField({required this.initial, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return TextFormField(
      initialValue: initial,
      decoration: InputDecoration(
        labelText: 'Nom complet',
        hintText: 'Jean Dupont',
        prefixIcon:
            Icon(Icons.person_outline, color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.name],
      onChanged: onChanged,
      validator: (val) => val == null || val.isEmpty ? 'Requis' : null,
    );
  }
}

class _EmailField extends ConsumerWidget {
  final String initial;
  final ValueChanged<String> onChanged;
  const _EmailField({required this.initial, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return TextFormField(
      initialValue: initial,
      decoration: InputDecoration(
        labelText: 'Email professionnel',
        hintText: 'contact@entreprise.com',
        prefixIcon:
            Icon(Icons.alternate_email, color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      onChanged: onChanged,
      validator: (val) {
        if (val == null || val.isEmpty) return 'Requis';
        if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(val))
          return 'Email invalide';
        return null;
      },
    );
  }
}

class _MessageField extends ConsumerWidget {
  final String initial;
  final ValueChanged<String> onChanged;
  const _MessageField({required this.initial, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return TextFormField(
      initialValue: initial,
      decoration: InputDecoration(
        labelText: 'Votre message',
        hintText: 'Décrivez votre projet en quelques lignes...',
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 120),
          child:
              Icon(Icons.chat_bubble_outline, color: theme.colorScheme.primary),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        alignLabelWithHint: true,
      ),
      maxLines: 6,
      textInputAction: TextInputAction.newline,
      onChanged: onChanged,
      validator: (val) => val == null || val.isEmpty ? 'Requis' : null,
    );
  }
}

class _SubmitRow extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onEmail;
  final VoidCallback onWhatsApp;

  const _SubmitRow({
    required this.isSubmitting,
    required this.onEmail,
    required this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: isSubmitting
          ? Container(
              key: const ValueKey('loading'),
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  CircularProgressIndicator(color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Envoi en cours...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              key: const ValueKey('actions'),
              children: [
                // Bouton Email (principal)
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: onEmail,
                    icon: const Icon(Icons.send_rounded, size: 24),
                    label: const Text(
                      'Envoyer par Email',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor:
                          theme.colorScheme.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Séparateur
                Row(
                  children: [
                    Expanded(
                        child: Divider(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.2))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ou contactez-moi via',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    Expanded(
                        child: Divider(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.2))),
                  ],
                ),

                const SizedBox(height: 16),

                // Bouton WhatsApp
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: onWhatsApp,
                    icon: const Icon(Icons.phone, size: 22),
                    label: const Text(
                      'WhatsApp',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
