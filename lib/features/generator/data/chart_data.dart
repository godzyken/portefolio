import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

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

// Données de benchmark
class BenchmarkInfo {
  final String projectTitle;
  final int scoreGlobal;
  final int performances;
  final int performancesMax;
  final int seo;
  final int seoMax;
  final int mobile;
  final int mobileMax;
  final int securite;
  final int securiteMax;

  const BenchmarkInfo({
    required this.projectTitle,
    required this.scoreGlobal,
    required this.performances,
    this.performancesMax = 30,
    required this.seo,
    this.seoMax = 30,
    required this.mobile,
    this.mobileMax = 30,
    required this.securite,
    this.securiteMax = 10,
  });

  int get total => performances + seo + mobile + securite;
  int get maxTotal => performancesMax + seoMax + mobileMax + securiteMax;

  factory BenchmarkInfo.fromJson(Map<String, dynamic> json) {
    // Parse "79/100" ou juste "79"
    int parseScore(dynamic value) {
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value.split('/').first) ?? 0;
      }
      return 0;
    }

    return BenchmarkInfo(
      projectTitle: json['projectTitle'] ?? '',
      scoreGlobal: parseScore(json['score']),
      performances: parseScore(json['performances']),
      performancesMax: json['performancesMax'] ?? 30,
      seo: parseScore(json['seo']),
      seoMax: json['seoMax'] ?? 30,
      mobile: parseScore(json['mobile']),
      mobileMax: json['mobileMax'] ?? 30,
      securite: parseScore(json['sécurité'] ?? json['securite']),
      securiteMax: json['securiteMax'] ?? 10,
    );
  }
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

class ChartDataFactory {
  static double _parseNumeric(dynamic value) {
    if (value == null) return 0;
    final str = value.toString().replaceAll(RegExp('[^0-9.,-]'), '');
    return double.tryParse(str.replaceAll(',', '.')) ?? 0;
  }

  /// Crée les graphiques liés à l'analyse économique (champ "development")
  static List<ChartData> createChartsFromDevelopment(
      Map<String, dynamic> development) {
    final charts = <ChartData>[];

    // 1️⃣ Synthèse annuelle du ROI (BarChart)
    if (development.containsKey('5_synthese_annuelle')) {
      final synthese = development['5_synthese_annuelle'] as List<dynamic>;
      final barGroups = synthese.asMap().entries.map((entry) {
        final x = entry.key;
        final result = entry.value;
        final y = (result['roi'].toString().replaceAll('%', '')).trim();
        final value = double.tryParse(y) ?? 0;
        return BarChartGroupData(
          x: x,
          barRods: [
            BarChartRodData(
              toY: value,
              color: Colors.greenAccent,
              width: 18,
            )
          ],
        );
      }).toList();

      charts.add(ChartData.bar(
        title: '📈 ROI annuel comparatif',
        barGroups: barGroups,
      ));
    }

    // 2️⃣ Cumul des gains et coûts (LineChart)
    if (development.containsKey('5_synthese_annuelle')) {
      final synthese = development['5_synthese_annuelle'] as List<dynamic>;
      final gains =
          synthese.map((e) => (e['gains'] as num).toDouble()).toList();
      final couts =
          synthese.map((e) => (e['couts'] as num).toDouble()).toList();

      final gainSpots = gains
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList();
      final coutSpots = couts
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList();

      final labels = synthese.map((e) {
        return Text('Année ${e['annee']}',
            style: const TextStyle(color: Colors.white70, fontSize: 12));
      }).toList();

      charts.add(ChartData.line(
        title: '💸 Gains vs Coûts',
        lineSpots: gainSpots,
        xLabels: labels,
        lineColor: Colors.lightGreenAccent,
      ));

      charts.add(ChartData.line(
        title: '💰 Coûts cumulés',
        lineSpots: coutSpots,
        xLabels: labels,
        lineColor: Colors.redAccent,
      ));
    }

    // 3️⃣ KPIs économiques globaux
    if (development.containsKey('6_roi_global')) {
      final roi = development['6_roi_global'] as Map<String, dynamic>;
      final business = development['7_interpretation_business'] ?? {};

      final kpis = <String, double>{
        'ROI 3 ans': _parseNumeric(roi['roi_3_ans']),
        'Gains totaux': _parseNumeric(roi['gains_totaux']),
        'Coûts totaux': _parseNumeric(roi['couts_totaux']),
        'Productivité': _parseNumeric(business['reactivite']),
        'Temps économisé': _parseNumeric(business['temps_economise_total']),
      };

      final colors = [
        Colors.greenAccent,
        Colors.orangeAccent,
        Colors.redAccent,
        Colors.blueAccent,
        Colors.purpleAccent,
      ];

      final scatterSpots = <ScatterSpot>[];
      var i = 0;
      kpis.forEach((label, value) {
        final x = i.toDouble() * 2;
        final y = value;
        scatterSpots.add(
          ScatterSpot(
            x,
            y,
            renderPriority: i,
            dotPainter: FlDotCirclePainter(
              color: colors[i % colors.length],
              radius: (value / 1000).clamp(5, 16),
              strokeWidth: 1.5,
              strokeColor: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        );
        i++;
      });

      charts.add(ChartData.scatter(
        title: '💼 Indicateurs économiques clés',
        scatterSpots: scatterSpots,
        scatterColor: Colors.greenAccent,
      ));
    }

    return charts;
  }

  /// Crée les données de tous les charts à partir de resultsMap
  static List<ChartData> createChartsFromResults(
      Map<String, dynamic> resultsMap) {
    final charts = <ChartData>[];

    if (resultsMap.containsKey('benchmark')) {
      charts.addAll(_createBenchmarkCharts(resultsMap['benchmark']));
    }

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
      final pieData = _createPieChart('Répartition des clients par âge',
          resultsMap['clients'] as List<dynamic>,
          labelKey: 'age', valueKey: 'nombre');
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
          'Followers par plateforme', resultsMap['followers'],
          labelKey: 'plateforme', valueKey: 'nombre');
      if (pieData != null) charts.add(pieData);
    }

    return charts;
  }

