import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:portefolio/features/experience/views/widgets/activity_metrics_chart.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';
import 'package:portefolio/features/generator/views/generator_widgets_extentions.dart';
import 'package:portefolio/features/projets/data/github_project_analyzer.dart';

/// Section Résultats - Affiche de véritables analyses dynamiques (GitHub, WakaTime, Performance)
/// et une présentation claire et structurée (plus facile à lire).
class ResultsSection extends StatefulWidget {
  final ProjectInfo project;
  final ResponsiveInfo info;

  const ResultsSection({
    super.key,
    required this.project,
    required this.info,
  });

  @override
  State<ResultsSection> createState() => _ResultsSectionState();
}

class _ResultsSectionState extends State<ResultsSection> {
  late List<ChartData> _charts;
  Future<GithubProjectTechInfo?>? _githubAnalysisFuture;

  @override
  void initState() {
    super.initState();
    _prepareChartData();
    _initGithubAnalysis();
  }

  void _prepareChartData() {
    final resultats = widget.project.resultsMap;
    if (resultats == null) {
      _charts = [];
      return;
    }
    _charts = ChartDataFactory.createChartsFromResults(resultats);
  }

  void _initGithubAnalysis() {
    final repoUrl = widget.project.githubRepoUrl;
    if (repoUrl != null && repoUrl.trim().isNotEmpty) {
      _githubAnalysisFuture = GithubProjectAnalyzer.analyzeRepo(repoUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = widget.project.results ?? [];
    final techDetails = widget.project.techDetails;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête explicite
          Row(
            children: [
              const Icon(Icons.analytics_rounded,
                  color: ColorHelpers.cyan, size: 28),
              const SizedBox(width: 12),
              const ResponsiveText.titleMedium(
                '🏁 Analyses & Résultats du Projet',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ResponsiveText.bodyMedium(
            'Synthèse combinant l\'inspection temps réel du dépôt GitHub, l\'activité de développement et les indicateurs d\'impact.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 24),

          // 1. Analyse Live GitHub (Si disponible)
          if (_githubAnalysisFuture != null) ...[
            const ResponsiveText.titleSmall(
              '🔍 Analyse Live du Dépôt GitHub',
              style: TextStyle(
                  color: Colors.cyanAccent, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FutureBuilder<GithubProjectTechInfo?>(
              future: _githubAnalysisFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: const Center(
                      child:
                          CircularProgressIndicator(color: ColorHelpers.cyan),
                    ),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return _buildTechFallbackCard(techDetails);
                }
                final data = snapshot.data!;
                return _buildGithubAnalysisCard(data);
              },
            ),
            const SizedBox(height: 32),
          ] else if (techDetails != null && techDetails.isNotEmpty) ...[
            const ResponsiveText.titleSmall(
              '💻 Spécifications & Architecture',
              style: TextStyle(
                  color: Colors.cyanAccent, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTechFallbackCard(techDetails),
            const SizedBox(height: 32),
          ],

          // 2. Résultats & Impact Métier (Badges lisibles)
          if (results.isNotEmpty) ...[
            const ResponsiveText.titleSmall(
              '🎯 Impact & Réalisations Clés',
              style: TextStyle(
                  color: Colors.cyanAccent, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            BadgeList(
              badges: _buildResultBadges(results),
            ),
            const SizedBox(height: 32),
          ],

          // 3. Activité de Développement (WakaTime & Supabase Live)
          const ResponsiveText.titleSmall(
            '📈 Métriques d\'Activité & Performance',
            style: TextStyle(
                color: Colors.cyanAccent, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 420,
            child: ActivityMetricsChart(
              project: widget.project,
              info: widget.info,
            ),
          ),

          const SizedBox(height: 32),

          // 4. Indicateurs Complémentaires (Graphiques structurés)
          if (_charts.isNotEmpty) ...[
            const ResponsiveText.titleSmall(
              '📊 Indicateurs Détaillés & Benchmarks',
              style: TextStyle(
                  color: Colors.cyanAccent, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 500,
              child: CompactChartsGrid(
                charts: _charts,
                info: widget.info,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGithubAnalysisCard(GithubProjectTechInfo data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.code, color: Colors.cyanAccent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: ResponsiveText.bodyMedium(
                  data.summary,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...data.languages
                  .map((l) => _buildChip('Langage: $l', Colors.blue)),
              ...data.frameworks
                  .map((f) => _buildChip('Framework: $f', Colors.purple)),
              ...data.platforms
                  .map((p) => _buildChip('Plateforme: $p', Colors.green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechFallbackCard(Map<String, dynamic>? techDetails) {
    if (techDetails == null || techDetails.isEmpty)
      return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: techDetails.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    color: Colors.cyanAccent, size: 16),
                const SizedBox(width: 8),
                ResponsiveText.bodySmall(
                  '${entry.key}: ',
                  style: const TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ResponsiveText.bodySmall(
                    '${entry.value}',
                    style: const TextStyle(color: Colors.white60),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChip(String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color[900]!.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color[400]!.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color[200], fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  List<Widget> _buildResultBadges(List<String> results) {
    return results.map((result) => BadgeWidget.result(result)).toList();
  }
}
