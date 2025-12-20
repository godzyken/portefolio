import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:portefolio/features/generator/data/chart_data.dart';
import 'package:portefolio/features/generator/views/widgets/benchmark_widgets.dart';
import 'package:portefolio/features/generator/views/widgets/three_d_tech_icon.dart';

import '../../../../core/affichage/colors_spec.dart';
import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/ui/widgets/responsive_text.dart';

class ChartRenderer {
  /// Rend tous les charts de manière uniforme
  static Widget renderChartsWithBenchmarks(
    List<ChartData> charts,
    ResponsiveInfo info,
    Widget Function(double) yLabel,
  ) {
    if (charts.isEmpty) return const SizedBox.shrink();

    final benchmarkCharts = charts
        .where((c) => [
              ChartType.benchmarkGlobal,
              ChartType.benchmarkComparison,
              ChartType.benchmarkRadar,
              ChartType.benchmarkTable
            ].contains(c.type))
        .toList();

    final otherCharts =
        charts.where((c) => !benchmarkCharts.contains(c)).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (benchmarkCharts.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.all(info.isMobile ? 12 : 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ResponsiveText.titleMedium('📊 Analyse des Benchmarks',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...benchmarkCharts.map((chart) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _renderBenchmarkChart(chart, info),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (otherCharts.isNotEmpty) renderCharts(otherCharts, info, yLabel),
      ],
    );
  }

  static Widget renderCharts(
    List<ChartData> charts,
    ResponsiveInfo info,
    Widget Function(double) yLabelBuilder,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: charts
          .map((chart) => Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chart.title,
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: info.isMobile ? 14 : 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildChartContent(chart, info, yLabelBuilder),
                  ],
                ),
              ))
          .toList(),
    );
  }

  static Widget _buildChartContent(ChartData chart, ResponsiveInfo info,
      Widget Function(double) yLabelBuilder) {
    // REDUCTION DE LA HAUTEUR : 130px sur mobile, 180px sur desktop
    final double h = info.isMobile ? 130 : 180;

    switch (chart.type) {
      case ChartType.kpiCards:
        return _buildKPICardsCompact(chart.kpiValues!, info);
      case ChartType.barChart:
        return SizedBox(
            height: h,
            child: _buildBarChart(chart.barGroups!, info, yLabelBuilder));
      case ChartType.lineChart:
        return SizedBox(
            height: h,
            child: _buildLineChart(chart.lineSpots!, chart.xLabels!,
                chart.lineColor!, chart.xLabelStep!, info, yLabelBuilder));
      case ChartType.pieChart:
        return SizedBox(
            height: h, child: _buildPieChart(chart.pieSections!, info));

      default:
        return const SizedBox.shrink();
    }
  }

  static Widget _buildKPICardsCompact(
      Map<String, String> kpis, ResponsiveInfo info) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: kpis.entries.map((entry) {
        return Container(
          width: info.isMobile ? (info.size.width / 2) - 30 : 140,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Text(entry.key,
                  style: const TextStyle(color: Colors.white60, fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 1),
              Text(entry.value,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: info.isMobile ? 15 : 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- Helper Methods (Benchmark) ---
  static Widget _renderBenchmarkChart(ChartData chart, ResponsiveInfo info) {
    if (chart.type == ChartType.benchmarkGlobal) {
      return BenchmarkGlobalWidget(benchmark: chart.benchmarkInfo!, info: info);
    }
    if (chart.type == ChartType.benchmarkComparison) {
      return BenchmarkComparisonWidget(
          benchmarks: chart.benchmarkComparison!, info: info);
    }
    return const SizedBox.shrink();
  }

  // ============================================
  // PIE CHART
  // ============================================

  static Widget _buildPieChart(
      List<PieChartSectionData> sections, ResponsiveInfo info) {
    if (sections.isEmpty) return const Center(child: Text("Pas de données"));

    // 1. Transformation des sections pour injecter le badge futuriste
    final futuristicSections = sections.map((section) {
      return section.copyWith(
        showTitle: false,
        radius: info.isMobile ? 40 : 55,
        badgeWidget: ThreeDTechIcon(
          logoPath: section.title,
          color: section.color,
          size: info.isMobile ? 34 : 44,
        ),
        badgePositionPercentageOffset: 1.2,
      );
    }).toList();

    return Center(
      child: AspectRatio(
        aspectRatio: 1.3, // Maintient un cercle parfait
        child: PieChart(
          PieChartData(
            sections: futuristicSections,
            centerSpaceRadius: info.isMobile ? 30 : 45,
            sectionsSpace: 4,
            pieTouchData: PieTouchData(
                enabled: true,
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    return;
                  }
                }),
          ),
        ),
      ),
    );
  }

  // ============================================
  // BAR CHART
  // ============================================

  static Widget _buildBarChart(
    List<BarChartGroupData> barGroups,
    ResponsiveInfo info,
    Widget Function(double) yLabelBuilder,
  ) {
    return ResponsiveBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: info.isMobile ? 32 : 40,
                getTitlesWidget: (v, m) => yLabelBuilder(v),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white24),
          ),
        ),
      ),
    );
  }

  // ============================================
  // LINE CHART
  // ============================================

  static Widget _buildLineChart(
    List<FlSpot> spots,
    List<Widget> xLabels,
    Color color,
    int xLabelStep,
    ResponsiveInfo info,
    Widget Function(double) yLabelBuilder,
  ) {
    return ResponsiveBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 1,
                    strokeColor: color,
                  );
                },
              ),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= xLabels.length || idx % xLabelStep != 0) {
                    return const SizedBox.shrink();
                  }
                  return Transform.rotate(
                    angle: -0.2,
                    child: xLabels[idx],
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: info.isMobile ? 32 : 40,
                interval: _computeYInterval(spots),
                getTitlesWidget: (v, m) => yLabelBuilder(v),
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _computeYInterval(spots),
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white12,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white24),
          ),
        ),
      ),
    );
  }

  static double _computeYInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 1;
    final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final range = maxY - minY;

    if (range <= 5) return 1;
    if (range <= 20) return 5;
    if (range <= 50) return 10;
    if (range <= 100) return 20;
    return (range / 5).ceilToDouble();
  }
}

