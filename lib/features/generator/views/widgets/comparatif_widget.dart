import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/provider/json_data_provider.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/ui/widgets/responsive_text.dart';
import '../../../home/data/comparatifs_data.dart';

class ComparisonStatsView extends ConsumerStatefulWidget {
  const ComparisonStatsView({super.key});

  @override
  ConsumerState<ComparisonStatsView> createState() =>
      _ComparisonStatsViewState();
}

class _ComparisonStatsViewState extends ConsumerState<ComparisonStatsView> {
  late final PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(comparaisonsJsonProvider);
    final info = ref.watch(responsiveInfoProvider);

    return asyncData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
      data: (comparatifs) => AspectRatio(
        aspectRatio: info.isMobile ? 1.2 : 1.8,
        child: PageView.builder(
          controller: controller,
          itemCount: comparatifs.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                double value = 1.0;

                if (controller.position.haveDimensions) {
                  value = (controller.page! - index).abs();
                  value = (1 - (value * 0.3)).clamp(0.8, 1.0);
                }

                return Transform.scale(
                  scale: Curves.easeOut.transform(value),
                  child: child,
                );
              },
              child: ComparatifCard(comparatif: comparatifs[index]),
            );
          },
        ),
      ),
    );
  }
}

class ComparatifCard extends StatelessWidget {
  final Comparatif comparatif;

  const ComparatifCard({super.key, required this.comparatif});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText.headlineSmall(comparatif.title),
            const SizedBox(height: 8),
            Flexible(
              fit: FlexFit.loose,
              child: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Barres'),
                        Tab(text: 'Radar'),
                        Tab(text: 'Table'),
                        Tab(text: 'Recommendation'),
                      ],
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: TabBarView(
                        children: [
                          _buildBarChart(comparatif),
                          _buildRadarChart(comparatif),
                          _buildTableView(comparatif),
                          _buildRecommendation(comparatif),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Bar Chart ----------
  Widget _buildBarChart(Comparatif comparatif) {
    final barGroups = comparatif.categories
        .asMap()
        .entries
        .map(
          (entry) => BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                  toY: entry.value.scoreFlutter.toDouble(), color: Colors.blue),
              BarChartRodData(
                  toY: entry.value.scoreReactNative.toDouble(),
                  color: Colors.green),
            ],
          ),
        )
        .toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          titlesData: FlTitlesData(
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= comparatif.categories.length) {
                    return const SizedBox();
                  }

                  return Transform.rotate(
                      angle: -0.5,
                      child: ResponsiveText.bodySmall(
                          comparatif.categories[index].name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true),
                axisNameWidget: const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: ResponsiveText.bodySmall('Score'),
                ),
                drawBelowEverything: true,
                axisNameSize: double.minPositive),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  // ---------- Radar Chart ----------
  Widget _buildRadarChart(Comparatif comparatif) {
    final categories = comparatif.categories.map((e) => e.name).toList();
    final flutterScores =
        comparatif.categories.map((e) => e.scoreFlutter.toDouble()).toList();
    final reactScores = comparatif.categories
        .map((e) => e.scoreReactNative.toDouble())
        .toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              dataEntries:
                  flutterScores.map((s) => RadarEntry(value: s)).toList(),
              borderColor: Colors.blue,
              fillColor: Colors.blue.withValues(alpha: 0.3),
              entryRadius: 3,
            ),
            RadarDataSet(
              dataEntries:
                  reactScores.map((s) => RadarEntry(value: s)).toList(),
              borderColor: Colors.green,
              fillColor: Colors.green.withValues(alpha: 0.3),
              entryRadius: 3,
            ),
          ],
          radarBackgroundColor: Colors.transparent,
          titleTextStyle: const TextStyle(fontSize: 12),
          getTitle: (index, angle) {
            // Retourne un RadarChartTitle pour chaque index
            return RadarChartTitle(
              text: categories[index],
              angle: angle,
            );
          },
          tickCount: 5,
        ),
      ),
    );
  }

  // ---------- Table View ----------
  Widget _buildTableView(Comparatif comparatif) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: ResponsiveText.bodySmall('Catégorie')),
          DataColumn(label: ResponsiveText.bodySmall('Flutter')),
          DataColumn(label: ResponsiveText.bodySmall('React Native')),
        ],
        rows: comparatif.categories
            .map(
              (c) => DataRow(
                cells: [
                  DataCell(ResponsiveText.bodySmall(c.name)),
                  DataCell(ResponsiveText.bodySmall('${c.scoreFlutter}')),
                  DataCell(ResponsiveText.bodySmall('${c.scoreReactNative}')),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  // ---------- Recommendation ----------
  Widget _buildRecommendation(Comparatif comparatif) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText.headlineSmall('Recommendation'),
          const SizedBox(height: 8),
          ResponsiveText.bodyMedium(comparatif.recommendation.summary),
          const SizedBox(height: 8),
          ...comparatif.recommendation.details.map((d) => Row(
                children: [
                  const Icon(Icons.check, color: Colors.green, size: 16),
                  const SizedBox(width: 6),
                  Expanded(child: ResponsiveText.bodySmall(d)),
                ],
              )),
        ],
      ),
    );
  }
}
