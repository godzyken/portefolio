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
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollCtrl = ScrollController();

  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Animation de fade-in global
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Animation de pulsation pour l'icône mail
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarTitleProvider.notifier).setTitle("Contactez-moi");
      ref.read(appBarActionsProvider.notifier).clearActions();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _listenAndSnack(ContactFormState next) {
    if (next.status == SubmitStatus.success) {
      // ✨ Animation de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.white),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Message envoyé !',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Je vous répondrai sous 24h',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
      ref.read(contactFormProvider.notifier).reset();
      _formKey.currentState?.reset();

      // Scroll vers le haut après succès
      _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
      );
    } else if (next.status == SubmitStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(child: Text('Erreur : ${next.error}')),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
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
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withValues(alpha: 0.95),
            ],
          ),
        ),
        child: Scrollbar(
          controller: _scrollCtrl,
          child: SingleChildScrollView(
            controller: _scrollCtrl,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ✨ SECTION ABOUT (en haut)
                _buildAboutSection(info, theme),

                // 🎨 SÉPARATEUR ANIMÉ
                _buildAnimatedDivider(info, theme),

                // 📝 FORMULAIRE DE CONTACT
                _buildContactForm(formState, info, theme),

                // 🎯 APPEL À L'ACTION SECONDAIRE
                _buildSecondaryCallToAction(info, theme),

                // Footer avec informations complémentaires
                _buildFooter(info, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ✨ Section About avec effet glassmorphism
  Widget _buildAboutSection(ResponsiveInfo info, ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.05),
            theme.colorScheme.secondary.withValues(alpha: 0.03),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: const AboutSection(),
    );
  }

  /// 🎨 Séparateur animé avec icône pulsante
  Widget _buildAnimatedDivider(ResponsiveInfo info, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: info.isMobile ? 40 : 64,
        horizontal: info.isMobile ? 24 : 48,
      ),
      child: Column(
        children: [
          // Ligne décorative avec icône au centre
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        theme.colorScheme.primary.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mail_outline,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: info.isMobile ? 24 : 32),

          // Titre principal
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
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
            child: Column(
              children: [
                Text(
                  'Parlons de votre projet',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ).createShader(const Rect.fromLTWH(0, 0, 300, 70)),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Je réponds généralement sous 24 heures',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📝 Formulaire de contact ultra-moderne
  Widget _buildContactForm(
    ContactFormState formState,
    ResponsiveInfo info,
    ThemeData theme,
  ) {
    final horizontalPadding = info.isDesktop
        ? info.size.width * 0.25
        : info.isMobile
            ? 24.0
            : 64.0;

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
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFieldWithAnimation(
                  delay: 100,
                  child: _NameField(initial: formState.name),
                ),
                const SizedBox(height: 20),
                _buildFieldWithAnimation(
                  delay: 200,
                  child: _EmailField(initial: formState.email),
                ),
                const SizedBox(height: 20),
                _buildFieldWithAnimation(
                  delay: 300,
                  child: _MessageField(initial: formState.message),
                ),
                const SizedBox(height: 32),
                _buildFieldWithAnimation(
                  delay: 400,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🎯 Appel à l'action secondaire
  Widget _buildSecondaryCallToAction(ResponsiveInfo info, ThemeData theme) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: info.isMobile ? 24 : 64,
        vertical: 32,
      ),
      padding: EdgeInsets.all(info.isMobile ? 24 : 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Vous avez une idée de projet ?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Discutons-en autour d\'un café virtuel ou réel',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildActionChip(
                theme,
                Icons.calendar_today,
                'Réserver un créneau',
                () {
                  // TODO: Intégrer Calendly ou autre
                },
              ),
              _buildActionChip(
                theme,
                Icons.download,
                'Télécharger mon CV',
                () {
                  // TODO: Télécharger CV
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(
    ThemeData theme,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Footer informatif
  Widget _buildFooter(ResponsiveInfo info, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(info.isMobile ? 24 : 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            theme.colorScheme.surface.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            '🚀 Prêt à transformer votre idée en réalité ?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildFooterInfo(theme, Icons.schedule, 'Réponse sous 24h'),
              _buildFooterInfo(theme, Icons.lock, 'Confidentialité garantie'),
              _buildFooterInfo(theme, Icons.verified, 'Devis gratuit'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterInfo(ThemeData theme, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
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
  const _NameField({required this.initial});

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
      onChanged: (val) =>
          ref.read(contactFormProvider.notifier).updateName(val),
      validator: (val) => val == null || val.isEmpty ? 'Requis' : null,
    );
  }
}

class _EmailField extends ConsumerWidget {
  final String initial;
  const _EmailField({required this.initial});

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
      onChanged: (val) =>
          ref.read(contactFormProvider.notifier).updateEmail(val),
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
  const _MessageField({required this.initial});

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
      onChanged: (val) =>
          ref.read(contactFormProvider.notifier).updateMessage(val),
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
