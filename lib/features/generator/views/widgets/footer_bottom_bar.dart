import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

class PortfolioFooter extends ConsumerWidget {
  const PortfolioFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final info = ref.watch(responsiveInfoProvider);
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
                context,
                theme,
                info,
                Icons.psychology_outlined,
                'Parler à mon Avatar IA',
                route: '/avatar',
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

          // --- Section Copyright (5 taps rapides = accès admin, discret) ---
          _SecretAdminTrigger(year: DateTime.now().year),
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

    if (route == null) return content;

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

/// Le texte de copyright ordinaire, mais 5 taps rapides (moins de 2s entre
/// chaque) ouvrent l'écran de connexion admin. Aucune indication visuelle :
/// c'est le seul moyen d'accéder à `/admin/login` depuis le site public.
class _SecretAdminTrigger extends StatefulWidget {
  const _SecretAdminTrigger({required this.year});
  final int year;

  @override
  State<_SecretAdminTrigger> createState() => _SecretAdminTriggerState();
}

class _SecretAdminTriggerState extends State<_SecretAdminTrigger> {
  static const _requiredTaps = 5;
  static const _resetDelay = Duration(seconds: 2);

  int _tapCount = 0;
  DateTime? _lastTap;

  void _onTap() {
    final now = DateTime.now();
    if (_lastTap == null || now.difference(_lastTap!) > _resetDelay) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }
    _lastTap = now;

    if (_tapCount >= _requiredTaps) {
      _tapCount = 0;
      context.push('/admin/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: ResponsiveText.bodySmall(
        '© ${widget.year} Godzyken — Tous droits réservés.',
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}