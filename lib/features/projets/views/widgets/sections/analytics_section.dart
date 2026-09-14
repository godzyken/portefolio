import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:portefolio/features/projets/data/analytics_models.dart';
import 'package:portefolio/features/projets/data/project_data.dart';
import 'package:portefolio/features/projets/providers/analytics_providers.dart';
import 'package:portefolio/features/projets/views/widgets/analytics_widgets.dart';

class AnalyticsSection extends ConsumerWidget {
  final ProjectInfo project;
  final ResponsiveInfo info;

  const AnalyticsSection({
    super.key,
    required this.project,
    required this.info,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(projectAnalyticsProvider(project.analyticsId));

    return analyticsAsync.when(
      data: (analytics) => _buildContent(context, analytics),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _buildError(e),
    );
  }

  Widget _buildContent(BuildContext context, ProjectAnalytics analytics) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: info.isMobile ? 16 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          
          // Métriques Live / KPIs
          _buildMetricsGrid(analytics),
          const SizedBox(height: 40),

          // Audits (SEO, Perf, GEO)
          if (analytics.audits.isNotEmpty) ...[
            _buildAuditsSection(analytics),
            const SizedBox(height: 40),
          ],

          // Historique
          if (analytics.history.isNotEmpty) ...[
            _buildHistorySection(analytics),
            const SizedBox(height: 40),
          ],

          // Disclaimer / Methodologie
          _buildMethodology(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.analytics_outlined, color: Colors.cyanAccent, size: 32),
            const SizedBox(width: 16),
            ResponsiveText.headlineMedium(
              'Performance & ROI',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ResponsiveText.bodyMedium(
          'Analyse temps réel, scores d\'audit et impact business du projet ${project.title}.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(ProjectAnalytics analytics) {
    final eventMetrics = analytics.metrics[MetricDomain.event] ?? [];
    final kpiMetrics = analytics.metrics[MetricDomain.kpi] ?? [];
    final allMetrics = [...kpiMetrics, ...eventMetrics];

    if (allMetrics.isEmpty) {
      return _buildEmptyState('Aucune métrique live disponible pour le moment.');
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: info.isMobile ? 2 : info.isTablet ? 3 : 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: allMetrics.length,
      itemBuilder: (context, index) => MetricCard(
        metric: allMetrics[index],
        icon: _getMetricIcon(allMetrics[index].key),
      ),
    );
  }

  Widget _buildAuditsSection(ProjectAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ResponsiveText.titleLarge(
          'Audits de Qualité',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 32,
          runSpacing: 32,
          children: analytics.audits.values.map((audit) {
            return SizedBox(
              width: info.isMobile ? double.infinity : 300,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuditScoreCircle(
                    score: audit.score,
                    label: audit.title,
                    status: audit.status,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Points clés :',
                          style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        AuditItemsList(items: audit.items),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHistorySection(ProjectAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ResponsiveText.titleLarge(
          'Évolution dans le temps',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Container(
          height: 250,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < analytics.history.length) {
                        final date = analytics.history[value.toInt()].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${date.day}/${date.month}',
                            style: const TextStyle(color: Colors.white38, fontSize: 10),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: analytics.history.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value.seoScore ?? 0);
                  }).toList(),
                  isCurved: true,
                  color: Colors.cyanAccent,
                  barWidth: 4,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.cyanAccent.withValues(alpha: 0.1),
                  ),
                ),
                LineChartBarData(
                  spots: analytics.history.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value.performanceScore ?? 0);
                  }).toList(),
                  isCurved: true,
                  color: Colors.purpleAccent,
                  barWidth: 4,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.purpleAccent.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('SEO', Colors.cyanAccent),
            const SizedBox(width: 24),
            _buildLegendItem('Performance', Colors.purpleAccent),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 4, color: color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _buildMethodology() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amberAccent, size: 16),
              SizedBox(width: 8),
              Text(
                'Méthodologie',
                style: TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Les scores CALCULATED sont générés par notre moteur d\'analyse interne basé sur des critères standards. '
            'Les données REAL proviennent directement des APIs connectées. '
            'Les projections ESTIMATED sont basées sur les tendances actuelles.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.analytics_outlined, color: Colors.white24, size: 48),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildError(Object e) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Text('Erreur Analytics: $e', style: const TextStyle(color: Colors.redAccent)),
        ],
      ),
    );
  }

  IconData? _getMetricIcon(String key) {
    if (key.contains('call')) return Icons.phone;
    if (key.contains('email')) return Icons.email;
    if (key.contains('whatsapp')) return Icons.chat;
    if (key.contains('form')) return Icons.assignment;
    if (key.contains('lead')) return Icons.trending_up;
    return Icons.bolt;
  }
}
