import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

import '../../../../wakatime/data/wakatime_models_data.dart';
import '../../../../wakatime/providers/projects_wakatime_service_provider.dart';

/// Section WakaTime complète : dashboard multi-graphiques + radar métier.
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
  String _selectedRange = 'all_time';

  static const _ranges = {
    'last_7_days': '7J',
    'last_30_days': '30J',
    'last_year': '1A',
    'all_time': 'All',
  };

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

    return statsAsync.when(
      data: (stats) {
        if (stats == null) return _buildEmptyState(matched: false);

        final projectStat = _findProjectStat(stats);

        // Projet non présent dans WakaTime → on n'affiche pas le dashboard
        if (projectStat == null) {
          return _buildEmptyState(matched: true);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildKpiRow(stats, projectStat),
              const SizedBox(height: 16),
              if (widget.info.isLandscape)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildLanguagesCard(stats),
                          const SizedBox(height: 16),
                          _buildCategoriesCard(stats),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          _buildRadarCard(stats, projectStat),
                          const SizedBox(height: 16),
                          _buildEditorsCard(stats),
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
                    _buildRadarCard(stats, projectStat),
                    const SizedBox(height: 16),
                    _buildCategoriesCard(stats),
                    const SizedBox(height: 16),
                    _buildEditorsCard(stats),
                  ],
                ),
              const SizedBox(height: 16),
              _buildProjectComparison(stats, projectStat),
              const SizedBox(height: 16),
              if (projectStat != null) _buildBonusSection(stats, projectStat),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => _buildErrorState(),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  WakaTimeProjectStat? _findProjectStat(WakaTimeStats stats) {
    try {
      return stats.projects.firstWhere((p) {
        final cleanApi =
            p.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        final cleanLocal = widget.projectName
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]'), '');
        return cleanApi.contains(cleanLocal) || cleanLocal.contains(cleanApi);
      });
    } catch (_) {
      return null;
    }
  }

  String _formatDuration(double totalSeconds) {
    final h = (totalSeconds / 3600).floor();
    final m = ((totalSeconds % 3600) / 60).floor();
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            return Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(
                      alpha: 0.4 + 0.4 * _pulseController.value,
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
        const Expanded(
          child: ResponsiveText.titleMedium(
            'Statistiques de développement',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        _buildRangeSelector(),
      ],
    );
  }

  Widget _buildRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _ranges.entries.map((e) {
          final selected = _selectedRange == e.key;
          return GestureDetector(
            onTap: () => setState(() => _selectedRange = e.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.blue.withValues(alpha: 0.35)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                e.value,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white60,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // KPI
  // ---------------------------------------------------------------------------

  Widget _buildKpiRow(WakaTimeStats stats, WakaTimeProjectStat? projectStat) {
    final totalH = stats.totalSeconds / 3600;
    final projectH = (projectStat?.totalSeconds ?? 0) / 3600;
    final projectPct = projectStat?.percent ?? 0;
    final topLang =
        stats.languages.isNotEmpty ? stats.languages.first.name : '—';

    return Row(
      children: [
        Expanded(
            child: _kpiCard('Temps total', '${totalH.toStringAsFixed(1)}h',
                Icons.timer_outlined, Colors.blue)),
        const SizedBox(width: 10),
        Expanded(
            child: _kpiCard(
                'Sur ce projet',
                projectStat != null ? '${projectH.toStringAsFixed(1)}h' : '—',
                Icons.folder_special_outlined,
                Colors.green)),
        const SizedBox(width: 10),
        Expanded(
            child: _kpiCard(
                'Focus projet',
                projectStat != null ? '${projectPct.toStringAsFixed(0)}%' : '—',
                Icons.center_focus_strong,
                Colors.orange)),
        const SizedBox(width: 10),
        Expanded(
            child: _kpiCard('Langage #1', topLang, Icons.code, Colors.purple)),
      ],
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: widget.info.isMobile ? 14 : 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Languages
  // ---------------------------------------------------------------------------

  Widget _buildLanguagesCard(WakaTimeStats stats) {
    final colors = ColorHelpers.chartColors;
    final languages = stats.languages.take(7).toList();

    return _card(
      title: 'Langages',
      icon: Icons.code,
      iconColor: Colors.blue.shade300,
      child: SizedBox(
        height: 220,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 48,
                  sections: languages.asMap().entries.map((e) {
                    return PieChartSectionData(
                      value: e.value.percent,
                      color: colors[e.key % colors.length],
                      radius: 42,
                      showTitle: false,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: languages.asMap().entries.map((e) {
                  return _legendItem(
                    e.value.name,
                    '${e.value.percent.toStringAsFixed(1)}%',
                    _formatDuration(e.value.totalSeconds),
                    colors[e.key % colors.length],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(
      String name, String percent, String duration, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(percent,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(width: 6),
          Text(duration,
              style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Categories (vraies données)
  // ---------------------------------------------------------------------------

  Widget _buildCategoriesCard(WakaTimeStats stats) {
    final categories = stats.categories;
    if (categories.isEmpty) {
      return _card(
        title: 'Catégories d\'activité',
        icon: Icons.category_outlined,
        iconColor: Colors.teal.shade300,
        child: const Text(
          'Aucune catégorie disponible pour cette période.',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
      );
    }

    final colors = [
      Colors.blue,
      Colors.teal,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
    ];

    return _card(
      title: 'Catégories d\'activité',
      icon: Icons.category_outlined,
      iconColor: Colors.teal.shade300,
      child: Column(
        children: categories.asMap().entries.map((e) {
          final c = e.value;
          final color = colors[e.key % colors.length];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(c.name,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    const Spacer(),
                    Text(
                      '${c.percent.toStringAsFixed(1)}% · ${_formatDuration(c.totalSeconds)}',
                      style: TextStyle(
                        color: color,
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
                    value: (c.percent / 100).clamp(0.0, 1.0),
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 7,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Radar WakaTime
  // ---------------------------------------------------------------------------

  Widget _buildRadarCard(
      WakaTimeStats stats, WakaTimeProjectStat? projectStat) {
    final projectFocus = (projectStat?.percent ?? 0).clamp(0.0, 100.0);

    final topLangPct =
        stats.languages.isNotEmpty ? stats.languages.first.percent : 100.0;
    final langDiversity = (100 - topLangPct).clamp(0.0, 100.0);

    final topEditorPct =
        stats.editors.isNotEmpty ? stats.editors.first.percent : 50.0;
    final editorFocus = topEditorPct.clamp(0.0, 100.0);

    final volumeScore =
        ((stats.totalSeconds / 3600) / 40 * 100).clamp(0.0, 100.0);

    final codingCat =
        stats.categories.where((c) => c.name.toLowerCase().contains('coding'));
    final codingIntensity =
        codingCat.isNotEmpty ? codingCat.first.percent.clamp(0.0, 100.0) : 70.0;

    final values = [
      projectFocus,
      langDiversity,
      codingIntensity,
      editorFocus,
      volumeScore,
    ];

    const labels = [
      'Focus projet',
      'Diversité lang.',
      'Intensité code',
      'Focus éditeur',
      'Volume',
    ];

    return _card(
      title: 'Radar compétences projet',
      icon: Icons.radar,
      iconColor: Colors.purple.shade300,
      child: SizedBox(
        height: 240,
        child: RadarChart(
          RadarChartData(
            radarShape: RadarShape.polygon,
            radarBorderData:
                BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            gridBorderData:
                BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            tickBorderData:
                BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            tickCount: 4,
            ticksTextStyle: const TextStyle(color: Colors.transparent),
            radarBackgroundColor: Colors.transparent,
            dataSets: [
              RadarDataSet(
                fillColor: Colors.purple.withValues(alpha: 0.25),
                borderColor: Colors.purpleAccent,
                borderWidth: 2,
                entryRadius: 3,
                dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
              ),
            ],
            getTitle: (index, angle) =>
                RadarChartTitle(text: labels[index], angle: 0),
            titleTextStyle: TextStyle(
              color: Colors.white70,
              fontSize: widget.info.isMobile ? 10 : 11,
            ),
            titlePositionPercentageOffset: 0.18,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Editors
  // ---------------------------------------------------------------------------

  Widget _buildEditorsCard(WakaTimeStats stats) {
    final editors = stats.editors.take(5).toList();

    return _card(
      title: 'Éditeurs',
      icon: Icons.laptop_mac,
      iconColor: Colors.orange.shade300,
      child: Column(
        children: editors.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(e.name,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ),
                    Text(
                      '${e.percent.toStringAsFixed(1)}% · ${_formatDuration(e.totalSeconds)}',
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
                    value: (e.percent / 100).clamp(0.0, 1.0),
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: const AlwaysStoppedAnimation(Colors.orange),
                    minHeight: 7,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top projets
  // ---------------------------------------------------------------------------

  Widget _buildProjectComparison(
      WakaTimeStats stats, WakaTimeProjectStat? current) {
    final top = stats.projects.take(6).toList();

    return _card(
      title: 'Top projets (temps)',
      icon: Icons.bar_chart,
      iconColor: Colors.cyan.shade300,
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: top.isEmpty
                ? 100
                : top.map((p) => p.percent).reduce((a, b) => a > b ? a : b) *
                    1.15,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final p = top[group.x.toInt()];
                  return BarTooltipItem(
                    '${p.name}\n${_formatDuration(p.totalSeconds)} (${p.percent.toStringAsFixed(1)}%)',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= top.length) return const SizedBox();
                    final name = top[i].name;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        name.length > 9 ? '${name.substring(0, 9)}…' : name,
                        style:
                            const TextStyle(color: Colors.white54, fontSize: 9),
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: Colors.white.withValues(alpha: 0.06)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: top.asMap().entries.map((e) {
              final isCurrent = current != null &&
                  e.value.name.toLowerCase() == current.name.toLowerCase();
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value.percent,
                    width: 18,
                    borderRadius: BorderRadius.circular(5),
                    color: isCurrent
                        ? Colors.blueAccent
                        : ColorHelpers.getColorForIndex(e.key),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bonus
  // ---------------------------------------------------------------------------

  Widget _buildBonusSection(
      WakaTimeStats stats, WakaTimeProjectStat projectStat) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.blue.withValues(alpha: 0.12),
          Colors.purple.withValues(alpha: 0.12),
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Indicateurs clés',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _badge('Temps projet', _formatDuration(projectStat.totalSeconds),
                  Colors.green),
              _badge('Part du total',
                  '${projectStat.percent.toStringAsFixed(1)}%', Colors.blue),
              _badge('Période', _ranges[_selectedRange] ?? _selectedRange,
                  Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  TextStyle(color: color.withValues(alpha: 0.9), fontSize: 11)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI helpers
  // ---------------------------------------------------------------------------

  Widget _card({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildEmptyState({required bool matched}) {
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
            Icon(
              matched ? Icons.visibility_off_outlined : Icons.info_outline,
              color: Colors.white38,
              size: 40,
            ),
            const SizedBox(height: 16),
            ResponsiveText.bodyLarge(
              matched
                  ? 'Projet non tracké par WakaTime'
                  : 'Aucune donnée WakaTime disponible',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ResponsiveText.bodyMedium(
              matched
                  ? 'Ce projet n\'est pas encore tracké par WakaTime'
                  : 'Les statistiques ne sont pas encore chargées pour cette période',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
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
}
