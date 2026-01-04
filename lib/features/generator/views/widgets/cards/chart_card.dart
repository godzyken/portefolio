import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

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
    final dominantColor =
        chart.lineColor ?? chart.pieSections?.first.color ?? Colors.white;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          dominantColor.withValues(alpha: 0.05),
          Colors.white.withValues(alpha: 0.03),
        ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dominantColor.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: dominantColor.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: info.isMobile ? 4 : 8,
                bottom: info.isMobile ? 4 : 12,
              ),
              child: _buildChartContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final dominantColor =
        chart.lineColor ?? chart.pieSections?.first.color ?? Colors.white;

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
            themeColor: dominantColor,
          ),
        ),
      ],
    );
  }

  Widget _buildChartContent() {
    final randomDelay = Duration(milliseconds: Random().nextInt(300));

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 600),
            opacity: 1,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 700),
              scale: 1,
              curve: Curves.easeOutBack,
              child: FutureBuilder(
                future: Future.delayed(randomDelay),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  return _buildChart();
                },
              ),
            ),
          ),
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

      case ChartType.scatterChart:
        return CompactScatterTrendChart(
            spots: chart.scatterSpots!.map((s) => FlSpot(s.x, s.y)).toList(),
            labels: [
              'ROI 3 ans',
              'Gains',
              'Coûts',
              'Productivité',
              'Temps économisé'
            ],
            color: chart.scatterColor ?? Colors.tealAccent,
            info: info);
    }
  }
}
