import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/widgets/ui_widgets_extentions.dart';
import 'package:portefolio/features/generator/views/generator_widgets_extentions.dart';

import '../../../data/chart_data.dart';

/// Affiche un graphique en plein écran dans un dialog
void showChartFullscreen({
  required BuildContext context,
  required ChartData chart,
  required ResponsiveInfo info,
}) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: info.size.width * 0.9,
          maxHeight: info.size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ResponsiveText.titleLarge(
                    chart.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildFullscreenChartContent(chart, info),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildFullscreenChartContent(ChartData chart, ResponsiveInfo info) {
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
