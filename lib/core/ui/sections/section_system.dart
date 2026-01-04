// ============================================================================
// lib/core/ui/sections/section_system.dart
// Système unifié de sections et cards - Remplace 8 fichiers
// ============================================================================

import 'package:flutter/material.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

// ============================================================================
// PARTIE 1 : BUILDERS DE SECTIONS
// ============================================================================

/// Configuration pour une section
class SectionConfig {
  final String title;
  final IconData? icon;
  final Color? accentColor;
  final EdgeInsets? padding;
  final bool useGradient;
  final bool showBorder;
  final double? borderRadius;

  const SectionConfig({
    required this.title,
    this.icon,
    this.accentColor,
    this.padding,
    this.useGradient = false,
    this.showBorder = true,
    this.borderRadius = 16,
  });
}

/// 🎯 Builder universel de sections
class SectionBuilder extends StatelessWidget {
  final SectionConfig config;
  final Widget child;

  const SectionBuilder({
    super.key,
    required this.config,
    required this.child,
  });

  /// Factory : Section simple
  factory SectionBuilder.simple({
    required String title,
    required Widget child,
    IconData? icon,
    Color? accentColor,
  }) {
    return SectionBuilder(
      config: SectionConfig(
        title: title,
        icon: icon,
        accentColor: accentColor,
      ),
      child: child,
    );
  }

  /// Factory : Section avec gradient
  factory SectionBuilder.gradient({
    required String title,
    required Widget child,
    IconData? icon,
    Color? accentColor,
  }) {
    return SectionBuilder(
      config: SectionConfig(
        title: title,
        icon: icon,
        accentColor: accentColor,
        useGradient: true,
      ),
      child: child,
    );
  }

