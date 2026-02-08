import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';

/// Factory corrigé pour EMAP Services et tous les projets
class ChartDataFactory {
  /// Crée tous les charts à partir de resultsMap
  static List<ChartData> createChartsFromResults(
      Map<String, dynamic> resultsMap) {
    final List<ChartData> charts = [];

    // 1. Extraire les KPI scalaires
    final kpiValues = _extractKPIValues(resultsMap);
    if (kpiValues.isNotEmpty) {
      charts.add(ChartData.kpiCards(
        title: 'Indicateurs clés de performance',
        kpiValues: kpiValues,
      ));
    }

    // 2. Gérer les démonstrations (Line Chart)
    if (resultsMap.containsKey('demonstrations')) {
      final demoChart =
          _createDemonstrationsChart(resultsMap['demonstrations']);
      if (demoChart != null) charts.add(demoChart);
    }

    // 3. Gérer les vidéos (Bar Chart)
    if (resultsMap.containsKey('videos')) {
      final videoChart = _createVideosChart(resultsMap['videos']);
      if (videoChart != null) charts.add(videoChart);
    }

    // 4. Gérer les ventes (si présentes)
    if (resultsMap.containsKey('ventes')) {
      final salesChart = _createSalesChart(resultsMap['ventes']);
      if (salesChart != null) charts.add(salesChart);
    }

    // 5. Gérer les clients par âge (Pie Chart)
    if (resultsMap.containsKey('clients')) {
      final clientsChart = _createClientsChart(resultsMap['clients']);
      if (clientsChart != null) charts.add(clientsChart);
    }

    // 6. Gérer les followers (si présentes)
    if (resultsMap.containsKey('followers')) {
      final followersChart = _createFollowersChart(resultsMap['followers']);
      if (followersChart != null) charts.add(followersChart);
    }

    // 7. Gérer les diffusions (si présentes)
    if (resultsMap.containsKey('diffusions')) {
      final diffusionsChart = _createDiffusionsChart(resultsMap['diffusions']);
      if (diffusionsChart != null) charts.add(diffusionsChart);
    }

    // 8. Gérer le stock (si présent)
    if (resultsMap.containsKey('stock')) {
      final stockChart = _createStockChart(resultsMap['stock']);
      if (stockChart != null) charts.add(stockChart);
    }

    // 9. Gérer les benchmarks
    if (resultsMap.containsKey('benchmark')) {
      final benchmarkData = resultsMap['benchmark'];

      // Vérifier si c'est un benchmark unique ou une comparaison
      if (benchmarkData is Map<String, dynamic>) {
        // Benchmark unique
        final benchmark = BenchmarkInfo.fromJson(benchmarkData);
        charts.add(ChartData.benchmarkGlobal(
          title: 'Score de performance global',
          benchmarkInfo: benchmark,
        ));

        charts.add(ChartData.benchmarkRadar(
          title: 'Analyse radar des critères',
          benchmarkInfo: benchmark,
        ));
      } else if (benchmarkData is List) {
        // Comparaison de benchmarks
        final benchmarks = benchmarkData
            .map((b) => BenchmarkInfo.fromJson(b as Map<String, dynamic>))
            .toList();

        charts.add(ChartData.benchmarkComparison(
          title: 'Comparaison des performances',
          benchmarkComparison: benchmarks,
        ));

        charts.add(ChartData.benchmarkTable(
          title: 'Tableau détaillé des scores',
          benchmarkComparison: benchmarks,
        ));
      }
    }

    return charts;
  }

  /// Extrait les valeurs KPI scalaires (chaînes et nombres)
  static Map<String, String> _extractKPIValues(
      Map<String, dynamic> resultsMap) {
    final kpis = <String, String>{};

    // Clés KPI connues (étendre selon les besoins)
    const kpiKeys = {
      'roi': 'ROI',
      'timeSaved': 'Temps gagné',
      'clients': 'Clients',
      'messages': 'Messages/mois',
      'satisfaction': 'Satisfaction',
      'efficiency': 'Efficacité',
      'deployment': 'Déploiement',
      'compliance': 'Conformité',
      'pagesVisited': 'Pages visitées',
      'pdfGenerated': 'PDF générés',
      'sessionsTawk': 'Sessions chat',
      'iotUpdates': 'Mises à jour IoT',
      'visualizations3D': 'Visualisations 3D',
      'projects': 'Projets',
      'gainCA': 'Gain CA',
    };

    for (final entry in resultsMap.entries) {
      // Ignorer les listes et objets complexes
      if (entry.value is List || entry.value is Map) continue;

      // Convertir en string
      final label = kpiKeys[entry.key] ?? _formatKey(entry.key);
      kpis[label] = entry.value.toString();
    }

    return kpis;
  }

  /// Crée un Line Chart pour les démonstrations
  static ChartData? _createDemonstrationsChart(dynamic data) {
    if (data is! List || data.isEmpty) return null;

    final spots = <FlSpot>[];
    final labels = <Widget>[];

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      if (item is! Map) continue;

      final evenements = _parseNumber(item['evenements']);
      spots.add(FlSpot(i.toDouble(), evenements));

      final label =
          item['mois']?.toString() ?? item['annee']?.toString() ?? 'M$i';
      labels.add(_buildLabel(label));
    }

