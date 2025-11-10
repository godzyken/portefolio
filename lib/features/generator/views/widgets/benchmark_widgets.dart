import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:portefolio/constants/benchmark_colors.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

import '../../data/chart_data.dart';

class BenchmarkGlobalWidget extends StatelessWidget {
  final BenchmarkInfo benchmark;
  final ResponsiveInfo info;

  const BenchmarkGlobalWidget({
    super.key,
    required this.benchmark,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(info.isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: BenchmarkColors.darkBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          ResponsiveText.titleLarge(
            benchmark.projectTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: info.isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: info.isMobile ? 16 : 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pie Chart
              SizedBox(
                width: info.isMobile ? 160 : 200,
                height: info.isMobile ? 160 : 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 5,
                    centerSpaceRadius: info.isMobile ? 50 : 60,
                    sections: [
                      PieChartSectionData(
                        value: benchmark.scoreGlobal.toDouble(),
                        color: BenchmarkColors.green,
                        radius: 30,
                        title: '',
                      ),
                      PieChartSectionData(
                        value: (100 - benchmark.scoreGlobal).toDouble(),
                        color: BenchmarkColors.gray,
                        radius: 30,
                        title: '',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: info.isMobile ? 16 : 32),
              // Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveText.displaySmall(
                    '${benchmark.scoreGlobal}/100',
                    style: TextStyle(
                      color: BenchmarkColors.green,
                      fontSize: info.isMobile ? 32 : 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ResponsiveText.bodyMedium(
                    'Score global',
                    style: TextStyle(
                      color: BenchmarkColors.textGray,
                      fontSize: info.isMobile ? 14 : 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BenchmarkComparisonWidget extends StatelessWidget {
  final List<BenchmarkInfo> benchmarks;
  final ResponsiveInfo info;

  const BenchmarkComparisonWidget({
    super.key,
    required this.benchmarks,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    if (benchmarks.isEmpty) return const SizedBox.shrink();

    // Préparer les données pour le bar chart
    final List<BarChartGroupData> barGroups = [];

    // 4 critères : Performances, SEO, Mobile, Sécurité
    for (int i = 0; i < 4; i++) {
      final rods = <BarChartRodData>[];

      // Barre grise pour le maximum
      final maxValues = [30.0, 30.0, 30.0, 10.0];
      rods.add(BarChartRodData(
        toY: maxValues[i],
        color: BenchmarkColors.gridColor,
        width: info.isMobile ? 12 : 16,
      ));

      // Barres colorées pour chaque projet
      for (int j = 0; j < benchmarks.length; j++) {
        final benchmark = benchmarks[j];
        final values = [
          benchmark.performances.toDouble(),
          benchmark.seo.toDouble(),
          benchmark.mobile.toDouble(),
          benchmark.securite.toDouble(),
        ];

        rods.add(BarChartRodData(
          toY: values[i],
          color: BenchmarkColors.getProjectColor(j),
          width: info.isMobile ? 12 : 16,
        ));
      }

      barGroups.add(BarChartGroupData(
        x: i,
        barRods: rods,
        barsSpace: 4,
      ));
    }

    return Container(
      padding: EdgeInsets.all(info.isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: BenchmarkColors.darkBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          ResponsiveText.titleLarge(
            'Comparaison des Critères (${benchmarks.length} projets)',
            style: TextStyle(
              color: Colors.white,
              fontSize: info.isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: info.isMobile ? 16 : 24),
          SizedBox(
            height: info.isMobile ? 300 : 400,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 35,
                barGroups: barGroups,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: BenchmarkColors.gridColor,
                    strokeWidth: 1,
                    dashArray: [3, 3],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final labels = ['Perfs', 'SEO', 'Mobile', 'Sécu'];
                        if (value.toInt() < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[value.toInt()],
                              style: TextStyle(
                                color: BenchmarkColors.textGray,
                                fontSize: info.isMobile ? 10 : 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return ResponsiveText(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: BenchmarkColors.textGray,
                            fontSize: info.isMobile ? 10 : 12,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.black87,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String label = '';
                      if (rodIndex == 0) {
                        label = 'Max: ${rod.toY.toInt()}';
                      } else if (rodIndex <= benchmarks.length) {
                        label =
                            '${benchmarks[rodIndex - 1].projectTitle}: ${rod.toY.toInt()}';
                      }
                      return BarTooltipItem(
                        label,
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // Légende
          SizedBox(height: info.isMobile ? 12 : 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendItem('Maximum', BenchmarkColors.gridColor),
              ...benchmarks.asMap().entries.map((entry) {
                return _buildLegendItem(
                  entry.value.projectTitle,
                  BenchmarkColors.getProjectColor(entry.key),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: BenchmarkColors.textGray,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class BenchmarkRadarWidget extends StatelessWidget {
  final BenchmarkInfo benchmark;
  final ResponsiveInfo info;
  final Color color;

  const BenchmarkRadarWidget({
    super.key,
    required this.benchmark,
    required this.info,
    this.color = BenchmarkColors.purple,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(info.isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: BenchmarkColors.darkBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          ResponsiveText.titleLarge(
            '${benchmark.projectTitle} - Analyse Radar',
            style: TextStyle(
              color: Colors.white,
              fontSize: info.isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: info.isMobile ? 16 : 24),
          SizedBox(
            height: info.isMobile ? 250 : 300,
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                radarBorderData: BorderSide(
                  color: BenchmarkColors.gridColor,
                  width: 2,
                ),
                gridBorderData: BorderSide(
                  color: BenchmarkColors.gridColor,
                  width: 1,
                ),
                tickBorderData: BorderSide(
                  color: BenchmarkColors.gridColor.withValues(alpha: 0.5),
                ),
                tickCount: 4,
                ticksTextStyle: TextStyle(
                  color: BenchmarkColors.textGray,
                  fontSize: 10,
                ),
                radarBackgroundColor: Colors.transparent,
                dataSets: [
                  RadarDataSet(
                    fillColor: color.withValues(alpha: 0.6),
                    borderColor: color,
                    borderWidth: 2,
                    entryRadius: 3,
                    dataEntries: [
                      RadarEntry(value: benchmark.performances.toDouble()),
                      RadarEntry(value: benchmark.seo.toDouble()),
                      RadarEntry(value: benchmark.mobile.toDouble()),
                      RadarEntry(
                          value: benchmark.securite.toDouble() *
                              3), // Normaliser à 30
                    ],
                  ),
                ],
                getTitle: (index, angle) {
                  final labels = ['Perfs', 'SEO', 'Mobile', 'Sécu'];
                  return RadarChartTitle(
                    text: labels[index],
                    angle: angle,
                  );
                },
                titleTextStyle: TextStyle(
                  color: BenchmarkColors.textGray,
                  fontSize: info.isMobile ? 12 : 14,
                ),
                titlePositionPercentageOffset: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BenchmarkTableWidget extends StatelessWidget {
  final List<BenchmarkInfo> benchmarks;
  final ResponsiveInfo info;

  const BenchmarkTableWidget({
    super.key,
    required this.benchmarks,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    if (benchmarks.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(info.isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: BenchmarkColors.darkBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          ResponsiveText.titleLarge(
            'Tableau Récapitulatif (${benchmarks.length} projets)',
            style: TextStyle(
              color: Colors.white,
              fontSize: info.isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: info.isMobile ? 16 : 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                Colors.white.withValues(alpha: 0.05),
              ),
              dataRowColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? BenchmarkColors.purple.withValues(alpha: 0.1)
                    : null;
              }),
              border: TableBorder.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
              columns: [
                DataColumn(
                  label: Text(
                    'Critère',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: info.isMobile ? 12 : 14,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Maximum',
                    style: TextStyle(
                      color: BenchmarkColors.textGray,
                      fontWeight: FontWeight.bold,
                      fontSize: info.isMobile ? 12 : 14,
                    ),
                  ),
                ),
                ...benchmarks.map((b) => DataColumn(
                      label: Text(
                        b.projectTitle.length > 15
                            ? '${b.projectTitle.substring(0, 15)}...'
                            : b.projectTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: info.isMobile ? 12 : 14,
                        ),
                      ),
                    )),
              ],
              rows: [
                _buildDataRow(
                    '⚡ Performances', 30, benchmarks, (b) => b.performances),
                _buildDataRow('🔍 SEO', 30, benchmarks, (b) => b.seo),
                _buildDataRow('📱 Mobile', 30, benchmarks, (b) => b.mobile),
                _buildDataRow(
                    '🛡️ Sécurité', 10, benchmarks, (b) => b.securite),
                _buildTotalRow(benchmarks),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(
    String label,
    int max,
    List<BenchmarkInfo> benchmarks,
    int Function(BenchmarkInfo) getValue,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(
          label,
          style: const TextStyle(color: Colors.white),
        )),
        DataCell(Text(
          max.toString(),
          style: TextStyle(color: BenchmarkColors.textGray),
          textAlign: TextAlign.center,
        )),
        ...benchmarks.asMap().entries.map((entry) {
          return DataCell(Text(
            getValue(entry.value).toString(),
            style: TextStyle(
              color: BenchmarkColors.getProjectColor(entry.key),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ));
        }),
      ],
    );
  }

  DataRow _buildTotalRow(List<BenchmarkInfo> benchmarks) {
    return DataRow(
      color: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.05)),
      cells: [
        const DataCell(Text(
          '📊 SCORE TOTAL',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        )),
        DataCell(Text(
          '100',
          style: TextStyle(
            color: BenchmarkColors.textGray,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        )),
        ...benchmarks.asMap().entries.map((entry) {
          return DataCell(Text(
            entry.value.scoreGlobal.toString(),
            style: TextStyle(
              color: BenchmarkColors.getProjectColor(entry.key),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ));
        }),
      ],
    );
  }
}

class BenchmarkRecommendationsWidget extends StatelessWidget {
  final List<BenchmarkInfo> benchmarks;
  final ResponsiveInfo info;

  const BenchmarkRecommendationsWidget({
    super.key,
    required this.benchmarks,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    if (benchmarks.isEmpty) return const SizedBox.shrink();
    // Limiter à 2 benchmarks maximum pour éviter l'erreur d'index
    final limitedBenchmarks = benchmarks.take(3).toList();

    return Column(
      children: limitedBenchmarks.asMap().entries.map((entry) {
        final gradient = BenchmarkColors.getProjectGradient(entry.key);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: EdgeInsets.all(info.isMobile ? 20 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: gradient[2].withValues(alpha: 0.6),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText.titleMedium(
                  '🎯 ${entry.value.projectTitle}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ..._buildRecommendations(entry.value).map((rec) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec['icon']!,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            rec['text']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Map<String, String>> _buildRecommendations(BenchmarkInfo benchmark) {
    final recommendations = <Map<String, String>>[];

    if (benchmark.seo >= 25) {
      recommendations.add({
        'icon': '✅',
        'text': 'Excellent SEO (${benchmark.seo}/${benchmark.seoMax})'
      });
    }
    if (benchmark.securite >= 8) {
      recommendations.add({
        'icon': '✅',
        'text':
            'Bonne sécurité (${benchmark.securite}/${benchmark.securiteMax})'
      });
    }
    if (benchmark.performances < 20) {
      recommendations.add({
        'icon': '⚠️',
        'text':
            'Performances à améliorer (${benchmark.performances}/${benchmark.performancesMax})'
      });
    }
    if (benchmark.mobile < 25) {
      recommendations.add({
        'icon': '⚠️',
        'text':
            'Optimisation mobile perfectible (${benchmark.mobile}/${benchmark.mobileMax})'
      });
    }
    if (benchmark.securite < 6) {
      recommendations.add({
        'icon': '❌',
        'text':
            'Sécurité critique (${benchmark.securite}/${benchmark.securiteMax})'
      });
    }
    if (benchmark.seo < 20) {
      recommendations.add({
        'icon': '⚠️',
        'text': 'SEO à optimiser (${benchmark.seo}/${benchmark.seoMax})'
      });
    }

    return recommendations;
  }
}
