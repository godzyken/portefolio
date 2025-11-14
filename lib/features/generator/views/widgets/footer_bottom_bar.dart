import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';
import 'package:portefolio/core/ui/widgets/ui_widgets_extentions.dart'; // Import pour ResponsiveBox/Spacing

class PortfolioFooter extends ConsumerWidget {
  // 1. Changé en ConsumerWidget
  const PortfolioFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Ajout de WidgetRef ref
    final theme = Theme.of(context);
    final info = ref
        .watch(responsiveInfoProvider); // 3. Récupération des infos responsive
    final isMobile = info.isMobile;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Icônes / Infos principales ---
          Wrap(
            spacing: isMobile ? 16 : 32, // Réduction de l'espacement sur mobile
            runSpacing: isMobile
                ? 8
                : 12, // Réduction de l'espacement vertical sur mobile
            alignment: WrapAlignment.center,
            children: [
              _buildFooterInfo(
                  context, theme, info, Icons.schedule, 'Réponse sous 24h'),
              _buildFooterInfo(
                context,
                theme,
                info,
                Icons.gavel,
                'Confidentialité garantie',
                route: '/legal',
              ),
              _buildFooterInfo(
                  context, theme, info, Icons.verified, 'Devis gratuit'),
            ],
          ),

          const ResponsiveBox(paddingSize: ResponsiveSpacing.xs),

          // --- Séparateur léger ---
          Divider(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            thickness: 0.5,
            height: isMobile ? 16 : 24, // Hauteur réduite sur mobile
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
    ResponsiveInfo info, // Ajout de ResponsiveInfo
    IconData icon,
    String text, {
    String? route,
  }) {
    final isMobile = info.isMobile;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: isMobile
              ? 16
              : 18, // Taille d'icône légèrement réduite sur mobile
          color: theme.colorScheme.primary.withValues(alpha: 0.8),
        ),
        const ResponsiveBox(paddingSize: ResponsiveSpacing.xs),
        ResponsiveText.bodySmall(
          // Changé de bodyMedium à bodySmall pour plus de compacité sur mobile
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
        child: ResponsiveBox(
          paddingSize: ResponsiveSpacing.xs,
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: content,
        ),
      ),
    );
  }
}