    if (spots.isEmpty) return null;

    return ChartData.line(
      title: 'Évolution des démonstrations',
      lineSpots: spots,
      xLabels: labels,
      lineColor: Colors.greenAccent,
      xLabelStep: 1,
    );
  }

  /// Crée un Bar Chart pour les vidéos
  static ChartData? _createVideosChart(dynamic data) {
    if (data is! List || data.isEmpty) return null;

    final barGroups = <BarChartGroupData>[];
    final labels = <Widget>[];

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      if (item is! Map) continue;

      final vues = _parseNumber(item['vues']);

      barGroups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: vues,
            color: Colors.purpleAccent,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ));

      final titre = item['titre']?.toString() ?? 'Video $i';
      labels.add(_buildLabel(titre, maxLength: 15));
    }

    if (barGroups.isEmpty) return null;

    return ChartData.bar(
      title: 'Vues des vidéos',
      barGroups: barGroups,
      xLabels: labels,
    );
  }

  /// Crée un Bar Chart pour les ventes
  static ChartData? _createSalesChart(dynamic data) {
    if (data is! List || data.isEmpty) return null;

    final barGroups = <BarChartGroupData>[];
    final labels = <Widget>[];

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      if (item is! Map) continue;

      final quantite = _parseNumber(item['quantite']);

      barGroups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: quantite,
            color: Colors.blueAccent,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ));

      final gamme = item['gamme']?.toString() ?? 'Gamme $i';
      labels.add(_buildLabel(gamme));
    }

    if (barGroups.isEmpty) return null;

    return ChartData.bar(
      title: 'Ventes par gamme de prix',
      barGroups: barGroups,
      xLabels: labels,
    );
  }

  /// Crée un Pie Chart pour les clients
  static ChartData? _createClientsChart(dynamic data) {
    if (data is! List || data.isEmpty) return null;

    final sections = <PieChartSectionData>[];
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      if (item is! Map) continue;

      final nombre = _parseNumber(item['nombre']);
      final age =
          item['age']?.toString() ?? item['plateforme']?.toString() ?? 'Cat $i';

      sections.add(PieChartSectionData(
        value: nombre,
        title: age,
        color: colors[i % colors.length],
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }

    if (sections.isEmpty) return null;

    return ChartData.pie(
      title: 'Répartition des clients',
      pieSections: sections,
    );
  }

  /// Crée un Bar Chart pour les followers
  static ChartData? _createFollowersChart(dynamic data) {
    if (data is! List || data.isEmpty) return null;

    final barGroups = <BarChartGroupData>[];
    final labels = <Widget>[];

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      if (item is! Map) continue;

      final nombre = _parseNumber(item['nombre']);

      barGroups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: nombre,
            color: Colors.cyanAccent,
            width: 18,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ));

      final plateforme = item['plateforme']?.toString() ?? 'Platform $i';
      labels.add(_buildLabel(plateforme));
    }

    if (barGroups.isEmpty) return null;

    return ChartData.bar(
      title: 'Followers par plateforme',
      barGroups: barGroups,
      xLabels: labels,
    );
  }

  /// Crée un Line Chart pour les diffusions
  static ChartData? _createDiffusionsChart(dynamic data) {
    if (data is! List || data.isEmpty) return null;

    final spots = <FlSpot>[];
    final labels = <Widget>[];

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      if (item is! Map) continue;

      final musics = _parseNumber(item['musics']);
      spots.add(FlSpot(i.toDouble(), musics));

      final annee = item['annee']?.toString() ?? '$i';
      labels.add(_buildLabel(annee));
    }

    if (spots.isEmpty) return null;

    return ChartData.line(
      title: 'Diffusions musicales par année',
      lineSpots: spots,
      xLabels: labels,
      lineColor: Colors.orangeAccent,
      xLabelStep: 1,
    );
  }

  /// Crée un Pie Chart pour le stock
  static ChartData? _createStockChart(dynamic data) {
    if (data is! List || data.isEmpty) return null;

    final sections = <PieChartSectionData>[];

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      if (item is! Map) continue;

      final nombre = _parseNumber(item['nombre']);
      final etat = item['etat']?.toString() ?? 'État $i';

      sections.add(PieChartSectionData(
        value: nombre,
        title: '$etat\n$nombre',
        color: etat.toLowerCase() == 'disponible' ? Colors.green : Colors.red,
        radius: 70,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }

    if (sections.isEmpty) return null;

    return ChartData.pie(
      title: 'État du stock',
      pieSections: sections,
    );
  }

  // === HELPERS ===

  static double _parseNumber(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      // Gérer les formats comme "2.5k", "300+", etc.
      final cleaned = value
          .replaceAll('+', '')
          .replaceAll('k', '000')
          .replaceAll('K', '000')
          .replaceAll('M', '000000');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  static Widget _buildLabel(String text, {int maxLength = 20}) {
    final truncated =
        text.length > maxLength ? '${text.substring(0, maxLength)}...' : text;

    return Text(
      truncated,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 10,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  static String _formatKey(String key) {
    // Convertir camelCase en Title Case avec espaces
    final words = key
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .trim()
        .split(' ');

    return words
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }
}