  static List<ChartData> _createBenchmarkCharts(dynamic benchmarkData) {
    final charts = <ChartData>[];

    // Si c'est un seul benchmark
    if (benchmarkData is Map<String, dynamic>) {
      final info = BenchmarkInfo.fromJson(benchmarkData);

      final barGroups = [
        BarChartGroupData(x: 0, barRods: [
          BarChartRodData(
              toY: info.performances.toDouble(), color: Colors.greenAccent)
        ]),
        BarChartGroupData(x: 1, barRods: [
          BarChartRodData(toY: info.seo.toDouble(), color: Colors.blueAccent)
        ]),
        BarChartGroupData(x: 2, barRods: [
          BarChartRodData(
              toY: info.mobile.toDouble(), color: Colors.orangeAccent)
        ]),
        BarChartGroupData(x: 3, barRods: [
          BarChartRodData(
              toY: info.securite.toDouble(), color: Colors.redAccent)
        ]),
      ];

      // Score global avec pie chart
      charts.add(ChartData.benchmarkGlobal(
        title: '📊 Score Global - ${info.projectTitle}',
        benchmarkInfo: info,
      ));

      charts.add(ChartData.bar(
        title: '📊 Performances globales -  ${info.projectTitle}',
        barGroups: barGroups,
      ));

      // Radar chart
      charts.add(ChartData.benchmarkRadar(
        title: '🎯 Analyse Détaillée',
        benchmarkInfo: info,
      ));
    }

    // Si c'est une liste de benchmarks (pour comparaison)
    if (benchmarkData is List) {
      final infos = benchmarkData
          .map((item) => BenchmarkInfo.fromJson(item as Map<String, dynamic>))
          .toList();

      if (infos.isNotEmpty) {
        // Comparaison par critères
        charts.add(ChartData.benchmarkComparison(
          title: '📊 Comparaison des Critères',
          benchmarkComparison: infos,
        ));

        // Tableau récapitulatif
        charts.add(ChartData.benchmarkTable(
          title: '📋 Tableau Récapitulatif',
          benchmarkComparison: infos,
        ));
      }
    }

    return charts;
  }

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

    final mix = ColorHelpers.chartColors;

    final pieSections = kpis.entries.toList().asMap().entries.map((entry) {
      final i = entry.key;
      final key = entry.value.key;
      final val = entry.value.value;
      final color = mix[i % mix.length];
      final numeric = _parseNumeric(val);
      return PieChartSectionData(
        value: numeric == 0 ? 1 : numeric,
        title: key,
        color: color.withValues(alpha: 0.8),
        radius: 55,
        showTitle: false,
      );
    }).toList();

    return ChartData.pie(
      title: '📊 Indicateurs clés de performance',
      pieSections: pieSections,
    );
  }

  static ChartData? _createBarChart(List<dynamic> ventes) {
    if (ventes.isEmpty) return null;

    // Génère les BarGroups et les labels associés
    final barGroups = <BarChartGroupData>[];
    final labels = <String>[];

    final uniqueLabels = labels.toSet().toList();

    for (var i = 0; i < ventes.length; i++) {
      final item = ventes[i];
      final quantite = (item['quantite'] as num?)?.toDouble() ?? 0.0;
      final label = item['gamme']?.toString() ??
          item['label']?.toString() ??
          'Catégorie ${i + 1}';

      labels.add(label);

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: quantite,
              color: Colors.blueAccent,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    // ➜ On stocke les labels dans ChartData via xLabels (widgets)
    final xLabels = uniqueLabels
        .map(
          (label) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: ResponsiveText.bodySmall(
              label.isEmpty ? 'N/A' : label,
              style: const TextStyle(
                color: Colors.white70,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
          ),
        )
        .toList();

    return ChartData.bar(
      // ⚠️ on va créer une version bar étendue
      title: '📦 Ventes par gamme de prix',
      barGroups: barGroups, // placeholder, pas utilisé ici
      xLabels: xLabels,
    );
  }

  static ChartData? _createPieChart(
    String title,
    List<dynamic> data, {
    String labelKey = 'age',
    String valueKey = 'nombre',
  }) {
    if (data.isEmpty) return null;
    final mix = ColorHelpers.chartColors;

    final sections = data.asMap().entries.map((entry) {
      final item = entry.value;
      final color = mix[entry.key % mix.length];
      final label = item[labelKey]?.toString() ?? '';

      return PieChartSectionData(
        value: (item[valueKey] as num).toDouble(),
        title: label,
        color: color.withValues(alpha: 0.8),
        radius: 60,
        showTitle: false,
        borderSide: BorderSide(color: color, width: 2),
        badgePositionPercentageOffset: 1.4,
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

    // 🔹 On filtre les doublons et on garde la première occurrence
    final seen = <String>{};
    final filteredData = data.where((item) {
      final label = item[xKey]?.toString() ?? '';
      if (seen.contains(label)) return false;
      seen.add(label);
      return true;
    }).toList();

    final spots = filteredData.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        (entry.value[yKey] as num).toDouble(),
      );
    }).toList();

    final labels = filteredData.map((item) {
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
