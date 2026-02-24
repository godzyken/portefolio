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
          ResponsiveText.titleMedium(
            '⚙️ Détails techniques',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
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
    return Container(
      width: info.isMobile ? double.infinity : 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorHelpers.withAlpha(Colors.blue, 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorHelpers.withAlpha(Colors.blue, 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText.bodySmall(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ResponsiveText.bodyMedium(
            value,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
