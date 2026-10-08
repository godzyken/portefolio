import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:portefolio/core/ui/widgets/seo_wrapper.dart';

import '../../../../core/provider/app_providers.dart';
import '../../../about/views/screens/about_screens.dart';
import '../../model/state/contact_form_state.dart';
import '../../providers/contact_form_provider.dart';
import '../widgets/contact_extention_widgets.dart';

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>(debugLabel: 'contact_form');
  final _scrollCtrl = ScrollController();

  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  ProviderSubscription<ContactFormState>? _formSubscription;

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
      if (!mounted) return;
      _fadeController.forward();

      _formSubscription = ref.listenManual<ContactFormState>(
        contactFormProvider,
        (previous, next) => _listenAndSnack(next),
      );
    });
  }

  @override
  void dispose() {
    _formSubscription?.close();
    _scrollCtrl.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Future.microtask(() {
      if (!mounted) return;
      ref.read(appBarTitleProvider.notifier).setTitle("Contactez-moi");
      ref.read(appBarActionsProvider.notifier).clearActions();
    });
  }

  // ⚡ Snackbars pour succès / erreur
  void _listenAndSnack(ContactFormState next) {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (next.status == SubmitStatus.success) {
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
                      ResponsiveText.bodyMedium(
                        'Message envoyé !',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      ResponsiveText.bodyMedium(
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

        // ⚡ Reset formulaire après succès
        ref.read(contactFormProvider.notifier).reset();
        _formKey.currentState?.reset();

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
                Expanded(
                    child: ResponsiveText.bodyMedium('Erreur : ${next.error}')),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(contactFormProvider);
    final info = ref.watch(responsiveInfoProvider);
    final theme = Theme.of(context);
    final isWide = info.size.width > 1024;

    return SeoWrapper(
      title: 'Contact | Emryck Doré',
      description:
          'Vous avez un projet Flutter, IoT ou digital ? Contactez-moi pour en discuter.',
      url: 'https://godzyken.github.io/portefolio/contact',
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ResponsiveBox(
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
                  // 🚀 FORMULAIRE & CALENDRIER EN PRIORITÉ (aux côtés de l'avatar sur grand écran)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: info.isMobile ? 16 : 32,
                      vertical: 24,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: Icon(
                                Icons.mail_outline,
                                color: theme.colorScheme.primary,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            ResponsiveText.bodyMedium(
                              'Parlons de votre projet',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ResponsiveText.bodyMedium(
                          'Formulaire et prise de rendez-vous en ligne — Réponse sous 24h',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar et carte d'identité à gauche
                              Expanded(
                                flex: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.15),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: SizedBox(
                                          width: 180,
                                          height: 220,
                                          child: SmartImage(
                                            path:
                                                'assets/images/realisations/vignette_clip_articles_1.avif',
                                            fit: BoxFit.cover,
                                            fallbackIcon: Icons.person,
                                            fallbackColor:
                                                theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      ResponsiveText.titleLarge(
                                        'Emryck Doré',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      ResponsiveText.bodyMedium(
                                        'Architecte Flutter & Consultant AMOA',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      ResponsiveText.bodySmall(
                                        'Disponible pour vos projets d’applications mobiles, web, IoT et le pilotage de vos projets digitaux.',
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.8),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 32),
                              // Formulaire + Calendrier à droite (accessibles immédiatement sans scroll)
                              Expanded(
                                flex: 8,
                                child: Column(
                                  children: [
                                    ContactForm(
                                      formState: formState,
                                      info: info,
                                      formKey: _formKey,
                                    ),
                                    const SizedBox(height: 24),
                                    ContactConversionOption(
                                        info: info, theme: theme),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              ContactForm(
                                formState: formState,
                                info: info,
                                formKey: _formKey,
                              ),
                              const SizedBox(height: 24),
                              ContactConversionOption(info: info, theme: theme),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // ✨ SECTION ABOUT (complète en dessous)
                  _buildAboutSection(info, theme),

                  // Footer avec informations complémentaires
                  ContactFooter(info: info, theme: theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ✨ Section About avec effet glassmorphism
  Widget _buildAboutSection(ResponsiveInfo info, ThemeData theme) {
    return ResponsiveBox(
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
}
