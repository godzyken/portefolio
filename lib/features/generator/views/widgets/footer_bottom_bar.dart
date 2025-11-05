import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/widgets/ui_widgets_extentions.dart';

class PortfolioFooter extends StatelessWidget {
  const PortfolioFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Icônes / Infos principales ---
          Wrap(
            spacing: 32,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildFooterInfo(
                  context, theme, Icons.schedule, 'Réponse sous 24h'),
              _buildFooterInfo(
                context,
                theme,
                Icons.gavel,
                'Confidentialité garantie',
                route: '/legal',
              ),
              _buildFooterInfo(context, theme, Icons.verified, 'Devis gratuit'),
            ],
          ),

          const SizedBox(height: 24),

          // --- Séparateur léger ---
          Divider(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            thickness: 0.5,
            height: 24,
          ),

          // --- Section Copyright ---
          ResponsiveText.bodySmall(
            '© ${DateTime.now().year} Godzyken — Tous droits réservés.',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Élément d'information du footer
  Widget _buildFooterInfo(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String text, {
    String? route,
  }) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.primary.withValues(alpha: 0.8),
        ),
        const ResponsiveBox(paddingSize: ResponsiveSpacing.xs),
        ResponsiveText.bodyMedium(
          text,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );

    // Si non cliquable, on renvoie le contenu brut
    if (route == null) return content;

    // Version cliquable avec effet hover pour Flutter Web
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        hoverColor: theme.colorScheme.primary.withValues(alpha: 0.08),
        onTap: () => context.push(route),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: content,
        ),
      ),
    );
  }
}
