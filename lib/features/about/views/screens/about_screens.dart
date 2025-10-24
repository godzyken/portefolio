import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/features/parametres/views/widgets/smart_image.dart';

class AboutSection extends ConsumerWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(responsiveInfoProvider);
    final theme = Theme.of(context);
    final isWide = info.size.width > 800;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isWide
              ? _buildWideLayout(context, theme, info)
              : _buildNarrowLayout(context, theme, info),
        ),
      ),
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    ThemeData theme,
    ResponsiveInfo info,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image à gauche
        Flexible(
          flex: 4,
          child: _buildProfileImage(context, theme, info),
        ),

        const SizedBox(width: 48),

        // Contenu à droite
        Flexible(
          flex: 6,
          child: _buildContent(context, theme, false),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(
    BuildContext context,
    ThemeData theme,
    ResponsiveInfo info,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildProfileImage(context, theme, info),
        const SizedBox(height: 32),
        _buildContent(context, theme, true),
      ],
    );
  }

  Widget _buildProfileImage(
    BuildContext context,
    ThemeData theme,
    ResponsiveInfo info,
  ) {
    final imageSize =
        info.isMobile ? info.size.width * 0.7 : info.size.width * 0.3;

    return Hero(
      tag: 'profile_image',
      child: Container(
        width: imageSize,
        height: imageSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SmartImage(
            path:
                'http://localhost:10004/wp-content/uploads/2025/10/acdc1610-eccb-4a59-8d8e-85896343cbbd.webp',
            fit: BoxFit.cover,
            fallbackIcon: Icons.person,
            fallbackColor: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    bool isCentered,
  ) {
    return Column(
      crossAxisAlignment:
          isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Titre
        Text(
          "Godzyken",
          style: GoogleFonts.montserrat(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
          textAlign: isCentered ? TextAlign.center : TextAlign.left,
        ),

        const SizedBox(height: 12),

        // Sous-titre
        Text(
          "Développeur Flutter freelance",
          style: GoogleFonts.openSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.secondary,
          ),
          textAlign: isCentered ? TextAlign.center : TextAlign.left,
        ),

        const SizedBox(height: 24),

        // Description détaillée
        _buildDescription(context, theme, isCentered),

        const SizedBox(height: 32),

        // Statistiques
        _buildStats(context, theme, isCentered),

        const SizedBox(height: 32),

        // Bouton d'action
        _buildActionButton(context, theme),
      ],
    );
  }

  Widget _buildDescription(
    BuildContext context,
    ThemeData theme,
    bool isCentered,
  ) {
    return Column(
      crossAxisAlignment:
          isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          "Je conçois des applications Flutter sur mesure pour aider les entreprises à digitaliser leurs processus métiers.",
          textAlign: isCentered ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.openSans(
            fontSize: 16,
            height: 1.6,
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Chaque année, je développe un projet complet — de l'idée à la mise en production — pour transformer des besoins réels en solutions performantes et durables.",
          textAlign: isCentered ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.openSans(
            fontSize: 16,
            height: 1.6,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Travaillant seul, je maîtrise chaque aspect du développement (UX, architecture, intégration, déploiement) afin d'offrir des outils clairs, efficaces et alignés sur les objectifs de mes clients.",
          textAlign: isCentered ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.openSans(
            fontSize: 16,
            height: 1.6,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(
    BuildContext context,
    ThemeData theme,
    bool isCentered,
  ) {
    final stats = [
      {'number': '10+', 'label': 'Années d\'expérience'},
      {'number': '50+', 'label': 'Projets réalisés'},
      {'number': '100%', 'label': 'Satisfaction client'},
    ];

    return Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: isCentered ? WrapAlignment.center : WrapAlignment.start,
      children: stats.map((stat) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                stat['number'] as String,
                style: GoogleFonts.montserrat(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stat['label'] as String,
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    ThemeData theme,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        // Navigation vers les projets
        Navigator.of(context).pushNamed('/projects');
      },
      icon: const Icon(Icons.arrow_forward_rounded),
      label: const Text("Découvrir mes projets"),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: theme.colorScheme.primary.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
