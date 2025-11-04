import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Représente un type de chart à afficher
enum ChartType {
  barChart,
  pieChart,
  lineChart,
  kpiCards, // NOUVEAU : pour afficher les KPIs simples
}

/// Configuration d'un chart
class ChartConfig {
  final String title;
  final ChartType type;
  final String dataKey; // clé dans resultsMap
  final Color color;
  final int xLabelStep; // pour espacer les labels X

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

  // Pour KPI Cards (NOUVEAU)
  final Map<String, String>? kpiValues;

  ChartData.bar({
    required this.title,
    required this.barGroups,
  })  : type = ChartType.barChart,
        pieSections = null,
        lineSpots = null,
        xLabels = null,
        lineColor = null,
        xLabelStep = null,
        kpiValues = null;

  ChartData.pie({
    required this.title,
    required this.pieSections,
  })  : type = ChartType.pieChart,
        barGroups = null,
        lineSpots = null,
        xLabels = null,
        lineColor = null,
        xLabelStep = null,
        kpiValues = null;

  ChartData.line({
    required this.title,
    required this.lineSpots,
    required this.xLabels,
    this.lineColor = Colors.blueAccent,
    this.xLabelStep = 1,
  })  : type = ChartType.lineChart,
        barGroups = null,
        pieSections = null,
        kpiValues = null;

  // NOUVEAU : constructeur pour KPI Cards
  ChartData.kpiCards({
    required this.title,
    required this.kpiValues,
  })  : type = ChartType.kpiCards,
        barGroups = null,
        pieSections = null,
        lineSpots = null,
        xLabels = null,
        lineColor = null,
        xLabelStep = null;
}

class ChartDataFactory {
  /// Crée les données de tous les charts à partir de resultsMap
  static List<ChartData> createChartsFromResults(
      Map<String, dynamic> resultsMap) {
    final charts = <ChartData>[];

    // 1. KPI Cards (NOUVEAU - en premier pour l'impact visuel)
    if (resultsMap.containsKey('roi') ||
        resultsMap.containsKey('timeSaved') ||
        resultsMap.containsKey('satisfaction')) {
      charts.add(_createKPICards(resultsMap));
    }

    // 2. Ventes (BarChart)
    if (resultsMap.containsKey('ventes') && resultsMap['ventes'] is List) {
      final barData = _createBarChart(resultsMap['ventes'] as List<dynamic>);
      if (barData != null) charts.add(barData);
    }

    // 3. Clients (PieChart)
    if (resultsMap.containsKey('clients') && resultsMap['clients'] is List) {
      final pieData = _createPieChart(
        'Répartition des clients par âge',
        resultsMap['clients'] as List<dynamic>,
      );
      if (pieData != null) charts.add(pieData);
    }

    // 4. Démonstrations (LineChart)
    if (resultsMap.containsKey('demonstrations')) {
      final lineData = _createLineChart(
        'Démonstrations / événements',
        resultsMap['demonstrations'],
        'mois',
        'evenements',
        Colors.orangeAccent,
      );
      if (lineData != null) charts.add(lineData);
    }

    // 5. Vidéos (LineChart)
    if (resultsMap.containsKey('videos')) {
      final lineData = _createLineChart(
        'Audience par publications',
        resultsMap['videos'],
        'titre',
        'vues',
        Colors.greenAccent,
        xLabelStep: 2,
      );
      if (lineData != null) charts.add(lineData);
    }

    // 6. Stock (PieChart)
    if (resultsMap.containsKey('stock')) {
      final pieData = _createPieChart(
        'État du stock',
        resultsMap['stock'],
        labelKey: 'etat',
      );
      if (pieData != null) charts.add(pieData);
    }

    // 7. Diffusions (LineChart)
    if (resultsMap.containsKey('diffusions')) {
      final lineData = _createLineChart(
        'Taux de publications par an',
        resultsMap['diffusions'],
        'annee',
        'musics',
        Colors.blueAccent,
      );
      if (lineData != null) charts.add(lineData);
    }

    // 8. Représentations (LineChart)
    if (resultsMap.containsKey('representations')) {
      final lineData = _createLineChart(
        'Participations aux événements',
        resultsMap['representations'],
        'annee',
        'evenements',
        Colors.purpleAccent,
      );
      if (lineData != null) charts.add(lineData);
    }

    // 9. Followers (PieChart)
    if (resultsMap.containsKey('followers')) {
      final pieData = _createPieChart(
        'Followers par plateforme',
        resultsMap['followers'],
        labelKey: 'plateforme',
      );
      if (pieData != null) charts.add(pieData);
    }

    return charts;
  }

  // NOUVEAU : Créer les KPI Cards
  static ChartData _createKPICards(Map<String, dynamic> resultsMap) {
    final kpis = <String, String>{};

    // Mapping des KPIs avec icônes et formatage
    final kpiConfig = {
      'roi': {'label': '💰 ROI', 'suffix': ''},
      'timeSaved': {'label': '⏰ Temps gagné', 'suffix': ''},
      'clients': {'label': '👥 Utilisateurs', 'suffix': ''},
      'projects': {'label': '🏗️ Projets', 'suffix': ''},
      'satisfaction': {'label': '⭐ Satisfaction', 'suffix': ''},
      'efficiency': {'label': '📈 Efficacité', 'suffix': ''},
      'deployment': {'label': '🚀 Déploiement', 'suffix': ''},
      'compliance': {'label': '✅ Conformité', 'suffix': ''},
    };

    kpiConfig.forEach((key, config) {
      if (resultsMap.containsKey(key)) {
        kpis[config['label']!] = '${resultsMap[key]}${config['suffix']}';
      }
    });

    return ChartData.kpiCards(
      title: '📊 Indicateurs clés de performance',
      kpiValues: kpis,
    );
  }

  static ChartData? _createBarChart(List<dynamic> ventes) {
    if (ventes.isEmpty) return null;

    final barGroups = ventes.asMap().entries.map((entry) {
      final x = entry.key;
      final y = (entry.value['quantite'] as num).toDouble();
      return BarChartGroupData(
        x: x,
        barRods: [BarChartRodData(toY: y, color: Colors.blueAccent)],
      );
    }).toList();

    return ChartData.bar(
      title: 'Ventes par gamme de prix',
      barGroups: barGroups,
    );
  }

  static ChartData? _createPieChart(
    String title,
    List<dynamic> data, {
    String labelKey = 'age',
    String valueKey = 'nombre',
  }) {
    if (data.isEmpty) return null;

    final sections = data.asMap().entries.map((entry) {
      final item = entry.value;
      return PieChartSectionData(
        value: (item[valueKey] as num).toDouble(),
        title: item[labelKey]?.toString() ?? '',
        color: Colors.primaries[entry.key % Colors.primaries.length],
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
      );
    }).toList();

    return ChartData.pie(title: title, pieSections: sections);
  }

  static ChartData? _createLineChart(
    String title,
    List<dynamic> data,
    String xKey,
    String yKey,
    Color color, {
    int xLabelStep = 1,
  }) {
    if (data.isEmpty) return null;

    final spots = data.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        (entry.value[yKey] as num).toDouble(),
      );
    }).toList();

    final labels = data.map((item) {
      return Text(
        item[xKey]?.toString() ?? '',
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      );
    }).toList();

    return ChartData.line(
      title: title,
      lineSpots: spots,
      xLabels: labels,
      lineColor: color,
      xLabelStep: xLabelStep,
    );
  }
}
