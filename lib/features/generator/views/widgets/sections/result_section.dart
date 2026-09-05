import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:portefolio/features/experience/views/widgets/activity_metrics_chart.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';
import 'package:portefolio/features/generator/views/generator_widgets_extentions.dart';

/// Section Résultats - Affiche les résultats et graphiques du projet
///
/// Affiche:
/// - Liste de badges des résultats
/// - ActivityMetricsChart (Dynamic WakaTime & Supabase)
/// - Grille de graphiques des résultats (Fallback/Legacy)
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
  }

  @override
  Widget build(BuildContext context) {
    final results = widget.project.results ?? [];
    final resultsMap = widget.project.resultsMap ?? {};

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ResponsiveText.titleMedium(
            '🏁 Résultats & Impact',
            style: TextStyle(
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

          const SizedBox(height: 24),

          // NOUVEAU : Graphiques dynamiques (WakaTime / Supabase)
          SizedBox(
            height: 400,
            child: ActivityMetricsChart(
              project: widget.project,
              info: widget.info,
            ),
          ),

          const SizedBox(height: 32),

          // Graphiques Legacy (en dessous en cas de besoin)
          if (_charts.isNotEmpty) ...[
            const ResponsiveText.bodyMedium(
              '📊 Indicateurs complémentaires',
              style:
                  TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 500,
              child: CompactChartsGrid(
                charts: _charts,
                info: widget.info,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildResultBadges(List<String> results) {
    return results.map((result) => BadgeWidget.result(result)).toList();
  }
}
