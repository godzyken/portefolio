import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';

import '../../../../core/provider/app_providers.dart';
import '../../../about/views/screens/about_screens.dart';
import '../../model/state/contact_form_state.dart';
import '../../providers/contact_form_provider.dart';

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollCtrl = ScrollController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarTitleProvider.notifier).setTitle("Contactez-moi");
      ref.read(appBarActionsProvider.notifier).clearActions();
      ref.read(appBarDrawerProvider.notifier).setDrawer;
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _listenAndSnack(ContactFormState next) {
    if (next.status == SubmitStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Message envoyé avec succès !'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      ref.read(contactFormProvider.notifier).reset();
      _formKey.currentState?.reset();
    } else if (next.status == SubmitStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Erreur : ${next.error}')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ContactFormState>(contactFormProvider, (_, next) {
      _listenAndSnack(next);
    });

    final formState = ref.watch(contactFormProvider);
    final info = ref.watch(responsiveInfoProvider);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scrollbar(
        controller: _scrollCtrl,
        child: SingleChildScrollView(
          controller: _scrollCtrl,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ✨ SECTION ABOUT (en haut, design fluide)
              _buildAboutSection(info),

              // 🎨 SÉPARATEUR DÉCORATIF
              _buildDivider(info),

              // 📝 FORMULAIRE DE CONTACT
              _buildContactForm(formState, info),

              // Footer spacer
              SizedBox(height: info.isMobile ? 32 : 48),
            ],
          ),
        ),
      ),
    );
  }

  /// ✨ Section About intégrée avec style immersif
  Widget _buildAboutSection(ResponsiveInfo info) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.03),
          ],
        ),
      ),
      child: const AboutSection(),
    );
  }

  /// 🎨 Séparateur décoratif entre About et Contact
  Widget _buildDivider(ResponsiveInfo info) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: info.isMobile ? 32 : 48,
        horizontal: info.isMobile ? 24 : 48,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.mail_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: info.isMobile ? 24 : 32,
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: info.isMobile ? 16 : 24),
          Text(
            'Envoyez-moi un message',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Je réponds généralement sous 24h',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 📝 Formulaire de contact moderne
  Widget _buildContactForm(ContactFormState formState, ResponsiveInfo info) {
    final horizontalPadding = info.isDesktop
        ? info.size.width * 0.2
        : info.isMobile
            ? 24.0
            : 48.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Champs du formulaire avec animations
                _buildAnimatedField(
                  child: _NameField(initial: formState.name),
                  delay: 100,
                ),
                const SizedBox(height: 16),
                _buildAnimatedField(
                  child: _EmailField(initial: formState.email),
                  delay: 200,
                ),
                const SizedBox(height: 16),
                _buildAnimatedField(
                  child: _MessageField(initial: formState.message),
                  delay: 300,
                ),
                const SizedBox(height: 24),
                _buildAnimatedField(
                  child: _SubmitRow(
                    isSubmitting: formState.status == SubmitStatus.loading,
                    onEmail: () async {
                      if (_formKey.currentState!.validate()) {
                        await ref
                            .read(contactFormProvider.notifier)
                            .submit(Channel.email);
                      }
                    },
                    onWhatsApp: () async {
                      if (_formKey.currentState!.validate()) {
                        await ref
                            .read(contactFormProvider.notifier)
                            .submit(Channel.whatsapp);
                      }
                    },
                  ),
                  delay: 400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Animation d'entrée pour les champs
  Widget _buildAnimatedField({
    required Widget child,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
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
// CHAMPS DU FORMULAIRE (styles améliorés)
// ══════════════════════════════════════════════════════════════════════════════

class _NameField extends ConsumerWidget {
  final String initial;
  const _NameField({required this.initial});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      initialValue: initial,
      decoration: InputDecoration(
        labelText: 'Nom',
        hintText: 'Votre nom complet',
        prefixIcon: Icon(
          Icons.person_outline,
          color: Theme.of(context).colorScheme.primary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.name],
      onChanged: (val) =>
          ref.read(contactFormProvider.notifier).updateName(val),
      validator: (val) =>
          val == null || val.isEmpty ? 'Veuillez entrer votre nom' : null,
    );
  }
}

class _EmailField extends ConsumerWidget {
  final String initial;
  const _EmailField({required this.initial});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      initialValue: initial,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'votre.email@exemple.com',
        prefixIcon: Icon(
          Icons.email_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      onChanged: (val) =>
          ref.read(contactFormProvider.notifier).updateEmail(val),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Veuillez entrer votre email';
        }
        final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
        return emailRegex.hasMatch(val) ? null : 'Email invalide';
      },
    );
  }
}

class _MessageField extends ConsumerWidget {
  final String initial;
  const _MessageField({required this.initial});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      initialValue: initial,
      decoration: InputDecoration(
        labelText: 'Message',
        hintText: 'Décrivez votre projet ou posez votre question...',
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Icon(
            Icons.message_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        alignLabelWithHint: true,
      ),
      maxLines: 6,
      textInputAction: TextInputAction.newline,
      onChanged: (val) =>
          ref.read(contactFormProvider.notifier).updateMessage(val),
      validator: (val) =>
          val == null || val.isEmpty ? 'Veuillez écrire un message' : null,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// BOUTONS D'ENVOI (modernisés)
// ══════════════════════════════════════════════════════════════════════════════

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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isSubmitting
          ? const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Envoi en cours...'),
                ],
              ),
            )
          : Column(
              children: [
                // Bouton Email principal
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: onEmail,
                    icon: const Icon(Icons.send_rounded, size: 22),
                    label: const Text(
                      'Envoyer par Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Divider "ou"
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ou',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 12),

                // Bouton WhatsApp secondaire
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: onWhatsApp,
                    icon: const Icon(Icons.phone, size: 22),
                    label: const Text(
                      'WhatsApp',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
