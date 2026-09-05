import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

class ExperienceAnalyticsWidget extends ConsumerWidget {
  const ExperienceAnalyticsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final info = ref.watch(responsiveInfoProvider);
    final isMobile = info.isMobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText.titleLarge(
          "Analyses d'Activité & Apprentissage",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const ResponsiveBox(paddingSize: ResponsiveSpacing.l),
        if (isMobile)
          Column(
            children: [
              _buildMixCard(context, theme),
              const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
              _buildJourneyCard(context, theme),
              const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
              _buildProjectCard(context, theme),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildMixCard(context, theme)),
              const ResponsiveBox(width: 20),
              Expanded(flex: 2, child: _buildJourneyCard(context, theme)),
            ],
          ),
        if (!isMobile) ...[
          const ResponsiveBox(paddingSize: ResponsiveSpacing.l),
          _buildProjectCard(context, theme),
        ],
      ],
    );
  }

  Widget _buildMixCard(BuildContext context, ThemeData theme) {
    return _BaseAnalyticsCard(
      title: "Mix de Compétences",
      subtitle: "Flutter vs Natif",
      child: SizedBox(
        height: 200,
        child: PieChart(
          PieChartData(
            sectionsSpace: 4,
            centerSpaceRadius: 40,
            sections: [
              PieChartSectionData(
                value: 85,
                title: 'Flutter/Dart',
                color: theme.colorScheme.primary,
                radius: 50,
                titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              PieChartSectionData(
                value: 15,
                title: 'Natif',
                color: theme.colorScheme.secondary,
                radius: 45,
                titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJourneyCard(BuildContext context, ThemeData theme) {
    return _BaseAnalyticsCard(
      title: "Courbe d'Apprentissage",
      subtitle: "Progression 2023 - 2026",
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    switch (value.toInt()) {
                      case 0:
                        return const Text('2023');
                      case 1:
                        return const Text('2024');
                      case 2:
                        return const Text('2025');
                      case 3:
                        return const Text('2026');
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 1),
                  FlSpot(1, 4),
                  FlSpot(2, 7),
                  FlSpot(3, 10),
                ],
                isCurved: true,
                color: theme.colorScheme.primary,
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, ThemeData theme) {
    return _BaseAnalyticsCard(
      title: "Focus Projets",
      subtitle: "Répartition par domaine",
      child: SizedBox(
        height: 150,
        child: BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    switch (value.toInt()) {
                      case 0:
                        return const Text('ERP');
                      case 1:
                        return const Text('Web');
                      case 2:
                        return const Text('Mobile');
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: [
              BarChartGroupData(x: 0, barRods: [
                BarChartRodData(
                    toY: 8, color: theme.colorScheme.primary, width: 20)
              ]),
              BarChartGroupData(x: 1, barRods: [
                BarChartRodData(
                    toY: 5, color: theme.colorScheme.secondary, width: 20)
              ]),
              BarChartGroupData(x: 2, barRods: [
                BarChartRodData(
                    toY: 6, color: theme.colorScheme.tertiary, width: 20)
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _BaseAnalyticsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _BaseAnalyticsCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText.titleMedium(
            title,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          ResponsiveText.bodySmall(
            subtitle,
            style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
          child,
        ],
      ),
    );
  }
}
