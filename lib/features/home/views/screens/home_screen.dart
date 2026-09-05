import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:portefolio/features/parametres/themes/views/widgets/space_background.dart';

import '../../../../core/provider/business_plan_provider.dart';
import '../../../diagnostic/views/widgets/diagnostic_teaser_banner.dart';
import '../../../generator/views/generator_widgets_extentions.dart';
import '../widgets/client_journey_timeline.dart';
import '../widgets/extentions_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(responsiveInfoProvider);
    final theme = Theme.of(context);

    return SpaceBackground(
      primaryColor: theme.colorScheme.primary,
      secondaryColor: theme.colorScheme.secondary,
      starCount: 150,
      child: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(builder: (context, constraints) {
              return info.isPortrait
                  ? _buildPortraitLayout(context, info, theme)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48, vertical: 32),
                      child: _buildLandscapeLayout(context, info, theme),
                    );
            }),
            Positioned(
              right: 24,
              bottom: 24,
              child: FloatingActionButton.extended(
                onPressed: () => context.go('/avatar'),
                backgroundColor: ColorHelpers.cyan,
                foregroundColor: Colors.black,
                icon: const Icon(Icons.psychology),
                label: const Text("Besoin d'aide ?",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ).animate().scale(
                  delay: const Duration(seconds: 2),
                  duration: const Duration(milliseconds: 500)),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Portrait Layout ----------
  Widget _buildPortraitLayout(
      BuildContext context, ResponsiveInfo info, ThemeData theme) {
    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: info.size.height * 2,
              child: const Opacity(
                opacity: 0.5,
                child: CharacterViewer(),
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: info.isMobile ? 24 : 48,
            vertical: 32,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildPresentationText(context, theme, info.isMobile),
              const SizedBox(height: 32),
              _buildActionButtons(context, theme, info.isMobile),
              SizedBox(height: info.isMobile ? 32 : 48),
              const BusinessStorySection(),
              SizedBox(height: info.isMobile ? 32 : 48),
              const AnimatedStatsSection(),
              SizedBox(height: info.isMobile ? 32 : 48),
              const ClientJourneyTimeline(),
              SizedBox(height: info.isMobile ? 32 : 48),
              const DiagnosticTeaserBanner(),
              SizedBox(height: info.isMobile ? 16 : 32),
              const ServicesSection(),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- Landscape Layout ----------
  Widget _buildLandscapeLayout(
      BuildContext context, ResponsiveInfo info, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: _buildProfileImage(context, info, theme),
                    ),
                    const SizedBox(height: 16),
                    _buildPresentationText(context, theme, info.isMobile),
                    const SizedBox(height: 32),
                    _buildActionButtons(context, theme, info.isMobile),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              const Expanded(
                flex: 3,
                child: CharacterViewer(),
              ),
              const SizedBox(width: 32),
              const Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DiagnosticTeaserBanner(),
                    SizedBox(height: 24),
                    ServicesSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: const BusinessStorySection(),
          ),
        ),
        const SizedBox(height: 48),
        const AnimatedStatsSection(),
        const SizedBox(height: 48),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: const ClientJourneyTimeline(),
          ),
        ),
      ],
    );
  }

  // ---------- Profile Image ----------
  Widget _buildProfileImage(
      BuildContext context, ResponsiveInfo info, ThemeData theme) {
    return Hero(
      tag: 'profile_image',
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
              blurRadius: 40,
              spreadRadius: 10,
            ),
            BoxShadow(
              color: theme.colorScheme.secondary.withValues(alpha: 0.3),
              blurRadius: 60,
              spreadRadius: 15,
            ),
          ],
        ),
        child: ClipOval(
          child: SmartImage(
            path: 'assets/images/pers_do_am.png',
            fit: BoxFit.cover,
            fallbackIcon: Icons.person,
            fallbackColor: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  // ---------- Presentation Text ----------
  Widget _buildPresentationText(
      BuildContext context, ThemeData theme, bool isMobile) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ResponsiveText.titleLarge(
          'Emryck Doré',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        SizedBox(height: 12),
        ResponsiveText.headlineSmall(
          'Développeur Flutter & Architecte Logiciel',
          style: TextStyle(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        _HeroDescription(),
      ],
    );
  }

  // ---------- Action Buttons ----------
  Widget _buildActionButtons(
      BuildContext context, ThemeData theme, bool isMobile) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        ResponsiveButton.icon(
          onPressed: () => context.go('/projects'),
          icon: const Icon(Icons.work_outline),
          label: 'Voir mes projets',
          style: _btnStyle(theme, isMobile),
        ),
        ResponsiveButton.icon(
          onPressed: () => context.go('/avatar'),
          icon: const Icon(Icons.psychology_outlined, color: ColorHelpers.cyan),
          label: 'Parler à mon Avatar',
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 32,
              vertical: isMobile ? 16 : 20,
            ),
            side: const BorderSide(color: ColorHelpers.cyan, width: 2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        ResponsiveButton.icon(
          onPressed: () => context.go('/contact'),
          icon: Icon(
            Icons.mail_outline,
            color: theme.colorScheme.surfaceContainerHigh,
          ),
          label: 'Me contacter',
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 32,
              vertical: isMobile ? 16 : 20,
            ),
            side: BorderSide(color: theme.colorScheme.primary, width: 2),
            shadowColor: theme.colorScheme.secondary.withValues(alpha: 0.5),
            foregroundColor: theme.colorScheme.onSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Button Style ----------
  ButtonStyle _btnStyle(ThemeData theme, bool isMobile) {
    return ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 32,
        vertical: isMobile ? 16 : 20,
      ),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 8,
      shadowColor: theme.colorScheme.primary.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

/// Description du hero, pilotée par `business_plan.json` (executiveSummary),
/// avec un texte de repli identique tant que le JSON n'est pas chargé.
class _HeroDescription extends ConsumerWidget {
  const _HeroDescription();

  static const _fallback =
      'Expert en développement mobile cross-platform et solutions digitales. '
      'Spécialisé dans la création d\'applications Flutter performantes, '
      'l\'architecture logicielle et la transformation digitale des entreprises.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final plan = ref.watch(businessPlanProvider).asData?.value;

    return ResponsiveText.bodyMedium(
      plan?.executiveSummary.content ?? _fallback,
      maxLines: 5,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(
          height: 1.5,
          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8)),
    );
  }
}