extension ChartRendererBenchmark on ChartRenderer {
  /// Rend tous les charts incluant les benchmarks
  static Widget renderChartsWithBenchmarks(
    List<ChartData> charts,
    ResponsiveInfo info,
    Widget Function(double) yLabel,
  ) {
    if (charts.isEmpty) return const SizedBox.shrink();

    // Séparer les benchmarks des autres charts
    final benchmarkCharts = charts
        .where((c) =>
            c.type == ChartType.benchmarkGlobal ||
            c.type == ChartType.benchmarkComparison ||
            c.type == ChartType.benchmarkRadar ||
            c.type == ChartType.benchmarkTable)
        .toList();

    final otherCharts = charts
        .where((c) =>
            c.type != ChartType.benchmarkGlobal &&
            c.type != ChartType.benchmarkComparison &&
            c.type != ChartType.benchmarkRadar &&
            c.type != ChartType.benchmarkTable)
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Section Benchmark avec titre et fond spécial
        if (benchmarkCharts.isNotEmpty) ...[
          ResponsiveBox(
            padding: EdgeInsets.all(info.isMobile ? 12 : 24),
            decoration: BoxDecoration(
              gradient: ColorHelpers.bgGradient,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Titre de section
                ResponsiveText.titleLarge(
                  '📊 Analyse des Benchmarks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: info.isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                ResponsiveBox(
                  paddingSize: ResponsiveSpacing.s,
                ),

                // Rendre les charts de benchmark
                ...benchmarkCharts.map((chart) {
                  return ResponsiveBox(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _renderBenchmarkChart(chart, info),
                  );
                }),

                // Recommandations si on a des comparaisons
                if (benchmarkCharts
                    .any((c) => c.type == ChartType.benchmarkComparison)) ...[
                  ResponsiveBox(
                    paddingSize: ResponsiveSpacing.s,
                  ),
                  _renderBenchmarkRecommendations(benchmarkCharts, info),
                ],
              ],
            ),
          ),
          ResponsiveBox(
            paddingSize: ResponsiveSpacing.s,
          ),
        ],

        // Autres charts (KPI, ventes, etc.)
        if (otherCharts.isNotEmpty)
          ChartRenderer.renderCharts(otherCharts, info, yLabel),
      ],
    );
  }

  /// Rend un chart de benchmark individuel
  static Widget _renderBenchmarkChart(ChartData chart, ResponsiveInfo info) {
    switch (chart.type) {
      case ChartType.benchmarkGlobal:
        if (chart.benchmarkInfo != null) {
          return BenchmarkGlobalWidget(
            benchmark: chart.benchmarkInfo!,
            info: info,
          );
        }
        break;

      case ChartType.benchmarkComparison:
        if (chart.benchmarkComparison != null) {
          return BenchmarkComparisonWidget(
            benchmarks: chart.benchmarkComparison!,
            info: info,
          );
        }
        break;

      case ChartType.benchmarkRadar:
        if (chart.benchmarkInfo != null) {
          // Déterminer la couleur selon l'index
          final colors = [ColorHelpers.purple, ColorHelpers.pink];
          return BenchmarkRadarWidget(
            benchmark: chart.benchmarkInfo!,
            info: info,
            color: colors[0], // Adapter selon le contexte
          );
        }
        break;

      case ChartType.benchmarkTable:
        if (chart.benchmarkComparison != null) {
          return BenchmarkTableWidget(
            benchmarks: chart.benchmarkComparison!,
            info: info,
          );
        }
        break;

      default:
        break;
    }
    return const SizedBox.shrink();
  }

  /// Rend les recommandations pour les benchmarks
  static Widget _renderBenchmarkRecommendations(
    List<ChartData> benchmarkCharts,
    ResponsiveInfo info,
  ) {
    // Récupérer toutes les infos de benchmark
    final allBenchmarks = <BenchmarkInfo>[];

    for (final chart in benchmarkCharts) {
      if (chart.benchmarkComparison != null) {
        allBenchmarks.addAll(chart.benchmarkComparison!);
      }
    }

    if (allBenchmarks.isEmpty) return const SizedBox.shrink();

    return BenchmarkRecommendationsWidget(
      benchmarks: allBenchmarks,
      info: info,
    );
  }
}
