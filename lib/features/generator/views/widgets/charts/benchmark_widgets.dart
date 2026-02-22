import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';

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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorHelpers.darkBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ResponsiveText.titleSmall(
            benchmark.projectTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Pie chart score
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 32,
                    sections: [
                      PieChartSectionData(
                        value: benchmark.scoreGlobal.toDouble(),
                        color: ColorHelpers.green,
                        radius: 18,
                        title: '',
                      ),
                      PieChartSectionData(
                        value: (100 - benchmark.scoreGlobal).toDouble(),
                        color: ColorHelpers.gray.withValues(alpha: 0.3),
                        radius: 18,
                        title: '',
                      ),
                    ],
                  ),
                ),
                Text(
                  '${benchmark.scoreGlobal}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Score: ${benchmark.scoreGlobal}/100',
            style: TextStyle(
              color: ColorHelpers.green,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Text(
            'Score global',
            style: TextStyle(
              color: ColorHelpers.textGray,
              fontSize: 11,
            ),
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

    // Critères avec max
    final criteria = [
      _Criterion('Perfs', 30, (b) => b.performances),
      _Criterion('SEO', 30, (b) => b.seo),
      _Criterion('Mobile', 30, (b) => b.mobile),
      _Criterion('Sécu', 10, (b) => b.securite),
    ];

    return Container(
      padding: EdgeInsets.all(info.isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: ColorHelpers.darkBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparaison des critères',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: info.isMobile ? 13 : 15,
            ),
          ),
          const SizedBox(height: 12),

          // Légende projets
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: benchmarks.asMap().entries.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: ColorHelpers.getProjectColor(e.key),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    e.value.projectTitle.length > 12
                        ? '${e.value.projectTitle.substring(0, 12)}…'
                        : e.value.projectTitle,
                    style: TextStyle(
                      color: ColorHelpers.textGray,
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Barres horizontales par critère — plus lisibles que des barres verticales
          ...criteria.map((criterion) =>
              _CriterionRow(criterion: criterion, benchmarks: benchmarks)),
        ],
      ),
    );
  }
}

class _Criterion {
  final String label;
  final int max;
  final int Function(BenchmarkInfo) getValue;
  const _Criterion(this.label, this.max, this.getValue);
}

class _CriterionRow extends StatelessWidget {
  final _Criterion criterion;
  final List<BenchmarkInfo> benchmarks;

