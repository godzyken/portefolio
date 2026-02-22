import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';

import '../../../data/models/chart_data.dart';
import '../cards/chart_card.dart';

/// Grille responsive de graphiques.
///
/// Architecture :
/// - Utilise [ListView] de [Row]s (pas de GridView) → hauteur fixe par chart,
///   zéro débordement lié au childAspectRatio.
/// - Mobile (< 600px) : 1 colonne systématiquement.
/// - Tablette (600–1000px) : 2 colonnes.
/// - Desktop (> 1000px) : 2–3 colonnes selon la largeur.
/// - Chaque type de chart a une hauteur calibrée pour son contenu.
class CompactChartsGrid extends StatelessWidget {
  final List<ChartData> charts;
  final ResponsiveInfo info;

  const CompactChartsGrid({
    super.key,
    required this.charts,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    if (charts.isEmpty) return const SizedBox.shrink();

    final cols = _columns();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: (charts.length / cols).ceil(),
      itemBuilder: (context, rowIndex) {
        final start = rowIndex * cols;
        final end = (start + cols).clamp(0, charts.length);
        final rowCharts = charts.sublist(start, end);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowCharts.asMap().entries.map((entry) {
              final chart = entry.value;
              final h = _height(chart);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: entry.key == 0 ? 0 : 5,
                    right: entry.key == rowCharts.length - 1 ? 0 : 5,
                  ),
                  child: SizedBox(
                    height: h,
                    child: ChartCard(chart: chart, info: info, height: h),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  int _columns() {
    final w = info.size.width;
    if (w < 600) return 1;
    if (w < 1000) return 2;
    return 3;
  }

  /// Hauteur calibrée pour chaque type de chart.
  ///
  /// Ces valeurs ont été choisies pour que le contenu soit lisible sans
  /// scroll interne ni débordement sur mobile et desktop.
  double _height(ChartData chart) {
    final m = info.isMobile;
    switch (chart.type) {
      case ChartType.kpiCards:
        final count = chart.kpiValues?.length ?? 4;
        final rows = (count / (m ? 2 : 3)).ceil();
        // 70px par ligne de KPI + 48px header
        return ((rows * 70) + 48).clamp(120.0, 300.0).toDouble();

      case ChartType.pieChart:
        // Le pie + légende horizontale
        return m ? 260.0 : 300.0;

      case ChartType.lineChart:
        return m ? 210.0 : 250.0;

      case ChartType.barChart:
        return m ? 210.0 : 250.0;

      case ChartType.scatterChart:
        return m ? 230.0 : 270.0;

      case ChartType.benchmarkGlobal:
        // Pie score compact
        return m ? 200.0 : 240.0;

      case ChartType.benchmarkRadar:
        return m ? 240.0 : 280.0;

      case ChartType.benchmarkComparison:
        // Barres horizontales : 4 critères × N projets
        final n = chart.benchmarkComparison?.length ?? 1;
        return (180 + n * 44).clamp(220.0, 420.0).toDouble();

      case ChartType.benchmarkTable:
        final n = chart.benchmarkComparison?.length ?? 1;
        return (160 + n * 30).clamp(200.0, 380.0).toDouble();

      default:
        return m ? 210.0 : 250.0;
    }
  }
}
