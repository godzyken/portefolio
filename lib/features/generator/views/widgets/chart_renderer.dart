import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:portefolio/features/generator/data/chart_data.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/ui/widgets/responsive_text.dart';

class ChartRenderer {
  /// Rend tous les charts de manière uniforme
  static Widget renderCharts(
    List<ChartData> charts,
    ResponsiveInfo info,
    Widget Function(double) yLabelBuilder,
  ) {
    if (charts.isEmpty) {
      return ResponsiveText.bodyMedium(
        "Aucune donnée de performance à afficher pour ce projet.",
        style: const TextStyle(color: Colors.white60),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: charts.map((chart) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChartTitle(chart.title, info),
            const ResponsiveBox(height: 16),
            _buildChartContent(chart, info, yLabelBuilder),
            const ResponsiveBox(height: 32),
          ],
        );
      }).toList(),
    );
  }

  static Widget _buildChartTitle(String title, ResponsiveInfo info) {
    return ResponsiveText.headlineMedium(
      title,
      style: TextStyle(
        color: Colors.white70,
        fontSize: info.isMobile ? 16 : 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static Widget _buildChartContent(
    ChartData chart,
    ResponsiveInfo info,
    Widget Function(double) yLabelBuilder,
  ) {
    switch (chart.type) {
      case ChartType.kpiCards:
        return _buildKPICards(chart.kpiValues!, info);

      case ChartType.barChart:
        return _buildBarChart(chart.barGroups!, info, yLabelBuilder);

      case ChartType.pieChart:
        return _buildPieChart(chart.pieSections!);

      case ChartType.lineChart:
        return _buildLineChart(
          chart.lineSpots!,
          chart.xLabels!,
          chart.lineColor!,
          chart.xLabelStep!,
          info,
          yLabelBuilder,
        );
    }
  }

  // ============================================
  // NOUVEAU : KPI CARDS WIDGET
  // ============================================

  static Widget _buildKPICards(Map<String, String> kpis, ResponsiveInfo info) {
    // Calcul du nombre de colonnes selon l'écran
    final crossAxisCount = info.isDesktop ? 4 : (info.isTablet ? 3 : 2);

    return ResponsiveBox(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: info.isMobile ? 1.2 : 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: kpis.length,
        itemBuilder: (context, index) {
          final entry = kpis.entries.elementAt(index);
          return _buildKPICard(entry.key, entry.value, info);
        },
      ),
    );
  }

  static Widget _buildKPICard(String label, String value, ResponsiveInfo info) {
    return ResponsiveBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(info.isMobile ? 12 : 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ResponsiveText.bodySmall(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: info.isMobile ? 12 : 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const ResponsiveBox(height: 8),
            ResponsiveText.titleLarge(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: info.isMobile ? 20 : 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
  // PIE CHART
  // ============================================

  static Widget _buildPieChart(List<PieChartSectionData> sections) {
    return ResponsiveBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
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
