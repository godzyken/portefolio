import 'package:flutter/material.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

/// 🎯 Builder universel de sections avec titre et contenu
class SectionBuilder extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? accentColor;
  final Widget child;
  final EdgeInsets? padding;
  final bool useGradient;

  const SectionBuilder({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.accentColor,
    this.padding,
    this.useGradient = false,
  });

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
    final color = accentColor ?? Colors.blue;

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
          child: ResponsiveText.titleMedium(
            title,
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
    if (!useGradient) {
      return Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (accentColor ?? Colors.blue).withValues(alpha: 0.2),
          ),
        ),
        child: child,
      );
    }

    // Version avec gradient
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (accentColor ?? Colors.blue).withValues(alpha: 0.2),
            (accentColor ?? Colors.blue).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (accentColor ?? Colors.blue).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: child,
    );
  }
}

/// 🎯 Builder de liste avec bullets
class BulletListBuilder extends StatelessWidget {
  final List<String> items;
  final Color? bulletColor;
  final Color? textColor;
  final double spacing;

  const BulletListBuilder({
    super.key,
    required this.items,
    this.bulletColor,
    this.textColor,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((text) => Padding(
                padding: EdgeInsets.only(bottom: spacing),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: bulletColor ?? Colors.blue,
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
              ))
          .toList(),
    );
  }
}

// ============================================================================
// UTILISATION : Remplace InfoCard, ExperienceListSection, etc.
// ============================================================================

/// ❌ AVANT dans experience_list_section.dart (50 lignes)
/// ✅ APRÈS
