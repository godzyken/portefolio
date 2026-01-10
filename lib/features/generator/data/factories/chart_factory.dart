import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';

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
              color: ColorHelpers.getColorForIndex(x),
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
        return ResponsiveText.titleSmall('Année ${e['annee']}',
            style: const TextStyle(color: Colors.white70));
      }).toList();

      charts.add(ChartData.line(
        title: '💸 Gains vs Coûts',
        lineSpots: gainSpots,
        xLabels: labels,
        lineColor: ColorHelpers.getColorForIndex(2),
      ));

      charts.add(ChartData.line(
        title: '💰 Coûts cumulés',
        lineSpots: coutSpots,
        xLabels: labels,
        lineColor: ColorHelpers.getColorForIndex(3),
      ));
    }

    // 3️⃣ Répartition des gains (PieChart)
    if (development.containsKey('3_autres_gains')) {
      final gains = development['3_autres_gains'] as Map<String, dynamic>;
      final data = gains.entries
          .where((e) => e.key != 'total')
          .map((e) => {
                'label': e.key.replaceAll('_', ' '),
                'valeur': _parseNumeric(e.value)
              })
          .toList();

      final sections = data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final color = ColorHelpers.getColorForIndex(index);
        return PieChartSectionData(
          value: (item['valeur'] as num?)?.toDouble() ?? 0,
          title: item['label'].toString(),
          color: color.withValues(alpha: 0.85),
          radius: 45,
          showTitle: true,
        );
      }).toList();

      charts.add(ChartData.pie(
        title: '💡 Répartition des gains',
        pieSections: sections,
      ));
    }

    // 4️⃣ Répartition des coûts (BarChart)
    if (development.containsKey('4_couts')) {
      final couts = development['4_couts'] as Map<String, dynamic>;
      final data = couts.entries
          .map((e) => {
                'label': e.key.replaceAll('_', ' '),
                'valeur': _parseNumeric(e.value)
              })
          .toList();

      final barGroups = data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: (item['valeur'] as num?)?.toDouble() ?? 0,
              color: ColorHelpers.getColorForIndex(index),
              width: 18,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        );
      }).toList();

      final xLabels = data
          .map((e) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: ResponsiveText.bodySmall(
                  e['label'].toString(),
                  style: const TextStyle(color: Colors.white70),
                  maxLines: 1,
                ),
              ))
          .toList();

      charts.add(ChartData.bar(
        title: '🏗️ Répartition des coûts',
        barGroups: barGroups,
        xLabels: xLabels,
      ));
    }

    // 5️⃣ KPIs économiques globaux
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

      final scatterSpots = <ScatterSpot>[];
      var i = 0;
      kpis.forEach((label, value) {
        scatterSpots.add(
          ScatterSpot(
            i.toDouble() * 2,
            value,
            renderPriority: i,
            dotPainter: FlDotCirclePainter(
              color: ColorHelpers.getColorForIndex(i),
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
        scatterColor: ColorHelpers.getColorForIndex(5),
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

    // 1. KPI Cards
    if (resultsMap.keys
        .any((k) => ['roi', 'timeSaved', 'satisfaction'].contains(k))) {
      charts.add(_createKPICards(resultsMap));
    }

    // 2. Ventes (BarChart)
    if (resultsMap['ventes'] is List<Map<String, dynamic>>) {
      final barData = _createBarChart(resultsMap['ventes']);
      if (barData != null) charts.add(barData);
    }

    // 3. Clients (PieChart)
    if (resultsMap['clients'] is List<Map<String, dynamic>>) {
      final pieData = _createPieChart(
        'Répartition des clients par âge',
        resultsMap['clients'],
        labelKey: 'age',
        valueKey: 'nombre',
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
              toY: info.performances.toDouble(),
              color: ColorHelpers.getColorForIndex(0))
        ]),
        BarChartGroupData(x: 1, barRods: [
          BarChartRodData(
              toY: info.seo.toDouble(), color: ColorHelpers.getColorForIndex(1))
        ]),
        BarChartGroupData(x: 2, barRods: [
          BarChartRodData(
              toY: info.mobile.toDouble(),
              color: ColorHelpers.getColorForIndex(2))
        ]),
        BarChartGroupData(x: 3, barRods: [
          BarChartRodData(
              toY: info.securite.toDouble(),
              color: ColorHelpers.getColorForIndex(3))
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
        radius: 45,
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
              color: ColorHelpers.getColorForIndex(i),
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
                color: ColorHelpers.textGray,
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
        radius: 30,
        showTitle: true,
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
      return ResponsiveText.bodySmall(
        item[xKey]?.toString() ?? '',
        style: const TextStyle(color: Colors.white70),
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
