import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';

import '../../../data/chart_data.dart';
import '../cards/chart_card.dart';

/// Grille responsive de graphiques
///
/// Adapte automatiquement le nombre de colonnes selon la taille d'écran:
/// - > 1200px: 4 colonnes
/// - > 800px: 3 colonnes
/// - > 600px: 2 colonnes
/// - <= 600px: 1 colonne
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
    final crossAxisCount = _calculateCrossAxisCount();
    final aspectRatio = _calculateAspectRatio(crossAxisCount);

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: charts.length,
      itemBuilder: (context, index) {
        final chart = charts[index];
        final height = _getChartHeight(chart);

        return ChartCard(
          chart: chart,
          info: info,
          height: height,
        );
      },
    );
  }

  int _calculateCrossAxisCount() {
    if (info.size.width > 1200) {
      return 4;
    } else if (info.size.width > 800) {
      return 3;
    } else if (info.size.width > 600) {
      return 2;
    } else {
      return 1;
    }
  }

  double _calculateAspectRatio(int crossAxisCount) {
    double aspectRatio = (info.size.width / crossAxisCount) / 400;
    return aspectRatio.clamp(1.1, 10.0);
  }

  double _getChartHeight(ChartData chart) {
    switch (chart.type) {
      case ChartType.kpiCards:
        return info.isMobile ? 200 : 250;

      case ChartType.lineChart:
      case ChartType.pieChart:
        return info.isMobile ? 300 : 350;

      case ChartType.benchmarkGlobal:
      case ChartType.benchmarkRadar:
        return info.isMobile ? 250 : 300;

      case ChartType.benchmarkComparison:
      case ChartType.benchmarkTable:
        return info.isMobile ? 400 : 500;

      default:
        return info.isMobile ? 300 : 350;
    }
  }
}
