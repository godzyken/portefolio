import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';

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
                ContactForm(
                  formState: formState,
                  info: info,
                  formKey: _formKey,
                ),

                // 🎯 APPEL À L'ACTION SECONDAIRE
                ContactConversionOption(info: info, theme: theme),

                // Footer avec informations complémentaires
                ContactFooter(info: info, theme: theme),
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
}
