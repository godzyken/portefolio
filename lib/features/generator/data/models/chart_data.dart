import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';

/// Représente un type de chart à afficher
enum ChartType {
  barChart,
  pieChart,
  lineChart,
  kpiCards,
  benchmarkGlobal,
  benchmarkComparison,
  benchmarkRadar,
  benchmarkTable,
  scatterChart,
}

/// Configuration d'un chart
class ChartConfig {
  final String title;
  final ChartType type;
  final String dataKey;
  final Color color;
  final int xLabelStep;

  const ChartConfig({
    required this.title,
    required this.type,
    required this.dataKey,
    this.color = Colors.blueAccent,
    this.xLabelStep = 1,
  });
}

/// Données pré-calculées pour un chart
class ChartData {
  final ChartType type;
  final String title;

  // Pour BarChart
  final List<BarChartGroupData>? barGroups;

  // Pour PieChart
  final List<PieChartSectionData>? pieSections;

  // Pour LineChart
  final List<FlSpot>? lineSpots;
  final List<Widget>? xLabels;
  final Color? lineColor;
  final int? xLabelStep;

  final Map<String, String>? kpiValues;
  final BenchmarkInfo? benchmarkInfo;
  final List<BenchmarkInfo>? benchmarkComparison;

  final List<ScatterSpot>? scatterSpots;
  final Color? scatterColor;

  ChartData.bar({
    required this.title,
    required this.barGroups,
    this.xLabels,
  })  : type = ChartType.barChart,
        pieSections = null,
        lineSpots = null,
        lineColor = null,
        xLabelStep = null,
        kpiValues = null,
        benchmarkInfo = null,
        benchmarkComparison = null,
        scatterSpots = null,
        scatterColor = null;

  ChartData.pie({
    required this.title,
    required this.pieSections,
  })  : type = ChartType.pieChart,
        barGroups = null,
        lineSpots = null,
        xLabels = null,
        lineColor = null,
        xLabelStep = null,
        kpiValues = null,
        benchmarkInfo = null,
        benchmarkComparison = null,
        scatterSpots = null,
        scatterColor = null;

  ChartData.line({
    required this.title,
    required this.lineSpots,
    required this.xLabels,
    this.lineColor = Colors.blueAccent,
    this.xLabelStep = 1,
  })  : type = ChartType.lineChart,
        barGroups = null,
        pieSections = null,
        kpiValues = null,
        benchmarkInfo = null,
        benchmarkComparison = null,
        scatterSpots = null,
        scatterColor = null;

  ChartData.kpiCards({
    required this.title,
    required this.kpiValues,
  })  : type = ChartType.kpiCards,
        barGroups = null,
        pieSections = null,
        lineSpots = null,
        xLabels = null,
        lineColor = null,
        xLabelStep = null,
        benchmarkInfo = null,
        benchmarkComparison = null,
        scatterSpots = null,
        scatterColor = null;

  ChartData.benchmarkGlobal({
    required this.title,
    required this.benchmarkInfo,
  })  : type = ChartType.benchmarkGlobal,
        barGroups = null,
        pieSections = null,
        lineSpots = null,
        xLabels = null,
        lineColor = null,
        xLabelStep = null,
        kpiValues = null,
        benchmarkComparison = null,
        scatterSpots = null,
        scatterColor = null;

  ChartData.benchmarkComparison({
    required this.title,
    required this.benchmarkComparison,
  })  : type = ChartType.benchmarkComparison,
        barGroups = null,
        pieSections = null,
        lineSpots = null,
        xLabels = null,
        lineColor = null,
        xLabelStep = null,
        kpiValues = null,
        benchmarkInfo = null,
        scatterSpots = null,
        scatterColor = null;

  ChartData.benchmarkRadar({
    required this.title,
    required this.benchmarkInfo,
  })  : type = ChartType.benchmarkRadar,
        barGroups = null,
        pieSections = null,
        lineSpots = null,
        xLabels = null,
        lineColor = null,
        xLabelStep = null,
        kpiValues = null,
        benchmarkComparison = null,
        scatterSpots = null,
        scatterColor = null;

  ChartData.benchmarkTable({
    required this.title,
    required this.benchmarkComparison,
  })  : type = ChartType.benchmarkTable,
        barGroups = null,
        pieSections = null,
        lineSpots = null,
        xLabels = null,
        lineColor = null,
        xLabelStep = null,
        kpiValues = null,
        benchmarkInfo = null,
        scatterSpots = null,
        scatterColor = null;

  ChartData.scatter({
    required this.title,
    required this.scatterSpots,
    this.scatterColor = Colors.blueAccent,
  })  : type = ChartType.scatterChart,
        barGroups = null,
        pieSections = null,
        lineSpots = null,
        xLabels = null,
        lineColor = null,
        xLabelStep = null,
        kpiValues = null,
        benchmarkInfo = null,
        benchmarkComparison = null;
}
