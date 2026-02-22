import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';

import '../../../data/extention_models.dart';
import '../../generator_widgets_extentions.dart';

/// Card wrapper pour un graphique individuel.
///
/// [height] est imposé de l'extérieur par [CompactChartsGrid].
/// Le graphique occupe tout l'espace disponible sous le header fixe.
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
    final dominantColor = chart.lineColor ??
        (chart.pieSections?.isNotEmpty == true
            ? chart.pieSections!.first.color
            : Colors.white);

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            dominantColor.withValues(alpha: 0.06),
            Colors.white.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: dominantColor.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: dominantColor.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header fixe 40px — titre + bouton plein écran
          SizedBox(
            height: 40,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 4, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      chart.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: info.isMobile ? 11 : 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.fullscreen, size: 16),
                    color: Colors.white38,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => showChartFullscreen(
                      context: context,
                      chart: chart,
                      info: info,
                      themeColor: dominantColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Séparateur
          Divider(
            height: 1,
            thickness: 1,
            color: dominantColor.withValues(alpha: 0.1),
          ),

          // Corps du graphique — prend tout l'espace restant
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                info.isMobile ? 6 : 10,
                6,
                info.isMobile ? 6 : 10,
                info.isMobile ? 6 : 10,
              ),
              child: _buildWithDelay(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithDelay() {
    final delay = Duration(milliseconds: Random().nextInt(200));
    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
          );
        }
        return _buildChart();
      },
    );
  }

  Widget _buildChart() {
    switch (chart.type) {
      case ChartType.kpiCards:
        return CompactKPICards(kpiValues: chart.kpiValues!, info: info);

      case ChartType.benchmarkGlobal:
        return BenchmarkGlobalWidget(
            benchmark: chart.benchmarkInfo!, info: info);

      case ChartType.benchmarkComparison:
        return SingleChildScrollView(
          child: BenchmarkComparisonWidget(
              benchmarks: chart.benchmarkComparison!, info: info),
        );

      case ChartType.benchmarkRadar:
        return BenchmarkRadarWidget(
            benchmark: chart.benchmarkInfo!, info: info);

      case ChartType.benchmarkTable:
        return SingleChildScrollView(
          child: BenchmarkTableWidget(
              benchmarks: chart.benchmarkComparison!, info: info),
        );

      case ChartType.barChart:
        return CompactBarChart(barGroups: chart.barGroups!, info: info);

      case ChartType.lineChart:
        return CompactLineChart(
          spots: chart.lineSpots!,
          xLabels: chart.xLabels!,
          color: chart.lineColor!,
          info: info,
        );

      case ChartType.pieChart:
        return CompactPieChart(sections: chart.pieSections!, info: info);

      case ChartType.scatterChart:
        return CompactScatterTrendChart(
          spots: chart.scatterSpots!.map((s) => FlSpot(s.x, s.y)).toList(),
          labels: const [
            'ROI 3 ans',
            'Gains',
            'Coûts',
            'Productivité',
            'Temps éco.'
          ],
          color: chart.scatterColor ?? Colors.tealAccent,
          info: info,
        );
    }
  }
}
