import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';
import 'package:portefolio/features/generator/views/widgets/cards/compact_charts_card.dart';

/// 🎯 SYSTÈME UNIFIÉ DE GRAPHIQUES
/// Économie : ~1400 lignes → ~400 lignes

class UnifiedChartConfig {
  final ResponsiveInfo info;
  final Color primaryColor;
  final bool showGrid;
  final bool animate;
  final EdgeInsets padding;

  const UnifiedChartConfig({
    required this.info,
    this.primaryColor = Colors.blue,
    this.showGrid = true,
    this.animate = true,
    this.padding = const EdgeInsets.all(16),
  });
}

class UnifiedChart extends StatelessWidget {
  final ChartData data;
  final UnifiedChartConfig config;

  const UnifiedChart({
    super.key,
    required this.data,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: config.padding,
      child: _buildChart(),
    );
  }

  Widget _buildChart() {
    return switch (data.type) {
      ChartType.barChart => _BarChartBuilder(data: data, config: config),
      ChartType.lineChart => _LineChartBuilder(data: data, config: config),
      ChartType.pieChart => _PieChartBuilder(data: data, config: config),
      ChartType.scatterChart =>
        _ScatterChartBuilder(data: data, config: config),
      ChartType.kpiCards => _KPIBuilder(data: data, config: config),
      _ => const Center(child: Text("Format en cours de migration...")),
    };
  }
}

class _BarChartBuilder extends StatelessWidget {
  final ChartData data;
  final UnifiedChartConfig config;

  const _BarChartBuilder({required this.data, required this.config});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: data.barGroups ?? [],
        titlesData: _buildTitles(),
        gridData:
            config.showGrid ? _defaultGrid : const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: config.animate),
      ),
    );
  }

  FlTitlesData _buildTitles() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: config.info.isMobile ? 28 : 35,
          getTitlesWidget: (value, meta) => SideTitleWidget(
            meta: meta,
            fitInside: SideTitleFitInsideData(
              enabled: true,
              distanceFromEdge: 0,
              parentAxisSize: meta.parentAxisSize,
              axisPosition: meta.axisPosition,
            ),
            space: 4,
            child: Text(
              _formatCompact(value),
              style: TextStyle(
                fontSize: config.info.isMobile ? 9 : 11,
                color: Colors.white54,
              ),
            ),
          ),
        ),
      ),
      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  static final _defaultGrid = FlGridData(
    show: true,
    drawVerticalLine: false,
    getDrawingHorizontalLine: (value) => FlLine(
      color: Colors.white.withValues(alpha: 0.1),
      strokeWidth: 1,
    ),
  );

  String _formatCompact(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
}

class _LineChartBuilder extends StatelessWidget {
  final ChartData data;
  final UnifiedChartConfig config;

  const _LineChartBuilder({required this.data, required this.config});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: data.lineSpots ?? [],
            isCurved: true,
            color: config.primaryColor,
            barWidth: 2.5,
            dotData: FlDotData(show: !config.info.isMobile),
            belowBarData: BarAreaData(
              show: true,
              color: config.primaryColor.withValues(alpha: 0.2),
            ),
          ),
        ],
        titlesData: const FlTitlesData(show: false),
        gridData: FlGridData(show: config.showGrid),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _PieChartBuilder extends StatelessWidget {
  final ChartData data;
  final UnifiedChartConfig config;

  const _PieChartBuilder({required this.data, required this.config});

  @override
  Widget build(BuildContext context) {
    final radius = config.info.isMobile ? 40.0 : 60.0;

    return PieChart(
      PieChartData(
        sections: data.pieSections ?? [],
        centerSpaceRadius: radius * 0.6,
        sectionsSpace: 2,
        startDegreeOffset: -90,
      ),
    );
  }
}

class _ScatterChartBuilder extends StatelessWidget {
  final ChartData data;
  final UnifiedChartConfig config;

  const _ScatterChartBuilder({required this.data, required this.config});

  @override
  Widget build(BuildContext context) {
    return ScatterChart(
      ScatterChartData(
        scatterSpots: data.scatterSpots ?? [],
        gridData: FlGridData(show: config.showGrid),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _KPIBuilder extends StatelessWidget {
  final ChartData data;
  final UnifiedChartConfig config;

  const _KPIBuilder({required this.data, required this.config});

  @override
  Widget build(BuildContext context) {
    return CompactKPICards(
      kpiValues: data.kpiValues ?? {},
      info: config.info,
    );
  }
}