  /// Factory : Section sans bordure
  factory SectionBuilder.borderless({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return SectionBuilder(
      config: SectionConfig(
        title: title,
        icon: icon,
        showBorder: false,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildContent(),
      ],
    );
  }

  Widget _buildHeader() {
    final color = config.accentColor ?? Colors.blue;

    return Row(
      children: [
        if (config.icon != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(config.icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: ResponsiveText.titleMedium(
            config.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final color = config.accentColor ?? Colors.blue;

    if (config.useGradient) {
      return Container(
        padding: config.padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(config.borderRadius ?? 16),
          border: config.showBorder
              ? Border.all(color: color.withValues(alpha: 0.3), width: 2)
              : null,
        ),
        child: child,
      );
    }

    return Container(
      padding: config.padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(config.borderRadius ?? 16),
        border: config.showBorder
            ? Border.all(color: color.withValues(alpha: 0.2))
            : null,
      ),
      child: child,
    );
  }
}

// ============================================================================
// PARTIE 2 : BUILDERS DE LISTES
// ============================================================================

/// 🎯 Builder de liste avec bullets
class BulletListBuilder extends StatelessWidget {
  final List<String> items;
  final Color? bulletColor;
  final Color? textColor;
  final double spacing;
  final IconData? bulletIcon;

  const BulletListBuilder({
    super.key,
    required this.items,
    this.bulletColor,
    this.textColor,
    this.spacing = 12,
    this.bulletIcon,
  });

  /// Factory : Liste avec cercles
  factory BulletListBuilder.circles({
    required List<String> items,
    Color? color,
  }) {
    return BulletListBuilder(
      items: items,
      bulletColor: color,
      textColor: color ?? Colors.white,
    );
  }

  /// Factory : Liste avec checks
  factory BulletListBuilder.checks({
    required List<String> items,
    Color? color,
  }) {
    return BulletListBuilder(
      items: items,
      bulletIcon: Icons.check_circle,
      bulletColor: color,
      textColor: color ?? Colors.white,
    );
  }

  /// Factory : Liste avec arrows
  factory BulletListBuilder.arrows({
    required List<String> items,
    Color? color,
  }) {
    return BulletListBuilder(
      items: items,
      bulletIcon: Icons.arrow_right,
      bulletColor: color,
      textColor: color ?? Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((text) => _buildItem(text)).toList(),
    );
  }

  Widget _buildItem(String text) {
    final color = bulletColor ?? Colors.blue;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bulletIcon != null)
            Icon(bulletIcon, size: 16, color: color)
          else
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: ResponsiveText.bodyMedium(
              text,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PARTIE 3 : STAT CARDS
// ============================================================================

/// Configuration pour une stat card
class StatCardConfig {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const StatCardConfig({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });
}

/// Style de stat card
enum StatCardStyle { compact, horizontal, gradient, minimal }

/// 🎯 Factory de stat cards
class StatCardFactory {
  /// Card compacte verticale
  static Widget compact(StatCardConfig config) {
    final color = config.color ?? Colors.blue;

    return InkWell(
      onTap: config.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(config.icon, color: color, size: 24),
            const SizedBox(height: 8),
            ResponsiveText.bodySmall(
              config.label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            const SizedBox(height: 4),
            ResponsiveText.titleMedium(
              config.value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  /// Card horizontale
  static Widget horizontal(StatCardConfig config) {
    final color = config.color ?? Colors.blue;

    return InkWell(
      onTap: config.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(config.icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ResponsiveText.bodySmall(
                    config.label,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  ResponsiveText.titleMedium(
                    config.value,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card avec gradient
  static Widget gradient(StatCardConfig config) {
    final color = config.color ?? Colors.blue;

    return InkWell(
      onTap: config.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.3),
              color.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(config.icon, color: color, size: 32),
            const SizedBox(height: 16),
            ResponsiveText.bodySmall(
              config.label,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            ResponsiveText.displaySmall(
              config.value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card minimale (badge style)
  static Widget minimal(StatCardConfig config) {
    final color = config.color ?? Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 12, color: color),
          const SizedBox(width: 6),
          ResponsiveText.bodySmall(
            config.label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(width: 6),
          ResponsiveText.bodySmall(
            config.value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// Grid de stats
  static Widget grid({
    required List<StatCardConfig> configs,
    int crossAxisCount = 2,
    double childAspectRatio = 1.5,
    StatCardStyle style = StatCardStyle.compact,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: configs.length,
      itemBuilder: (context, index) {
        return switch (style) {
          StatCardStyle.compact => compact(configs[index]),
          StatCardStyle.horizontal => horizontal(configs[index]),
          StatCardStyle.gradient => gradient(configs[index]),
          StatCardStyle.minimal => minimal(configs[index]),
        };
      },
    );
  }

  /// Liste horizontale scrollable
  static Widget horizontalList(
    List<StatCardConfig> configs, {
    StatCardStyle style = StatCardStyle.horizontal,
  }) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: configs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 200,
            child: switch (style) {
              StatCardStyle.horizontal => horizontal(configs[index]),
              StatCardStyle.gradient => gradient(configs[index]),
              _ => compact(configs[index]),
            },
          );
        },
      ),
    );
  }

  /// Wrap flexible
  static Widget wrap(
    List<StatCardConfig> configs, {
    StatCardStyle style = StatCardStyle.minimal,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: configs.map((config) {
        return switch (style) {
          StatCardStyle.minimal => minimal(config),
          StatCardStyle.compact => compact(config),
          _ => horizontal(config),
        };
      }).toList(),
    );
  }
}

// ============================================================================
// PARTIE 4 : DATA SECTION BUILDER
// ============================================================================

/// 🎯 Builder pour sections de données (comme Infrastructure)
class DataSectionBuilder extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final Map<String, dynamic> data;
  final String Function(String)? keyFormatter;

  const DataSectionBuilder({
    super.key,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.data,
    this.keyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return SectionBuilder(
      config: SectionConfig(
        title: title,
        icon: icon,
        accentColor: accentColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries.map((entry) {
          final formattedKey =
              keyFormatter?.call(entry.key) ?? _defaultFormatKey(entry.key);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ResponsiveText.bodyMedium(
                    '$formattedKey: ${entry.value}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _defaultFormatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) =>
            word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

// ============================================================================
// PARTIE 5 : METRIC COLUMN (pour synthèses annuelles)
// ============================================================================

/// 🎯 Colonne de métrique
class MetricColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double? fontSize;

  const MetricColumn({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ResponsiveText.bodySmall(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        ResponsiveText.bodyMedium(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}
