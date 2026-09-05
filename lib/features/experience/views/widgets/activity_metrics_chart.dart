import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';
import 'package:portefolio/core/provider/analytics_provider.dart';
import 'package:portefolio/features/wakatime/providers/projects_wakatime_service_provider.dart';

enum ChartViewMode { recruteur, artisan }

/// Widget responsive et interactif pour afficher les métriques d'activité.
/// Basculable entre une vue "Recruteur" (Dev vs Qualité) et "Artisan" (Volume Live).
class ActivityMetricsChart extends ConsumerStatefulWidget {
  final ProjectInfo project;
  final ResponsiveInfo info;

  const ActivityMetricsChart({
    super.key,
    required this.project,
    required this.info,
  });

  @override
  ConsumerState<ActivityMetricsChart> createState() => _ActivityMetricsChartState();
}

class _ActivityMetricsChartState extends ConsumerState<ActivityMetricsChart> {
  ChartViewMode _viewMode = ChartViewMode.recruteur;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _viewMode == ChartViewMode.recruteur
                  ? _buildRecruteurView()
                  : _buildArtisanView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText.titleMedium(
              _viewMode == ChartViewMode.recruteur
                  ? '📊 Performance & Qualité'
                  : '🚀 Activité Temps Réel',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            ResponsiveText.bodySmall(
              _viewMode == ChartViewMode.recruteur
                  ? 'Temps de dev vs Indicateurs de fiabilité'
                  : 'Volume d\'utilisation en live via Supabase',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ],
        ),
        SegmentedButton<ChartViewMode>(
          segments: const [
            ButtonSegment(
              value: ChartViewMode.recruteur,
              icon: Icon(Icons.badge_outlined),
              label: Text('Recruteur'),
            ),
            ButtonSegment(
              value: ChartViewMode.artisan,
              icon: Icon(Icons.precision_manufacturing_outlined),
              label: Text('Artisan'),
            ),
          ],
          selected: {_viewMode},
          onSelectionChanged: (Set<ChartViewMode> newSelection) {
            setState(() {
              _viewMode = newSelection.first;
            });
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.blue.withValues(alpha: 0.3);
              }
              return Colors.white.withValues(alpha: 0.05);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildRecruteurView() {
    // Récupération des données WakaTime
    final statsAsync = ref.watch(wakaTimeStatsProvider('last_7_days'));

    return statsAsync.when(
      data: (stats) {
        final timeSpent = widget.project.timeSpent?.inHours.toDouble() ?? 0.0;
        final qualityScore = _getQualityScore();

        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 100,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => Colors.blueGrey.shade900,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  String label = groupIndex == 0 ? 'Temps (h)' : 'Qualité (%)';
                  return BarTooltipItem(
                    '$label\n',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: rod.toY.toStringAsFixed(1),
                        style: TextStyle(color: rod.color, fontWeight: FontWeight.w500),
                      ),
                    ],
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final titles = ['Temps Passé', 'Qualité / Workflow'];
                    if (value.toInt() >= 0 && value.toInt() < titles.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ResponsiveText.bodySmall(
                          titles[value.toInt()],
                          style: const TextStyle(color: Colors.white70),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => ResponsiveText.bodySmall(
                    '${value.toInt()}',
                    style: const TextStyle(color: Colors.white60),
                  ),
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.white.withValues(alpha: 0.1),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: min(timeSpent, 100),
                    color: Colors.blueAccent,
                    width: 40,
                    borderRadius: BorderRadius.circular(6),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: 100,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: qualityScore,
                    color: Colors.greenAccent,
                    width: 40,
                    borderRadius: BorderRadius.circular(6),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: 100,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }

  Widget _buildArtisanView() {
    final analyticsAsync = ref.watch(liveAnalyticsStreamProvider(widget.project.id));

    return analyticsAsync.when(
      data: (analytics) {
        if (analytics.isEmpty) {
          return const Center(child: Text('Aucune donnée live disponible', style: TextStyle(color: Colors.white70)));
        }

        // Grouper par heure (simulé ici pour le graphique)
        final spots = _generateSpotsFromAnalytics(analytics);

        return LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => Colors.blueGrey.shade900,
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.white.withValues(alpha: 0.1),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${date.hour}h',
                        style: const TextStyle(color: Colors.white60, fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.white60, fontSize: 10),
                  ),
                  reservedSize: 40,
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                color: Colors.cyanAccent,
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.cyanAccent.withValues(alpha: 0.2),
                ),
                spots: spots,
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }

  double _getQualityScore() {
    // Calculer un score à partir du benchmark si présent, sinon mock
    final benchmark = widget.project.resultsMap?['benchmark'];
    if (benchmark != null) {
      if (benchmark is Map) {
        final scoreStr = benchmark['score']?.toString().replaceAll('/100', '') ?? '80';
        return double.tryParse(scoreStr) ?? 80.0;
      }
    }
    return 85.0; // Fallback
  }

  List<FlSpot> _generateSpotsFromAnalytics(List<AppAnalytics> analytics) {
    // On groupe par heure sur les dernières 24h
    final now = DateTime.now();
    final Map<int, double> hourlyVolume = {};
    
    for (var a in analytics) {
      final diff = now.difference(a.createdAt).inHours;
      if (diff < 24) {
        hourlyVolume[23 - diff] = (hourlyVolume[23 - diff] ?? 0) + a.value;
      }
    }

    return List.generate(24, (i) {
      return FlSpot(i.toDouble(), hourlyVolume[i] ?? 0.0);
    });
  }
}
