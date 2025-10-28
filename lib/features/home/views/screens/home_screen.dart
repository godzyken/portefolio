import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/features/parametres/themes/views/widgets/space_background.dart';
import 'package:portefolio/features/parametres/views/widgets/smart_image.dart';

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
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image de profil
          _buildProfileImage(context, info, theme),

          const SizedBox(height: 32),

          // Texte de présentation
          _buildPresentationText(context, theme, isMobile),

          const SizedBox(height: 40),

          // Boutons d'action
          _buildActionButtons(context, theme, isMobile),

          const SizedBox(height: 48),

          // Section compétences rapides
          _buildQuickSkills(context, theme, isMobile),

          const SizedBox(height: 64),

          // 🔥 Section Services
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
    return Padding(
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

              const SizedBox(width: 64),

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
                    const SizedBox(height: 48),
                    _buildQuickSkills(context, theme, false),
                  ],
                ),
              ),
            ],
          ),
          // 🔥Section Services
          const SizedBox(height: 80),
          ServicesSection(),
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
      child: Container(
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
            path: 'assets/images/me_portrait_2.webp',
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
        Text(
          'Emryck Doré',
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: isMobile ? 42 : 64,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ).createShader(const Rect.fromLTWH(0, 0, 400, 100)),
          ),
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),

        const SizedBox(height: 16),

        // Titre
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.2),
                theme.colorScheme.secondary.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Text(
            'Développeur Flutter & Architecte Logiciel',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
          ),
        ),

        const SizedBox(height: 32),

        // Description
        Text(
          'Expert en développement mobile cross-platform et solutions digitales. '
          'Spécialisé dans la création d\'applications Flutter performantes, '
          'l\'architecture logicielle et la transformation digitale des entreprises.',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: isMobile ? 16 : 18,
            height: 1.8,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
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
          label: const Text('Voir mes projets'),
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
          label: const Text('Me contacter'),
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

  Widget _buildQuickSkills(
    BuildContext context,
    ThemeData theme,
    bool isMobile,
  ) {
    final skills = [
      {'icon': Icons.phone_android, 'label': 'Flutter', 'color': Colors.blue},
      {'icon': Icons.web, 'label': 'Angular', 'color': Colors.red},
      {'icon': Icons.cloud, 'label': 'Firebase', 'color': Colors.orange},
      {
        'icon': Icons.architecture,
        'label': 'Architecture',
        'color': Colors.purple
      },
    ];

    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          'Expertises',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: (skill['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (skill['color'] as Color).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    skill['icon'] as IconData,
                    color: skill['color'] as Color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    skill['label'] as String,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: skill['color'] as Color,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
