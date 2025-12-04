import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/widgets/ui_widgets_extentions.dart';
import 'package:portefolio/features/parametres/themes/views/widgets/space_background.dart';

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
          return info.isPortrait
              ? _buildPortraitLayout(context, info, theme)
              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                  child: _buildLandscapeLayout(context, info, theme),
                );
        }),
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
              child: Opacity(
                opacity: 0.5,
                child: const CharacterViewer(),
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
    return IntrinsicHeight(
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
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                ServicesSection(),
              ],
            ),
          ),
        ],
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const ResponsiveText.titleLarge(
          'Emryck Doré',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        const SizedBox(height: 12),
        ResponsiveText.headlineSmall(
          'Développeur Flutter & Architecte Logiciel',
          style: const TextStyle(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ResponsiveText.bodyMedium(
          'Expert en développement mobile cross-platform et solutions digitales. '
          'Spécialisé dans la création d\'applications Flutter performantes, '
          'l\'architecture logicielle et la transformation digitale des entreprises.',
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
              height: 1.5,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8)),
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
      alignment: WrapAlignment.center,
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
