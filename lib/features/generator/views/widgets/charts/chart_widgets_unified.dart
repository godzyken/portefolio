import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';

/// 🎯 Configuration commune pour tous les charts
class ChartConfig {
  final ResponsiveInfo info;
  final Color primaryColor;
  final bool showGrid;
  final bool showBorder;
  final EdgeInsets? padding;

  const ChartConfig({
    required this.info,
    this.primaryColor = Colors.blueAccent,
    this.showGrid = true,
    this.showBorder = false,
    this.padding,
  });
}

/// 🎯 Widgets de charts unifiés et réutilisables
class ChartWidgets {
  /// BarChart unifié
  static Widget bar({
    required List<BarChartGroupData> barGroups,
    required ChartConfig config,
    Widget Function(double, FlTitlesData)? yLabelBuilder,
  }) {
    return BarChart(
      BarChartData(
        barGroups: barGroups,
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: config.info.isMobile ? 32 : 40,
              /*getTitlesWidget:
                  yLabelBuilder != null ? (v, m) => yLabelBuilder(v, m) : null,*/
            ),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: config.showGrid,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withValues(alpha: 0.1),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: config.showBorder),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toStringAsFixed(1),
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }

  /// LineChart unifié
  static Widget line({
    required List<FlSpot> spots,
    required ChartConfig config,
    List<Widget>? xLabels,
    int xLabelStep = 1,
  }) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: config.primaryColor,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 1.5,
                  strokeColor: config.primaryColor,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: config.primaryColor.withValues(alpha: 0.2),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: xLabels != null,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (xLabels == null ||
                    idx >= xLabels.length ||
                    idx % xLabelStep != 0) {
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
              reservedSize: config.info.isMobile ? 32 : 40,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: config.showGrid,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withValues(alpha: 0.1),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: config.showBorder),
      ),
    );
  }

  /// PieChart unifié
  static Widget pie({
    required List<PieChartSectionData> sections,
    required ChartConfig config,
    double centerSpaceRadius = 40,
  }) {
    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: centerSpaceRadius,
        sectionsSpace: 2,
        pieTouchData: PieTouchData(enabled: true),
      ),
    );
  }
}
