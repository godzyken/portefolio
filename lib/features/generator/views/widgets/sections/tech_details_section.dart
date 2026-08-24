import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

/// Section Détails Techniques - Affiche les spécifications techniques
///
/// Affiche une grille de cartes avec les détails techniques du projet
/// (framework, version, déploiement, etc.)
class TechDetailsSection extends StatelessWidget {
  final Map<String, dynamic> techDetails;
  final ResponsiveInfo info;

  const TechDetailsSection({
    super.key,
    required this.techDetails,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorHelpers.cyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorHelpers.cyan.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.settings_suggest_outlined, color: ColorHelpers.cyan, size: 22),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: ResponsiveText.titleMedium(
                    '⚙️ SPÉCIFICATIONS TECHNIQUES',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: techDetails.entries.map((entry) {
              return _TechDetailCard(
                label: entry.key,
                value: entry.value.toString(),
                info: info,
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

/// Card individuelle pour un détail technique
class _TechDetailCard extends StatelessWidget {
  final String label;
  final String value;
  final ResponsiveInfo info;

  const _TechDetailCard({
    required this.label,
    required this.value,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _getTechIcon(label);
    
    return Container(
      width: info.isMobile ? (info.size.width - 40) : 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ColorHelpers.cyan, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ColorHelpers.textSecondary,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTechIcon(String label) {
    final l = label.toLowerCase();
    if (l.contains('version') || l.contains('build')) return Icons.tag;
    if (l.contains('deploy') || l.contains('héberg') || l.contains('host')) return Icons.cloud_upload_outlined;
    if (l.contains('state') || l.contains('donnée')) return Icons.account_tree_outlined;
    if (l.contains('perf')) return Icons.speed;
    if (l.contains('test')) return Icons.biotech;
    if (l.contains('arch')) return Icons.architecture;
    if (l.contains('lang')) return Icons.language;
    if (l.contains('base')) return Icons.storage;
    return Icons.settings_input_component_outlined;
  }
}
