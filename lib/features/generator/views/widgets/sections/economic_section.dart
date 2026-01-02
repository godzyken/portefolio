import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/widgets/ui_widgets_extentions.dart';
import 'package:portefolio/features/generator/views/generator_widgets_extentions.dart';

import '../../../data/chart_data.dart';
import '../../../services/section_manager.dart';

/// Section Analyse Économique - Affiche ROI et graphiques économiques
///
/// Affiche:
/// - Badges économiques (ROI, gains, coûts, temps gagné, réactivité)
/// - Grille de graphiques économiques
class EconomicSection extends StatelessWidget {
  final Map<String, dynamic> development;
  final ResponsiveInfo info;

  const EconomicSection({
    super.key,
    required this.development,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final charts = ChartDataFactory.createChartsFromDevelopment(development);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText.titleMedium(
          '💼 Analyse Économique & ROI',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Liste compacte des badges économiques
        if (development.containsKey('6_roi_global'))
          BadgeList(
            badges: SectionManager.getEconomicBadges(development)
                .map((badge) => BadgeWidget.economic(
                      label: badge['label']!,
                      value: badge['value']!,
                    ))
                .toList(),
          ),

        // Graphiques en grille
        Expanded(
          child: charts.isEmpty
              ? Center(
                  child: ResponsiveText.bodyMedium(
                    'Aucun graphique économique disponible',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                )
              : CompactChartsGrid(
                  charts: charts,
                  info: info,
                ),
        ),
      ],
    );
  }
}
