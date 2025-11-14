import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/provider/json_data_provider.dart';

import '../../../../core/ui/widgets/responsive_text.dart';
import '../../../home/data/comparatifs_data.dart';

class ComparisonStatsView extends ConsumerWidget {
  final bool autoScroll;
  final Duration scrollInterval;

  const ComparisonStatsView({
    super.key,
    this.autoScroll = true,
    this.scrollInterval = const Duration(seconds: 5),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(comparaisonsJsonProvider);
    final size = MediaQuery.of(context).size;

    return asyncData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: ResponsiveText.bodyMedium('Erreur: $e')),
      data: (comparatifs) {
        // Hauteur maximale selon l'écran (50% max par exemple)
        final double maxHeight = size.height * 0.5;

        return SizedBox(
          height: maxHeight,
          child: PageView.builder(
            itemCount: comparatifs.length,
            controller: PageController(viewportFraction: 0.9),
            itemBuilder: (context, index) {
              final item = comparatifs[index];
              // Ajustement dynamique : si beaucoup d'éléments, on réduit la hauteur de chaque graphique
              final double graphHeight =
                  (maxHeight / (item.entries.length.clamp(1, 5)));

              return ComparatifCard(
                comparatif: item,
                graphHeight: graphHeight,
              );
            },
          ),
        );
      },
    );
  }
}

class ComparatifCard extends StatelessWidget {
  final Comparatif comparatif;
  final double? graphHeight;

  const ComparatifCard({super.key, required this.comparatif, this.graphHeight});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText.headlineSmall(comparatif.title),
            const SizedBox(height: 8),
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Graphiques'),
                        Tab(text: 'Table'),
                        Tab(text: 'Camembert'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildGraphView(),
                          _buildTableView(),
                          _buildPieChart(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGraphView() {
    return SizedBox(
      height: graphHeight ?? 250, // hauteur dynamique
      child: BarChart(
        BarChartData(
          barGroups: [
            for (var i = 0; i < comparatif.entries.length; i++)
              BarChartGroupData(
                  x: i,
                  barRods: [BarChartRodData(toY: comparatif.entries[i].value)])
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= comparatif.entries.length)
                    return const SizedBox();
                  return ResponsiveText.displaySmall(
                      comparatif.entries[index].label);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableView() {
    return SingleChildScrollView(
      child: DataTable(
        columns: [
          DataColumn(label: ResponsiveText.displaySmall('Label')),
          DataColumn(label: ResponsiveText.displaySmall('Valeur')),
        ],
        rows: comparatif.entries
            .map((e) => DataRow(cells: [
                  DataCell(ResponsiveText.displaySmall(e.label)),
                  DataCell(ResponsiveText.displaySmall(e.value.toString())),
                ]))
            .toList(),
      ),
    );
  }

  Widget _buildPieChart() {
    return SizedBox(
      height: graphHeight ?? 250,
      child: PieChart(
        PieChartData(
          sections: [
            for (final entry in comparatif.entries)
              PieChartSectionData(value: entry.value, title: entry.label)
          ],
        ),
      ),
    );
  }
}
