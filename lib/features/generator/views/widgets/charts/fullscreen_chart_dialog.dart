import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/features/generator/views/generator_widgets_extentions.dart';

import '../../../../../core/ui/widgets/responsive_text.dart';
import '../../../data/models/chart_data.dart';

/// Affiche un graphique en plein écran dans un dialog
void showChartFullscreen({
  required BuildContext context,
  required ChartData chart,
  required ResponsiveInfo info,
  required Color? themeColor,
}) {
  final color = themeColor ?? Colors.tealAccent;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fermer',
    barrierColor: Colors.black.withValues(alpha: 0.6), // Fond semi-transparent
    transitionDuration: const Duration(milliseconds: 600),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox
          .shrink(); // Nécessaire pour le builder custom ci-dessous
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final fade =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      final scale = Tween<double>(begin: 0.92, end: 1.0).animate(fade);
      final offset =
          Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack));

      return FadeTransition(
        opacity: fade,
        child: ScaleTransition(
          scale: scale,
          child: SlideTransition(
            position: offset,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: info.size.width * 0.9,
                  maxHeight: info.size.height * 0.85,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: color.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    // 🌫️ Fond flou
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                            color: Colors.black.withValues(alpha: 0.3)),
                      ),
                    ),

                    // 📊 Contenu principal
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // En-tête
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
                                icon: const Icon(Icons.close,
                                    color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 💥 Graphique
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  child: FadeTransition(
                                    opacity: CurvedAnimation(
                                      parent: fade,
                                      curve: const Interval(0.2, 1.0,
                                          curve: Curves.easeOut),
                                    ),
                                    child: _buildFullscreenChartContent(
                                        chart, info),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
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

    case ChartType.scatterChart:
      return CompactScatterTrendChart(
        spots: chart.scatterSpots!.map((s) => ScatterSpot(s.x, s.y)).toList(),
        labels: [
          'ROI 3 ans',
          'Gains',
          'Coûts',
          'Productivité',
          'Temps économisé'
        ],
        info: info,
        color: chart.scatterColor!,
      );
  }
}
