// lib/features/generator/views/widgets/charts/unified_chart_system.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';

/// 🎯 SYSTÈME UNIFIÉ DE GRAPHIQUES
/// Remplace : chart_renderer.dart, compact_charts_card.dart, chart_widgets_unified.dart
/// Économie : ~1400 lignes → ~400 lignes

// ============================================================================
// CONFIGURATION
// ============================================================================

class ChartConfig {
  final ResponsiveInfo info;
  final Color primaryColor;
  final bool showGrid;
  final bool animate;
  final EdgeInsets padding;

  const ChartConfig({
    required this.info,
    this.primaryColor = Colors.blue,
    this.showGrid = true,
    this.animate = true,
    this.padding = const EdgeInsets.all(16),
  });
}

// ============================================================================
// FACTORY PATTERN - Point d'entrée unique
// ============================================================================

class UnifiedChart extends StatelessWidget {
  final ChartData data;
  final ChartConfig config;

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
      ChartType.bar => _BarChartBuilder(data: data, config: config),
      ChartType.line => _LineChartBuilder(data: data, config: config),
      ChartType.pie => _PieChartBuilder(data: data, config: config),
      ChartType.scatter => _ScatterChartBuilder(data: data, config: config),
      ChartType.kpi => _KPIBuilder(data: data, config: config),
    };
  }
}

// ============================================================================
// BUILDERS OPTIMISÉS
// ============================================================================

class _BarChartBuilder extends StatelessWidget {
  final ChartData data;
  final ChartConfig config;

  const _BarChartBuilder({required this.data, required this.config});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: data.barGroups,
        titlesData: _buildTitles(),
        gridData: config.showGrid ? _defaultGrid : FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  FlTitlesData _buildTitles() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: config.info.isMobile ? 32 : 40,
          getTitlesWidget: (value, meta) => Text(
            _formatCompact(value),
            style: TextStyle(fontSize: config.info.isMobile ? 10 : 12),
          ),
        ),
      ),
      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
  final ChartConfig config;

  const _LineChartBuilder({required this.data, required this.config});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: data.lineSpots!,
            isCurved: true,
            color: config.primaryColor,
            barWidth: 2.5,
            dotData: FlDotData(show: config.info.isMobile ? false : true),
            belowBarData: BarAreaData(
              show: true,
              color: config.primaryColor.withValues(alpha: 0.2),
            ),
          ),
        ],
        titlesData: FlTitlesData(show: false),
        gridData: FlGridData(show: config.showGrid),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _PieChartBuilder extends StatelessWidget {
  final ChartData data;
  final ChartConfig config;

  const _PieChartBuilder({required this.data, required this.config});

  @override
  Widget build(BuildContext context) {
    final radius = config.info.isMobile ? 50.0 : 70.0;

    return PieChart(
      PieChartData(
        sections: data.pieSections,
        centerSpaceRadius: radius * 0.6,
        sectionsSpace: 2,
        startDegreeOffset: -90,
      ),
    );
  }
}

class _ScatterChartBuilder extends StatelessWidget {
  final ChartData data;
  final ChartConfig config;

  const _ScatterChartBuilder({required this.data, required this.config});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: data.scatterSpots!.map((s) => FlSpot(s.x, s.y)).toList(),
            isCurved: false,
            dotData: FlDotData(show: true),
            show: true,
          ),
        ],
      ),
    );
  }
}

class _KPIBuilder extends StatelessWidget {
  final ChartData data;
  final ChartConfig config;

  const _KPIBuilder({required this.data, required this.config});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: config.info.isMobile ? 2 : 4,
        childAspectRatio: 2.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: data.kpiValues?.length,
      itemBuilder: (context, index) {
        final entry = data.kpiValues?.entries.elementAt(index);
        return _KPICard(label: entry!.key, value: entry.value);
      },
    );
  }
}

class _KPICard extends StatelessWidget {
  final String label;
  final String value;

  const _KPICard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 10)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TYPES (à déplacer dans models/)
// ============================================================================

enum ChartType { bar, line, pie, scatter, kpi }

class ChartData {
  final ChartType type;
  final List<BarChartGroupData>? barGroups;
  final List<FlSpot>? lineSpots;
  final List<PieChartSectionData>? pieSections;
  final List<ScatterSpot>? scatterSpots;
  final Map<String, String>? kpiValues;

  const ChartData({
    required this.type,
    this.barGroups,
    this.lineSpots,
    this.pieSections,
    this.scatterSpots,
    this.kpiValues,
  });
}
