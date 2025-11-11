import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/widgets/smart_image.dart';
import 'package:portefolio/features/parametres/themes/views/widgets/space_background.dart';

import '../../../../core/ui/widgets/responsive_text.dart';
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isPortrait = info.isPortrait;
            final isMobile = info.isMobile;

            return SingleChildScrollView(
              child: isPortrait
                  ? _buildPortraitLayout(context, info, theme, isMobile)
                  : _buildLandscapeLayout(context, info, theme),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    ResponsiveInfo info,
    ThemeData theme,
    bool isMobile,
  ) {
    return ResponsiveBox(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image de profil
          _buildProfileImage(context, info, theme),

          const ResponsiveBox(paddingSize: ResponsiveSpacing.m),

          // Texte de présentation
          _buildPresentationText(context, theme, isMobile),

          const ResponsiveBox(paddingSize: ResponsiveSpacing.m),

          // Boutons d'action
          _buildActionButtons(context, theme, isMobile),

          const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
          ServicesSection(),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    ResponsiveInfo info,
    ThemeData theme,
  ) {
    return ResponsiveBox(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image à gauche
              Flexible(
                flex: 4,
                child: _buildProfileImage(context, info, theme),
              ),

              const ResponsiveBox(paddingSize: ResponsiveSpacing.m),

              // Contenu à droite
              Flexible(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPresentationText(context, theme, false),
                    const SizedBox(height: 40),
                    _buildActionButtons(context, theme, false),
                  ],
                ),
              ),
            ],
          ),
          const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
          const ServicesSection(),
        ],
      ),
    );
  }

  Widget _buildProfileImage(
    BuildContext context,
    ResponsiveInfo info,
    ThemeData theme,
  ) {
    final imageSize = info.isMobile
        ? info.size.width * 0.7
        : info.isPortrait
            ? info.size.width * 0.5
            : info.size.height * 0.7;

    return Hero(
      tag: 'profile_image',
      child: ResponsiveBox(
        width: imageSize,
        height: imageSize,
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
            path: 'assets/images/pers_do.png',
            fit: BoxFit.cover,
            fallbackIcon: Icons.person,
            fallbackColor: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildPresentationText(
    BuildContext context,
    ThemeData theme,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Nom
        const ResponsiveText.displayLarge(
          'Emryck Doré',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        // Titre
        ResponsiveBox(
          paddingSize: ResponsiveSpacing.m,
          child: const ResponsiveText.titleLarge(
            'Développeur Flutter & Architecte Logiciel',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        // Description
        const ResponsiveText.bodyLarge(
          'Expert en développement mobile cross-platform et solutions digitales. '
          'Spécialisé dans la création d\'applications Flutter performantes, '
          'l\'architecture logicielle et la transformation digitale des entreprises.',
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ThemeData theme,
    bool isMobile,
  ) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
      children: [
        // Bouton Projets
        ElevatedButton.icon(
          onPressed: () => context.go('/projects'),
          icon: const Icon(Icons.work_outline),
          label: const ResponsiveText.bodyMedium('Voir mes projets'),
          style: ElevatedButton.styleFrom(
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
          ),
        ),

        // Bouton Contact
        OutlinedButton.icon(
          onPressed: () => context.go('/contact'),
          icon: const Icon(Icons.mail_outline),
          label: const ResponsiveText.bodyMedium('Me contacter'),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 32,
              vertical: isMobile ? 16 : 20,
            ),
            side: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
            foregroundColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}
