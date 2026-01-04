import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/provider/image_providers.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

import '../../../../projets/providers/projects_wakatime_service_provider.dart';
import '../../../data/wakatime_models_data.dart';
import '../../generator_widgets_extentions.dart';

/// Section WakaTime - Affiche les statistiques de développement
///
/// Affiche:
/// - Temps de développement total
/// - Part du temps total
/// - Format détaillé
/// - Graphique pie chart des langages utilisés
class WakaTimeSection extends ConsumerWidget {
  final String projectName;
  final ResponsiveInfo info;

  const WakaTimeSection({
    super.key,
    required this.projectName,
    required this.info,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(wakaTimeStatsProvider('last_7_days'));

    return statsAsync.when(
      data: (stats) {
        if (stats == null || stats.projects.isEmpty) {
          return _EmptyWakaTimeCard(info: info);
        }

        final projectStat = _findProjectStat(stats);

        if (projectStat == null) {
          return _EmptyWakaTimeCard(info: info);
        }

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: info.size.height * 0.7),
            child: _CompactWakaTimeStats(
              stats: stats,
              projectStat: projectStat,
              info: info,
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _ErrorWakaTimeCard(info: info),
    );
  }

  WakaTimeProjectStat? _findProjectStat(WakaTimeStats stats) {
    return stats.projects.cast<WakaTimeProjectStat?>().firstWhere(
      (p) {
        if (p == null) return false;
        final cleanApiName =
            p.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        final cleanLocalName =
            projectName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        return cleanApiName.contains(cleanLocalName) ||
            cleanLocalName.contains(cleanApiName);
      },
      orElse: () => null,
    );
  }
}

/// Stats WakaTime compactes (temps + langages)
class _CompactWakaTimeStats extends StatelessWidget {
  final WakaTimeStats stats;
  final WakaTimeProjectStat projectStat;
  final ResponsiveInfo info;

  const _CompactWakaTimeStats({
    required this.stats,
    required this.projectStat,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final languages = stats.languages;

    return Row(
      children: [
        // Colonne gauche: Stats principales
        Expanded(
          flex: info.isMobile ? 1 : 2,
          child: _StatsColumn(
            projectStat: projectStat,
            info: info,
          ),
        ),

        SizedBox(width: info.isMobile ? 16 : 24),

        // Colonne droite: Langages
        if (languages.isNotEmpty)
          Expanded(
            flex: info.isMobile ? 1 : 3,
            child: _LanguagesSection(
              languages: languages,
              info: info,
            ),
          ),
      ],
    );
  }
}

/// Colonne des statistiques principales
class _StatsColumn extends StatelessWidget {
  final WakaTimeProjectStat projectStat;
  final ResponsiveInfo info;

  const _StatsColumn({
    required this.projectStat,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText.titleMedium(
          '⏱️ Statistiques de développement',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        StatCard(
          label: 'Temps de développement',
          value: projectStat.text,
          icon: Icons.timer,
        ),
        const SizedBox(height: 12),
        StatCard(
          label: 'Part du temps total',
          value: '${projectStat.percent.toStringAsFixed(1)}%',
          icon: Icons.trending_up,
        ),
        const SizedBox(height: 12),
        StatCard(
          label: 'Format détaillé',
          value: projectStat.digital,
          icon: Icons.schedule,
        ),
      ],
    );
  }
}

/// Section des langages avec pie chart et légende
class _LanguagesSection extends StatelessWidget {
  final List<WakaTimeLanguage> languages;
  final ResponsiveInfo info;

  const _LanguagesSection({
    required this.languages,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final displayLanguages = languages.take(5).toList();

    if (info.isLandscape) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: _LanguagePieChart(
              languages: displayLanguages,
              info: info,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 6,
            child: _LanguageLegend(
              languages: displayLanguages,
              info: info,
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText.bodyLarge(
            'Langages utilisés',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: info.isMobile ? 14 : 16,
            ),
          ),
          const SizedBox(height: 12),
          _LanguagePieChart(
            languages: displayLanguages,
            info: info,
          ),
          const SizedBox(height: 16),
          _LanguageLegend(
            languages: displayLanguages,
            info: info,
          ),
        ],
      );
    }
  }
}

/// Pie chart des langages
class _LanguagePieChart extends StatelessWidget {
  final List<WakaTimeLanguage> languages;
  final ResponsiveInfo info;

  const _LanguagePieChart({
    required this.languages,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ColorHelpers.chartColors;

    final sections = languages.asMap().entries.map((entry) {
      final index = entry.key;
      final lang = entry.value;
      final color = colors[index % colors.length];

      return PieChartSectionData(
        color: color,
        value: lang.percent,
        showTitle: false,
        radius: info.isMobile ? 50 : 65,
        borderSide: BorderSide(
          width: 2,
          color: color.withValues(alpha: 0.03),
          style: BorderStyle.solid,
          strokeAlign: 2.0,
        ),
        badgeWidget: ThreeDTechIcon(
          logoPath: lang.name,
          color: color,
          size: info.isMobile ? 38 : 48,
        ),
        badgePositionPercentageOffset: info.isMobile ? 0.5 : 1.5,
      );
    }).toList();

    return SizedBox(
      height: info.isLandscape ? 200 : 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: info.isMobile ? 40 : 55,
              sections: sections,
              borderData: FlBorderData(
                show: false,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 2,
                  ),
                ),
              ),
              startDegreeOffset: 20,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {},
              ),
              titleSunbeamLayout: true,
            ),
            curve: Curves.bounceInOut,
          ),
          // Centre du pie chart
          Container(
            width: info.isMobile ? 80 : 110,
            height: info.isMobile ? 80 : 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.6),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: ResponsiveText(
                '${languages.length}\nLangages',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: info.isMobile ? 11 : 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Légende des langages
class _LanguageLegend extends StatelessWidget {
  final List<WakaTimeLanguage> languages;
  final ResponsiveInfo info;

  const _LanguageLegend({
    required this.languages,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ColorHelpers.chartColors;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: languages.asMap().entries.map((entry) {
        final index = entry.key;
        final lang = entry.value;
        final color = colors[index % colors.length];

        return _LanguageLegendItem(
          lang: lang,
          color: color,
          info: info,
        );
      }).toList(),
    );
  }
}

/// Item de légende pour un langage
class _LanguageLegendItem extends ConsumerWidget {
  final WakaTimeLanguage lang;
  final Color color;
  final ResponsiveInfo info;

  const _LanguageLegendItem({
    required this.lang,
    required this.color,
    required this.info,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoPath = ref.watch(skillLogoPathProvider(lang.name.toLowerCase()));

    return Container(
      padding: EdgeInsets.all(info.isMobile ? 6 : 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (logoPath != null)
            SmartImage(
              path: logoPath,
              width: info.isMobile ? 20 : 24,
              height: info.isMobile ? 20 : 24,
              fit: BoxFit.contain,
              enableShimmer: false,
              useCache: true,
              fallbackIcon: Icons.code,
              fallbackColor: color,
            )
          else
            Icon(
              Icons.code,
              size: info.isMobile ? 20 : 24,
              color: color,
            ),
          SizedBox(width: info.isMobile ? 6 : 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ResponsiveText.bodySmall(
                lang.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: info.isMobile ? 11 : 12,
                ),
              ),
              const SizedBox(height: 2),
              ResponsiveText.bodySmall(
                '${lang.percent.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: info.isMobile ? 9 : 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card vide (aucune donnée)
class _EmptyWakaTimeCard extends StatelessWidget {
  final ResponsiveInfo info;

  const _EmptyWakaTimeCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBox(
      padding: EdgeInsets.all(info.isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade300, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: ResponsiveText.bodyMedium(
              'Aucune donnée WakaTime disponible pour ce projet',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: info.isMobile ? 14 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card erreur
class _ErrorWakaTimeCard extends StatelessWidget {
  final ResponsiveInfo info;

  const _ErrorWakaTimeCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBox(
      padding: EdgeInsets.all(info.isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade300, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: ResponsiveText.bodyMedium(
              'Erreur lors du chargement des statistiques WakaTime',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: info.isMobile ? 14 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
