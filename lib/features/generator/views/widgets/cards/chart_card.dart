import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/widgets/ui_widgets_extentions.dart';

import '../../../data/extention_models.dart';
import '../../generator_widgets_extentions.dart';

/// Card wrapper pour un graphique individuel
///
/// Affiche:
/// - Titre du graphique
/// - Bouton plein écran
/// - Contenu du graphique (délégué aux ChartBuilders)
class ChartCard extends StatelessWidget {
  final ChartData chart;
  final ResponsiveInfo info;
  final double height;

  const ChartCard({
    super.key,
    required this.chart,
    required this.info,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 8),
          Expanded(
            child: _buildChartContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ResponsiveText.bodyLarge(
            chart.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.fullscreen, size: 18),
          color: Colors.white70,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => showChartFullscreen(
            context: context,
            chart: chart,
            info: info,
          ),
        ),
      ],
    );
  }

  Widget _buildChartContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: _buildChart(),
        );
      },
    );
  }

  Widget _buildChart() {
    switch (chart.type) {
      case ChartType.kpiCards:
        return CompactKPICards(
          kpiValues: chart.kpiValues!,
          info: info,
        );

      case ChartType.benchmarkGlobal:
        return BenchmarkGlobalWidget(
          benchmark: chart.benchmarkInfo!,
          info: info,
        );

      case ChartType.benchmarkComparison:
        return BenchmarkComparisonWidget(
          benchmarks: chart.benchmarkComparison!,
          info: info,
        );

      case ChartType.benchmarkRadar:
        return BenchmarkRadarWidget(
          benchmark: chart.benchmarkInfo!,
          info: info,
        );

      case ChartType.benchmarkTable:
        return SingleChildScrollView(
          child: BenchmarkTableWidget(
            benchmarks: chart.benchmarkComparison!,
            info: info,
          ),
        );

      case ChartType.barChart:
        return CompactBarChart(
          barGroups: chart.barGroups!,
          info: info,
        );

      case ChartType.lineChart:
        return CompactLineChart(
          spots: chart.lineSpots!,
          xLabels: chart.xLabels!,
          color: chart.lineColor!,
          info: info,
        );

      case ChartType.pieChart:
        return CompactPieChart(
          sections: chart.pieSections!,
          info: info,
        );
    }
  }
}
