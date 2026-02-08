import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';
import 'package:portefolio/features/generator/views/generator_widgets_extentions.dart';

/// Section Résultats - Affiche les résultats et graphiques du projet
///
/// Affiche:
/// - Liste de badges des résultats
/// - Grille de graphiques des résultats
class ResultsSection extends StatefulWidget {
  final ProjectInfo project;
  final ResponsiveInfo info;

  const ResultsSection({
    super.key,
    required this.project,
    required this.info,
  });

  @override
  State<ResultsSection> createState() => _ResultsSectionState();
}

class _ResultsSectionState extends State<ResultsSection> {
  late List<ChartData> _charts;

  @override
  void initState() {
    super.initState();
    _prepareChartData();
  }

  void _prepareChartData() {
    final resultats = widget.project.resultsMap;
    if (resultats == null) {
      _charts = [];
      return;
    }
    _charts = ChartDataFactory.createChartsFromResults(resultats);

    developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    developer.log('Données chargées : ${_charts.length}');
    for (var chart in _charts) {
      developer.log('  ✓ ${chart.title} (${chart.type})');
    }
    developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  @override
  Widget build(BuildContext context) {
    final results = widget.project.results ?? [];
    final resultsMap = widget.project.resultsMap ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText.titleMedium(
          '🏁 Résultats & Impact',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Liste des badges de résultats
        if (results.isNotEmpty || resultsMap.isNotEmpty)
          BadgeList(
            badges: _buildResultBadges(results),
          ),

        // Graphiques en grille
        Expanded(
          child: _charts.isEmpty
              ? Center(
                  child: ResponsiveText.bodyMedium(
                    'Aucun graphique disponible',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                )
              : CompactChartsGrid(
                  charts: _charts,
                  info: widget.info,
                ),
        ),
      ],
    );
  }

  List<Widget> _buildResultBadges(List<String> results) {
    return results.map((result) => BadgeWidget.result(result)).toList();
  }
}
