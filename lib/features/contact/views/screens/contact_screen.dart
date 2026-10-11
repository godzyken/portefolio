import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:portefolio/core/ui/widgets/seo_wrapper.dart';
import 'package:portefolio/features/about/views/screens/about_screens.dart';
import 'package:portefolio/resources/resources.dart';

import '../../../../core/provider/app_providers.dart';
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
                              // Côté gauche : Formulaire de contact & Calendrier
                              Expanded(
                                flex: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                              ),
                              const SizedBox(width: 24),
                              // Côté droit : Avatar Hero + About, Skills, Analytics
                              Expanded(
                                flex: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildProfileImage(context, theme, info),
                                      const SizedBox(height: 20),
                                      const AboutSection(),
                                    ],
                                  ),
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
                              const SizedBox(height: 32),
                              // ✨ SECTION ABOUT (complète en dessous sur mobile)
                              _buildAboutSection(info, theme),
                            ],
                          ),
                      ],
                    ),
                  ),

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

  /// ✨ Image de profil avec cadre lumineux hero
  Widget _buildProfileImage(
    BuildContext context,
    ThemeData theme,
    ResponsiveInfo info,
  ) {
    const imageWidth = 140.0;
    const imageHeight = 180.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.3),
            theme.colorScheme.secondary.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 25,
            spreadRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: imageWidth,
          height: imageHeight,
          child: SmartImage(
            path: Images.mePortrait2,
            fit: BoxFit.cover,
            fallbackIcon: Icons.person,
            fallbackColor: theme.colorScheme.primary,
            enableShimmer: true,
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
