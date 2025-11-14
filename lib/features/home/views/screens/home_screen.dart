import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/widgets/smart_image.dart';
import 'package:portefolio/features/parametres/themes/views/widgets/space_background.dart';

import '../../../../core/ui/widgets/responsive_text.dart';
import '../../../generator/views/generator_widgets_extentions.dart';
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
        child: LayoutBuilder(builder: (context, constraints) {
          final size = constraints.biggest;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: info.isMobile ? 24 : 48,
              vertical: 16,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height,
              ),
              child: info.isPortrait
                  ? _buildPortraitLayout(context, info, theme)
                  : _buildLandscapeLayout(context, info, theme),
            ),
          );
        }),
      ),
    );
  }

  // ---------- Portrait ----------
  Widget _buildPortraitLayout(
      BuildContext context, ResponsiveInfo info, ThemeData theme) {
    final imageSize =
        info.isMobile ? info.size.width * 0.7 : info.size.width * 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: imageSize,
          height: imageSize,
          child: _buildProfileImage(context, info, theme),
        ),
        const SizedBox(height: 24),
        _buildPresentationText(context, theme, info.isMobile),
        const SizedBox(height: 24),
        _buildActionButtons(context, theme, info.isMobile),
        const SizedBox(height: 24),

        // Toujours scrollable si contenu long
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            ComparisonStatsView(),
            SizedBox(height: 24),
            ServicesSection(),
          ],
        ),
      ],
    );
  }

  // ---------- Landscape ----------
  Widget _buildLandscapeLayout(
      BuildContext context, ResponsiveInfo info, ThemeData theme) {
    const imageMaxSize = 400.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image à gauche
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: imageMaxSize,
            maxHeight: imageMaxSize,
          ),
          child: _buildProfileImage(context, info, theme),
        ),
        const SizedBox(width: 32),

        // Colonne droite totalement scrollable
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPresentationText(context, theme, info.isMobile),
              const SizedBox(height: 24),
              _buildActionButtons(context, theme, info.isMobile),
              const SizedBox(height: 24),

              // Le reste scroll si nécessaire
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  ComparisonStatsView(),
                  SizedBox(height: 24),
                  ServicesSection(),
                ],
              ),
            ],
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
      child: ClipOval(
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
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: const [
        ResponsiveText.titleLarge(
          'Emryck Doré',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        SizedBox(height: 8),
        ResponsiveText.headlineSmall(
          'Développeur Flutter & Architecte Logiciel',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        ResponsiveText.bodySmall(
          'Expert en développement mobile cross-platform et solutions digitales. '
          'Spécialisé dans la création d\'applications Flutter performantes, '
          'l\'architecture logicielle et la transformation digitale des entreprises.',
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ---------- Action Buttons ----------
  Widget _buildActionButtons(
      BuildContext context, ThemeData theme, bool isMobile) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () => context.go('/projects'),
          icon: const Icon(Icons.work_outline),
          label: const ResponsiveText.bodySmall('Voir mes projets'),
          style: _btnStyle(theme, isMobile),
        ),
        OutlinedButton.icon(
          onPressed: () => context.go('/contact'),
          icon: const Icon(Icons.mail_outline),
          label: const ResponsiveText.bodySmall('Me contacter'),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 32,
              vertical: isMobile ? 16 : 20,
            ),
            side: BorderSide(color: theme.colorScheme.primary, width: 2),
            foregroundColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

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
