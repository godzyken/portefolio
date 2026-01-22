import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../affichage/screen_size_detector.dart';

/// Configuration centralisée pour tous les types de cards
class CardConfig {
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enableHover;
  final bool enableAnimation;
  final Duration animationDuration;

  const CardConfig({
    this.margin,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.boxShadow,
    this.gradient,
    this.backgroundColor,
    this.onTap,
    this.onLongPress,
    this.enableHover = true,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  factory CardConfig.compact() => const CardConfig(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(12),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      );

  factory CardConfig.expanded() => const CardConfig(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(20),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      );

  factory CardConfig.minimal() => const CardConfig(
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.all(8),
        borderRadius: BorderRadius.all(Radius.circular(8)),
        enableAnimation: false,
      );
}

/// Widget de base pour toutes les cards de l'application
/// Gère automatiquement hover, animations, shadows
class BaseCard extends ConsumerStatefulWidget {
  final Widget child;
  final CardConfig config;
  final String? id; // Pour le state management global

  const BaseCard({
    super.key,
    required this.child,
    this.config = const CardConfig(),
    this.id,
  });

  @override
  ConsumerState<BaseCard> createState() => _BaseCardState();
}

class _BaseCardState extends ConsumerState<BaseCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final theme = Theme.of(context);
    final config = widget.config.copyWith(
      margin: widget.config.margin ??
          (info.isDesktop ? const EdgeInsets.all(16) : const EdgeInsets.all(8)),
      padding: widget.config.padding ??
          (info.isDesktop
              ? const EdgeInsets.all(20)
              : const EdgeInsets.all(12)),
      borderRadius: widget.config.borderRadius ??
          (info.isDesktop
              ? BorderRadius.circular(16)
              : BorderRadius.circular(12)),
      enableHover: widget.config.enableHover && info.isDesktop,
      enableAnimation: widget.config.enableAnimation && info.isDesktop,
      animationDuration: widget.config.animationDuration,
      boxShadow: widget.config.boxShadow ??
          (info.isDesktop ? _defaultShadow(theme, _isHovered) : null),
    );

    return MouseRegion(
      onEnter:
          config.enableHover ? (_) => setState(() => _isHovered = true) : null,
      onExit:
          config.enableHover ? (_) => setState(() => _isHovered = false) : null,
      cursor: config.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: config.onTap,
        onLongPress: config.onLongPress,
        child: AnimatedContainer(
          duration: config.animationDuration,
          width: config.width,
          height: config.height,
          margin: config.margin,
          padding: config.padding,
          transform: config.enableAnimation && _isHovered
              ? (Matrix4.identity()
                ..translateByDouble(0.0, -4.0, 0.0, 0.0)
                ..scaleByDouble(1.02, 1.02, 1.0, 1.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            borderRadius: config.borderRadius ?? BorderRadius.circular(12),
            gradient: config.gradient,
            color: config.backgroundColor ?? theme.cardColor,
            boxShadow: config.boxShadow ?? _defaultShadow(theme, _isHovered),
          ),
          child: widget.child,
        ),
      ),
    );
  }

  List<BoxShadow> _defaultShadow(ThemeData theme, bool isHovered) {
    return [
      BoxShadow(
        color: theme.shadowColor.withValues(alpha: isHovered ? 0.3 : 0.15),
        blurRadius: isHovered ? 16 : 8,
        offset: Offset(0, isHovered ? 8 : 4),
      ),
    ];
  }
}

// ============================================================================
// EXEMPLES D'UTILISATION
// ============================================================================

// Remplace ServiceCard, ProjectCard, ExperienceCard
class UnifiedContentCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? content;
  final Widget? statusBadge;
  final CardConfig config;
  final VoidCallback? onTap;

  const UnifiedContentCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.content,
    this.statusBadge,
    this.config = const CardConfig(),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseCard(
      config: config.copyWith(onTap: onTap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 12)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              if (statusBadge != null) ...[
                statusBadge!,
                const SizedBox(width: 8),
              ],
              if (trailing != null) trailing!,
            ],
          ),

          // Content
          if (content != null) ...[
            const SizedBox(height: 16),
            content!,
          ],
        ],
      ),
    );
  }
}

// Extension pour simplifier la création
extension CardConfigExtension on CardConfig {
  CardConfig copyWith({
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
    Color? backgroundColor,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool? enableHover,
    bool? enableAnimation,
    Duration? animationDuration,
  }) {
    return CardConfig(
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      width: width ?? this.width,
      height: height ?? this.height,
      borderRadius: borderRadius ?? this.borderRadius,
      boxShadow: boxShadow ?? this.boxShadow,
      gradient: gradient ?? this.gradient,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      onTap: onTap ?? this.onTap,
      onLongPress: onLongPress ?? this.onLongPress,
      enableHover: enableHover ?? this.enableHover,
      enableAnimation: enableAnimation ?? this.enableAnimation,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}

// ============================================================================
// AVANT / APRÈS
// ============================================================================

/*
❌ AVANT : 3 fichiers différents (ServicesCard, ProjectCard, ExperienceCard)
   - Chacun 200-400 lignes
   - Duplication de la logique hover/animation/shadow
   - Total : ~1000 lignes

✅ APRÈS : 1 fichier centralisé
   - BaseCard : 100 lignes
   - UnifiedContentCard : 50 lignes
   - Total : 150 lignes
   - Réduction de 85% !

// Utilisation simplifiée
UnifiedContentCard(
  title: 'Mon Service',
  subtitle: 'Description',
  leading: Icon(Icons.work),
  config: CardConfig.compact(),
  onTap: () => print('Tapped'),
)
*/
