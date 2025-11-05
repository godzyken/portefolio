import 'package:flutter/material.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

import '../../../../core/affichage/screen_size_detector.dart';

class ContactFooter extends StatelessWidget {
  final ResponsiveInfo info;
  final ThemeData theme;
  const ContactFooter({required this.info, required this.theme, super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBox(
      width: double.infinity,
      paddingSize: info.isMobile ? ResponsiveSpacing.m : ResponsiveSpacing.l,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            theme.colorScheme.surface.withValues(alpha: 0.5)
          ],
        ),
      ),
      child: Column(
        children: [
          ResponsiveText.bodyMedium(
            '🚀 Prêt à transformer votre idée en réalité ?',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
/*
          Wrap(
            spacing: 24,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildFooterInfo(
                  context, theme, Icons.schedule, 'Réponse sous 24h'),
              _buildFooterInfo(
                  context, theme, Icons.gavel, 'Confidentialité garantie',
                  route: '/legal'),
              _buildFooterInfo(context, theme, Icons.verified, 'Devis gratuit'),
            ],
          ),
*/
        ],
      ),
    );
  }

/*  Widget _buildFooterInfo(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String text, {
    String? route, // optionnel : permet de rendre l’item cliquable
  }) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary.withValues(alpha: 0.7),
        ),
        const ResponsiveBox(paddingSize: ResponsiveSpacing.xs),
        ResponsiveText.bodyMedium(
          text,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );

    // Si aucune route n’est fournie, on retourne simplement le contenu
    if (route == null) return content;

    // Si une route est fournie, on rend le widget cliquable
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => context.push(route),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: content,
      ),
    );
  }*/
}
