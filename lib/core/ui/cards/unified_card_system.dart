// ============================================================================
// lib/core/ui/cards/unified_card_system.dart
// Système de cards 100% unifié - Remplace tous les systèmes de cards
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';

import '../../config/image_preload_config.dart';
import '../../service/unified_image_manager.dart';
import '../widgets/smart_image_v2.dart';

// ============================================================================
// PARTIE 1: CONFIGURATION UNIFIÉE
// ============================================================================

/// Configuration unique pour TOUTES les cards de l'app
class UnifiedCardConfig {
  // Style visuel
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final List<BoxShadow>? boxShadow;

  // Dimensions
  final double? width;
  final double? height;
  final double? minHeight;
  final double? maxHeight;

  // Interactions
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enableHover;
  final bool enableAnimation;

  // Layout
  final Axis? direction; // horizontal ou vertical
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;

  const UnifiedCardConfig({
    this.padding,
    this.margin,
    this.borderRadius,
    this.gradient,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.boxShadow,
    this.width,
    this.height,
    this.minHeight,
    this.maxHeight,
    this.onTap,
    this.onLongPress,
    this.enableHover = true,
    this.enableAnimation = true,
    this.direction,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
  });

  /// Factory: Style card classique
  factory UnifiedCardConfig.standard({
    Color? accentColor,
    VoidCallback? onTap,
  }) {
    return UnifiedCardConfig(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(16),
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      borderColor: (accentColor ?? Colors.blue).withValues(alpha: 0.2),
      borderWidth: 1,
      onTap: onTap,
    );
  }

  /// Factory: Style card avec gradient
  factory UnifiedCardConfig.gradient({
    required Color primaryColor,
    Color? secondaryColor,
    VoidCallback? onTap,
  }) {
    return UnifiedCardConfig(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: [
          primaryColor.withValues(alpha: 0.3),
          (secondaryColor ?? primaryColor).withValues(alpha: 0.1),
        ],
      ),
      borderColor: primaryColor.withValues(alpha: 0.5),
      borderWidth: 2,
      boxShadow: [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      onTap: onTap,
    );
  }

  /// Factory: Style minimal (sans bordure)
  factory UnifiedCardConfig.minimal({VoidCallback? onTap}) {
    return UnifiedCardConfig(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      borderRadius: BorderRadius.circular(12),
      enableAnimation: false,
      onTap: onTap,
    );
  }

  /// Factory: Style compact (pour listes)
  factory UnifiedCardConfig.compact({VoidCallback? onTap}) {
    return UnifiedCardConfig(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(vertical: 4),
      borderRadius: BorderRadius.circular(8),
      direction: Axis.horizontal,
      onTap: onTap,
    );
  }

  UnifiedCardConfig copyWith({
    EdgeInsets? padding,
    EdgeInsets? margin,
    BorderRadius? borderRadius,
    Gradient? gradient,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    List<BoxShadow>? boxShadow,
    double? width,
    double? height,
    double? minHeight,
    double? maxHeight,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool? enableHover,
    bool? enableAnimation,
    Axis? direction,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
  }) {
    return UnifiedCardConfig(
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      borderRadius: borderRadius ?? this.borderRadius,
      gradient: gradient ?? this.gradient,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      boxShadow: boxShadow ?? this.boxShadow,
      width: width ?? this.width,
      height: height ?? this.height,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
      onTap: onTap ?? this.onTap,
      onLongPress: onLongPress ?? this.onLongPress,
      enableHover: enableHover ?? this.enableHover,
      enableAnimation: enableAnimation ?? this.enableAnimation,
      direction: direction ?? this.direction,
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
    );
  }
}

// ============================================================================
// PARTIE 2: COMPOSANTS DE CARD
// ============================================================================

/// Composant générique pour le contenu d'une card
abstract class CardComponent {
  Widget build(BuildContext context, ResponsiveInfo info);
  static CardComponent fromWidget(Widget widget) => _WidgetComponent(widget);
}

/// Header de card (titre + icône + trailing)
class CardHeader implements CardComponent {
  final String title;
  final IconData? icon;
  final Widget? trailing;
  final Color? accentColor;
  final TextStyle? titleStyle;

