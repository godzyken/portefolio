import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/provider/image_providers.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

import '../../../../wakatime/data/wakatime_models_data.dart';
import '../../../../wakatime/providers/projects_wakatime_service_provider.dart';

/// Section WakaTime complète et immersive
class EnhancedWakaTimeSection extends ConsumerStatefulWidget {
  final String projectName;
  final ResponsiveInfo info;

  const EnhancedWakaTimeSection({
    super.key,
    required this.projectName,
    required this.info,
  });

  @override
  ConsumerState<EnhancedWakaTimeSection> createState() =>
      _EnhancedWakaTimeSectionState();
}

class _EnhancedWakaTimeSectionState
    extends ConsumerState<EnhancedWakaTimeSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  String _selectedRange = 'last_7_days';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(wakaTimeStatsProvider(_selectedRange));
    final projectStat = _findProjectStat(statsAsync);

    return statsAsync.when(
      data: (stats) {
        if (stats == null || projectStat == null) {
          return _buildEmptyState();
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec range selector
              _buildHeader(),
              const SizedBox(height: 14),

              // Graphiques en 2 colonnes
              if (widget.info.isLandscape)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildLanguagesCard(stats),
                          const SizedBox(height: 16),
                          _buildEditorsCard(stats),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          _buildActivityTimeline(stats, projectStat),
                          const SizedBox(height: 16),
                          _buildProjectComparison(stats),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildLanguagesCard(stats),
                    const SizedBox(height: 16),
                    _buildActivityTimeline(stats, projectStat),
                    const SizedBox(height: 16),
                    _buildEditorsCard(stats),
                    const SizedBox(height: 16),
                    _buildProjectComparison(stats),
                  ],
                ),

              const SizedBox(height: 14),

              // Section bonus : Badges et liens
              _buildBonusSection(stats, projectStat),
              const SizedBox(height: 54),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildErrorState(),
    );
  }

  WakaTimeProjectStat? _findProjectStat(AsyncValue<WakaTimeStats?> statsAsync) {
    return statsAsync.maybeWhen(
      data: (stats) {
        if (stats == null) return null;
        try {
          return stats.projects.firstWhere(
            (p) {
              final cleanApiName =
                  p.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
              final cleanLocalName = widget.projectName
                  .toLowerCase()
                  .replaceAll(RegExp(r'[^a-z0-9]'), '');
              return cleanApiName.contains(cleanLocalName) ||
                  cleanLocalName.contains(cleanApiName);
            },
          );
        } catch (_) {
          return null;
        }
      },
      orElse: () => null,
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(
                          alpha: 0.5 + 0.5 * _pulseController.value,
                        ),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            ResponsiveText.titleMedium(
              '⏱️ Statistiques de développement',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        _buildRangeSelector(),
      ],
    );
  }

  Widget _buildRangeSelector() {
    final ranges = {
      'last_7_days': '7J',
      'last_30_days': '30J',
      'last_6_months': '6M',
      'last_year': '1A',
    };

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ranges.entries.map((entry) {
          final isSelected = _selectedRange == entry.key;
          return GestureDetector(
            onTap: () => setState(() => _selectedRange = entry.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue.withValues(alpha: 0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: ResponsiveText.bodySmall(
                entry.value,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLanguagesCard(WakaTimeStats stats) {
    final colors = ColorHelpers.chartColors;
    final languages = stats.languages.take(6).toList();

    return ResponsiveBox(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.code, color: Colors.blue.shade300, size: 12),
              const SizedBox(width: 12),
              const ResponsiveText.titleMedium(
                'Langages utilisés',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: languages.asMap().entries.map((entry) {
                        final color = colors[entry.key % colors.length];
                        return PieChartSectionData(
                          value: entry.value.percent,
                          color: color,
                          radius: 45,
                          showTitle: false,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: languages.asMap().entries.map((entry) {
                      return _buildLanguageLegendItem(
                        entry.value,
                        colors[entry.key % colors.length],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageLegendItem(WakaTimeLanguage lang, Color color) {
    return Consumer(
      builder: (context, ref, child) {
        final logoPath =
            ref.watch(skillLogoPathProvider(lang.name.toLowerCase()));

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              if (logoPath != null)
                SmartImageV2(
                  path: logoPath,
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                  enableShimmer: false,
                  autoPreload: true,
                  fallbackIcon: Icons.code,
                  fallbackColor: color,
                )
              else
                Icon(Icons.code, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: ResponsiveText.bodySmall(
                  lang.name,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
              ResponsiveText.bodySmall(
                '${lang.percent.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityTimeline(
      WakaTimeStats stats, WakaTimeProjectStat projectStat) {
    // Simuler une timeline sur 7 jours
    final random = Random(42);
    final spots = List.generate(
      7,
      (i) => FlSpot(
        i.toDouble(),
        (projectStat.totalSeconds / 7) *
            (0.8 + random.nextDouble() * 0.4) /
            3600,
      ),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: Colors.green.shade300, size: 24),
              const SizedBox(width: 12),
              const ResponsiveText.titleMedium(
                'Activité quotidienne',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        return ResponsiveText.bodySmall(
                          '${value.toInt()}h',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = [
                          'Lun',
                          'Mar',
                          'Mer',
                          'Jeu',
                          'Ven',
                          'Sam',
                          'Dim'
                        ];
                        final index = value.toInt();
                        if (index < 0 || index >= days.length) {
                          return const SizedBox();
                        }
                        return ResponsiveText.bodySmall(
                          days[index],
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Colors.green,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorsCard(WakaTimeStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.laptop, color: Colors.orange.shade300, size: 24),
              const SizedBox(width: 12),
              const ResponsiveText.titleMedium(
                'Éditeurs utilisés',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...stats.editors.map((editor) => _buildEditorBar(editor)),
        ],
      ),
    );
  }

  Widget _buildEditorBar(WakaTimeEditor editor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ResponsiveText.bodySmall(
                editor.name,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              ResponsiveText.bodySmall(
                '${editor.percent.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: editor.percent / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectComparison(WakaTimeStats stats) {
    final topProjects = stats.projects.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: Colors.purple.shade300, size: 24),
              const SizedBox(width: 12),
              const ResponsiveText.titleMedium(
                'Top projets',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= topProjects.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ResponsiveText.bodySmall(
                            topProjects[index].name.length > 10
                                ? '${topProjects[index].name.substring(0, 10)}...'
                                : topProjects[index].name,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 9,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: topProjects.asMap().entries.map((entry) {
                  final isCurrentProject = entry.value.name
                      .toLowerCase()
                      .contains(widget.projectName.toLowerCase());
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.percent,
                        color: isCurrentProject
                            ? Colors.blue
                            : ColorHelpers.getColorForIndex(entry.key),
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBonusSection(
      WakaTimeStats stats, WakaTimeProjectStat projectStat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withValues(alpha: 0.1),
            Colors.purple.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ResponsiveText.titleMedium(
            '🏆 Achievements',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildAchievementBadge(
                '💯 Productif',
                'Plus de ${(projectStat.totalSeconds / 3600).toStringAsFixed(0)}h sur ce projet',
                Colors.green,
              ),
              _buildAchievementBadge(
                '🔥 Streak',
                'Actif ${_selectedRange == 'last_7_days' ? '7 jours' : _getRangeLabel()}',
                Colors.orange,
              ),
              _buildAchievementBadge(
                '🎯 Focus',
                '${projectStat.percent.toStringAsFixed(0)}% du temps total',
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ResponsiveText.bodySmall(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          ResponsiveText.bodySmall(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, color: Colors.orange.shade300, size: 48),
            const SizedBox(height: 16),
            const ResponsiveText.bodyLarge(
              'Aucune donnée WakaTime disponible',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ResponsiveText.bodyMedium(
              'Ce projet n\'est pas encore tracké par WakaTime',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
            const SizedBox(height: 16),
            const ResponsiveText.bodyLarge(
              'Erreur de chargement',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            ResponsiveText.bodyMedium(
              'Impossible de récupérer les statistiques WakaTime',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getRangeLabel() {
    switch (_selectedRange) {
      case 'last_7_days':
        return '7 derniers jours';
      case 'last_30_days':
        return '30 derniers jours';
      case 'last_6_months':
        return '6 derniers mois';
      case 'last_year':
        return 'Dernière année';
      default:
        return '';
    }
  }
}
