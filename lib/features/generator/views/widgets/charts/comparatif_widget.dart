import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/provider/json_data_provider.dart';

import '../../../../../core/affichage/screen_size_detector.dart';
import '../../../../../core/ui/widgets/responsive_text.dart';
import '../../../../home/data/comparatifs_data.dart';

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
    final info = ref.watch(responsiveInfoProvider);

    return Padding(
      padding: EdgeInsets.only(
          left: _getSpacing(info, medium: 16, large: 24),
          top: _getSpacing(info, medium: 16, large: 24)),
      child: _buildComparativeDialogButton(context, info),
    );
  }

  Widget _buildComparativeDialogButton(
      BuildContext context, ResponsiveInfo info) {
    // Une taille d'icône bien visible
    final size = info.isMobile ? 36.0 : 48.0;

    return Tooltip(
      message: "Pourquoi Flutter ?",
      preferBelow: false,
      triggerMode: TooltipTriggerMode.tap,
      child: InkWell(
        onTap: () {
          Future.microtask(() {
            if (context.mounted) {
              _showFullScreenComparison(context, info);
            }
          });
        },
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Gradient pour simuler l'effet de sphère / 3D
            gradient: LinearGradient(
              colors: [
                Colors.indigo.shade400,
                Colors.cyan.shade300,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              // Ombre pour la profondeur
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                offset: const Offset(3, 3),
                blurRadius: 10,
              ),
              // Highlight pour la lumière
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.3),
                offset: const Offset(-2, -2),
                blurRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.question_mark_rounded, // Icône de question
            size: size * 0.6,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showFullScreenComparison(BuildContext context, ResponsiveInfo info) {
    showDialog(
      context: context,
      builder: (context) {
        final EdgeInsets padding =
            info.isMobile ? const EdgeInsets.all(4) : const EdgeInsets.all(16);

        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          insetPadding: padding,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 800),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ResponsiveText.headlineMedium(
                      'Comparaison des Technologies',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Consumer(
                        builder: (context, ref, child) {
                          final asyncData = ref.watch(comparaisonsJsonProvider);
                          return asyncData.when(
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (e, _) => Center(child: Text('Erreur: $e')),
                            data: (comparatifs) {
                              return ListView.builder(
                                itemCount: comparatifs.length,
                                itemBuilder: (context, index) {
                                  return ComparatifCard(
                                      comparatif: comparatifs[index]);
                                },
                              );
                            },
                          );
                        },
                      )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _getSpacing(ResponsiveInfo info,
          {double medium = 10, double large = 20}) =>
      info.isMobile ? 8 : (info.isTablet ? medium : large);
}

class ComparatifCard extends StatelessWidget {
  final Comparatif comparatif;

  const ComparatifCard({super.key, required this.comparatif});

  @override
  Widget build(BuildContext context) {
    const double itemHeight = 300.0;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Titre (Reste en haut)
            ResponsiveText.headlineSmall(comparatif.title),
            const SizedBox(height: 8),

            SizedBox(
              height: itemHeight,
              child: ListWheelScrollView(
                itemExtent: itemHeight,
                diameterRatio: 1.5,
                offAxisFraction: -0.5,
                children: [
                  _wrapViewInSizedBox(
                      _buildBarChart(comparatif), 'Barres', itemHeight),
                  _wrapViewInSizedBox(
                      _buildRadarChart(comparatif), 'Radar', itemHeight),
                  _wrapViewInSizedBox(
                      _buildTableView(comparatif), 'Table', itemHeight),
                  _wrapViewInSizedBox(_buildRecommendation(comparatif),
                      'Recommendation', itemHeight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wrapViewInSizedBox(Widget view, String title, double height) {
    return SizedBox(
      height: height,
      child: Column(
        children: [
          // Ajouter un titre visible pour savoir sur quelle vue on est
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ResponsiveText.titleMedium(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          // La vue elle-même prend le reste de l'espace
          Expanded(child: view),
        ],
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

    return Center(
      child: AspectRatio(
        aspectRatio: 1.0,
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
              return RadarChartTitle(
                text: categories[index],
                angle: angle,
              );
            },
            tickCount: 5,
          ),
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