  const CardHeader({
    required this.title,
    this.icon,
    this.trailing,
    this.accentColor,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context, ResponsiveInfo info) {
    final theme = Theme.of(context);
    final color = accentColor ?? theme.colorScheme.primary;

    return Row(
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            title,
            style: titleStyle ??
                theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}

/// Badge de statut
class CardStatusBadge implements CardComponent {
  final String label;
  final Color? color;
  final IconData? icon;

  const CardStatusBadge({
    required this.label,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context, ResponsiveInfo info) {
    final badgeColor = color ?? Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: badgeColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Média (image/vidéo)
class CardMedia implements CardComponent {
  final String? imagePath;
  final Widget? customWidget;
  final double? height;
  final BoxFit fit;

  const CardMedia({
    this.imagePath,
    this.customWidget,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context, ResponsiveInfo info) {
    if (customWidget != null) return customWidget!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height ?? (info.isMobile ? 150 : 200),
        width: double.infinity,
        // 🔹 Utilisation de SmartImageV2 pour profiter du cache unifié
        child: imagePath != null
            ? SmartImageV2(
                path: imagePath!,
                fit: fit,
              )
            : Container(
                color: Colors.grey.withValues(alpha: 0.1),
                child: const Icon(Icons.image_not_supported, size: 32),
              ),
      ),
    );
  }
}

/// Liste de bullet points
class CardBulletList implements CardComponent {
  final List<String> items;
  final IconData? bulletIcon;
  final Color? bulletColor;

  const CardBulletList({
    required this.items,
    this.bulletIcon,
    this.bulletColor,
  });

  @override
  Widget build(BuildContext context, ResponsiveInfo info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                bulletIcon ?? Icons.check_circle,
                size: 16,
                color: bulletColor ?? Colors.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(item),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ============================================================================
// PARTIE 3: CARD UNIFIÉE
// ============================================================================

/// Card universelle pour TOUTE l'app
class UnifiedCard extends ConsumerStatefulWidget {
  final UnifiedCardConfig config;
  final List<CardComponent>? components;
  final Widget? child;
  final String? id;

  const UnifiedCard({
    super.key,
    this.config = const UnifiedCardConfig(),
    this.components,
    this.child,
    this.id,
  }) : assert(
          components != null || child != null,
          'Either components or child must be provided',
        );

  /// Factory: Card de contenu (projet, expérience, service)
  factory UnifiedCard.content({
    required String title,
    String? subtitle,
    IconData? icon,
    Widget? trailing,
    List<String>? bulletPoints,
    String? imagePath,
    Color? accentColor,
    VoidCallback? onTap,
  }) {
    if (imagePath != null) {
      ImagePreloadConfig.registerImage(imagePath,
          strategy: PreloadStrategy.lazy);
    }
    return UnifiedCard(
      config: UnifiedCardConfig.standard(
        accentColor: accentColor,
        onTap: onTap,
      ),
      components: [
        CardHeader(
          title: title,
          icon: icon,
          trailing: trailing,
          accentColor: accentColor,
        ),
        if (subtitle != null)
          CardComponent.fromWidget(
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        if (imagePath != null) CardMedia(imagePath: imagePath),
        if (bulletPoints != null) CardBulletList(items: bulletPoints),
      ],
    );
  }

  @override
  ConsumerState<UnifiedCard> createState() => _UnifiedCardState();
}

class _UnifiedCardState extends ConsumerState<UnifiedCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final theme = Theme.of(context);
    final config = _getResponsiveConfig(info);

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
          duration: const Duration(milliseconds: 200),
          width: config.width,
          height: config.height,
          constraints: BoxConstraints(
            minHeight: config.minHeight ?? 0,
            maxHeight: config.maxHeight ?? double.infinity,
          ),
          margin: config.margin,
          padding: config.padding,
          transform: config.enableAnimation && _isHovered
              ? (Matrix4.identity()
                ..translateByDouble(0.0, -4.0, 0.0, 0.0)
                ..scaleByDouble(1.02, 1.02, 1.0, 1.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            borderRadius: config.borderRadius,
            gradient: config.gradient,
            color: config.backgroundColor,
            border: config.borderColor != null
                ? Border.all(
                    color: config.borderColor!,
                    width: config.borderWidth ?? 1,
                  )
                : null,
            boxShadow: config.boxShadow ??
                _defaultShadow(theme, _isHovered, config.enableHover),
          ),
          child: _buildContent(info),
        ),
      ),
    );
  }

  UnifiedCardConfig _getResponsiveConfig(ResponsiveInfo info) {
    return widget.config.copyWith(
      padding: widget.config.padding ?? EdgeInsets.all(info.isMobile ? 12 : 16),
      margin: widget.config.margin ?? EdgeInsets.all(info.isMobile ? 8 : 12),
      borderRadius: widget.config.borderRadius ??
          BorderRadius.circular(info.isMobile ? 12 : 16),
    );
  }

  Widget _buildContent(ResponsiveInfo info) {
    if (widget.child != null) return widget.child!;

    final components = widget.components!;
    final direction = widget.config.direction ?? Axis.vertical;

    final widgets = components.map((c) => c.build(context, info)).toList();

    if (direction == Axis.horizontal) {
      return Row(
        mainAxisAlignment:
            widget.config.mainAxisAlignment ?? MainAxisAlignment.start,
        crossAxisAlignment:
            widget.config.crossAxisAlignment ?? CrossAxisAlignment.center,
        children: _addSpacing(widgets, const SizedBox(width: 12)),
      );
    }

    return Column(
      mainAxisAlignment:
          widget.config.mainAxisAlignment ?? MainAxisAlignment.start,
      crossAxisAlignment:
          widget.config.crossAxisAlignment ?? CrossAxisAlignment.start,
      children: _addSpacing(widgets, const SizedBox(height: 12)),
    );
  }

  List<Widget> _addSpacing(List<Widget> widgets, Widget spacer) {
    if (widgets.isEmpty) return widgets;

    final result = <Widget>[];
    for (int i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i < widgets.length - 1) result.add(spacer);
    }
    return result;
  }

  List<BoxShadow> _defaultShadow(
      ThemeData theme, bool isHovered, bool enableHover) {
    if (!enableHover) {
      return [
        BoxShadow(
          color: theme.shadowColor.withValues(alpha: 0.15),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
    }

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
// EXTENSION HELPER
// ============================================================================

extension CardComponentExtension on CardComponent {
  /// Wrap n'importe quel widget en CardComponent
  static CardComponent fromWidget(Widget widget) => _WidgetComponent(widget);
}

class _WidgetComponent implements CardComponent {
  final Widget widget;
  const _WidgetComponent(this.widget);

  @override
  Widget build(BuildContext context, ResponsiveInfo info) => widget;
}