  const _CriterionRow({
    required this.criterion,
    required this.benchmarks,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                width: 52,
                child: Text(
                  criterion.label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '/${criterion.max}',
                style: TextStyle(color: ColorHelpers.textGray, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Une barre par projet
          ...benchmarks.asMap().entries.map((entry) {
            final value = criterion.getValue(entry.value);
            final ratio = value / criterion.max;
            final color = ColorHelpers.getProjectColor(entry.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                children: [
                  // Barre
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: ratio.clamp(0.0, 1.0),
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Valeur
                  SizedBox(
                    width: 22,
                    child: Text(
                      '$value',
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
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
    this.color = ColorHelpers.purple,
  });

  @override
  Widget build(BuildContext context) {
    final size = info.isMobile ? 180.0 : 220.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorHelpers.darkBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            benchmark.projectTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: size,
            height: size,
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                radarBorderData: BorderSide(
                  color: ColorHelpers.gridColor,
                  width: 1.5,
                ),
                gridBorderData: BorderSide(
                  color: ColorHelpers.gridColor,
                  width: 1,
                ),
                tickBorderData: BorderSide(
                  color: ColorHelpers.gridColor.withValues(alpha: 0.5),
                ),
                tickCount: 3,
                ticksTextStyle: TextStyle(
                  color: ColorHelpers.textGray,
                  fontSize: 9,
                ),
                radarBackgroundColor: Colors.transparent,
                dataSets: [
                  RadarDataSet(
                    fillColor: color.withValues(alpha: 0.5),
                    borderColor: color,
                    borderWidth: 2,
                    entryRadius: 3,
                    dataEntries: [
                      RadarEntry(value: benchmark.performances.toDouble()),
                      RadarEntry(value: benchmark.seo.toDouble()),
                      RadarEntry(value: benchmark.mobile.toDouble()),
                      RadarEntry(value: benchmark.securite.toDouble() * 3),
                    ],
                  ),
                ],
                getTitle: (index, angle) {
                  const labels = ['Perfs', 'SEO', 'Mobile', 'Sécu'];
                  return RadarChartTitle(
                    text: labels[index],
                    angle: angle,
                  );
                },
                titleTextStyle: TextStyle(
                  color: ColorHelpers.textGray,
                  fontSize: info.isMobile ? 11 : 13,
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
      padding: EdgeInsets.all(info.isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: ColorHelpers.darkBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tableau récapitulatif',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: info.isMobile ? 13 : 15,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildTable(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    final criteria = [
      ('⚡ Performances', 30, (BenchmarkInfo b) => b.performances),
      ('🔍 SEO', 30, (BenchmarkInfo b) => b.seo),
      ('📱 Mobile', 30, (BenchmarkInfo b) => b.mobile),
      ('🛡️ Sécurité', 10, (BenchmarkInfo b) => b.securite),
    ];

    const headerStyle = TextStyle(
      color: Colors.white70,
      fontWeight: FontWeight.bold,
      fontSize: 11,
    );
    const cellStyle = TextStyle(color: Colors.white, fontSize: 11);
    const maxStyle = TextStyle(color: Colors.white38, fontSize: 11);

    return Table(
      border: TableBorder.all(
        color: Colors.white.withValues(alpha: 0.08),
        width: 1,
        borderRadius: BorderRadius.circular(8),
      ),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
          ),
          children: [
            _cell('Critère', headerStyle, isHeader: true),
            _cell('Max', maxStyle, isHeader: true),
            ...benchmarks.map((b) => _cell(
                  b.projectTitle.length > 10
                      ? '${b.projectTitle.substring(0, 10)}…'
                      : b.projectTitle,
                  headerStyle,
                  isHeader: true,
                )),
          ],
        ),
        // Data rows
        ...criteria.map((row) {
          final (label, max, getValue) = row;
          return TableRow(
            children: [
              _cell(label, cellStyle),
              _cell('$max', maxStyle),
              ...benchmarks.asMap().entries.map((entry) {
                final value = getValue(entry.value);
                return _cell(
                  '$value',
                  TextStyle(
                    color: ColorHelpers.getProjectColor(entry.key),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                );
              }),
            ],
          );
        }),
        // Total row
        TableRow(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
          ),
          children: [
            _cell('📊 TOTAL', headerStyle),
            _cell('100', maxStyle),
            ...benchmarks.asMap().entries.map((entry) => _cell(
                  '${entry.value.scoreGlobal}',
                  TextStyle(
                    color: ColorHelpers.getProjectColor(entry.key),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                )),
          ],
        ),
      ],
    );
  }

  Widget _cell(String text, TextStyle style, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Text(text, style: style),
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
    final limited = benchmarks.take(3).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: limited.asMap().entries.map((entry) {
        final color = ColorHelpers.getProjectColor(entry.key);
        final recs = _buildRecommendations(entry.value);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🎯 ${entry.value.projectTitle}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              ...recs.map((rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rec['icon']!,
                            style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            rec['text']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Map<String, String>> _buildRecommendations(BenchmarkInfo b) {
    final recs = <Map<String, String>>[];
    if (b.seo >= 25) {
      recs.add({'icon': '✅', 'text': 'Excellent SEO (${b.seo}/${b.seoMax})'});
    }
    if (b.securite >= 8) {
      recs.add({
        'icon': '✅',
        'text': 'Bonne sécurité (${b.securite}/${b.securiteMax})'
      });
    }
    if (b.performances < 20) {
      recs.add({
        'icon': '⚠️',
        'text':
            'Performances à améliorer (${b.performances}/${b.performancesMax})'
      });
    }
    if (b.mobile < 25) {
      recs.add({
        'icon': '⚠️',
        'text': 'Optimisation mobile (${b.mobile}/${b.mobileMax})'
      });
    }
    if (b.securite < 6) {
      recs.add({
        'icon': '❌',
        'text': 'Sécurité critique (${b.securite}/${b.securiteMax})'
      });
    }
    if (b.seo < 20) {
      recs.add(
          {'icon': '⚠️', 'text': 'SEO à optimiser (${b.seo}/${b.seoMax})'});
    }
    return recs;
  }
}
