import 'package:flutter/material.dart';
import 'colors_spec.dart';

/// Framework de Maturité Technique basé sur les infographies FlutterSkills.
/// Utilisé pour "cadrer" la présentation des projets et expériences.
enum TechPillar {
  architecture(
    'Architecture',
    'Structure clean, modulaire et scalable.',
    Icons.architecture_rounded,
    ColorHelpers.purple,
  ),
  stateManagement(
    'State Management',
    'Gestion du flux de données prévisible et performante.',
    Icons.account_tree_rounded,
    ColorHelpers.blue,
  ),
  testing(
    'Testing',
    'Tests unitaires, widgets et intégration pour la fiabilité.',
    Icons.biotech_rounded,
    ColorHelpers.green,
  ),
  security(
    'Sécurité',
    'Protection des données et configurations sécurisées.',
    Icons.security_rounded,
    ColorHelpers.magenta,
  ),
  performance(
    'Performance',
    'Optimisation du rendu (60 FPS) et temps de chargement.',
    Icons.speed_rounded,
    ColorHelpers.cyan,
  ),
  cicd(
    'CI/CD',
    'Automatisation de l\'analyse, des tests et du déploiement.',
    Icons.loop_rounded,
    ColorHelpers.pink,
  ),
  monitoring(
    'Monitoring',
    'Suivi des erreurs, analytics et observabilité en prod.',
    Icons.insights_rounded,
    ColorHelpers.orange,
  ),
  aiSmart(
    'AI & Smart Features',
    'Intégration d\'IA et fonctionnalités intelligentes.',
    Icons.psychology_rounded,
    ColorHelpers.yellow,
  );

  final String label;
  final String description;
  final IconData icon;
  final Color color;

  const TechPillar(this.label, this.description, this.icon, this.color);

  static TechPillar? fromString(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('arch')) return TechPillar.architecture;
    if (lower.contains('state') || lower.contains('flux')) return TechPillar.stateManagement;
    if (lower.contains('test')) return TechPillar.testing;
    if (lower.contains('secu')) return TechPillar.security;
    if (lower.contains('perf')) return TechPillar.performance;
    if (lower.contains('ci') || lower.contains('cd') || lower.contains('auto')) return TechPillar.cicd;
    if (lower.contains('monitor') || lower.contains('analytic')) return TechPillar.monitoring;
    if (lower.contains('ai') || lower.contains('ia') || lower.contains('intel')) return TechPillar.aiSmart;
    return null;
  }
}

/// Widget de visualisation de la maturité technique
class TechMaturityRadar extends StatelessWidget {
  final Map<TechPillar, double> scores;
  final bool compact;

  const TechMaturityRadar({
    super.key,
    required this.scores,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: scores.entries.map((e) {
        final pillar = e.key;
        final score = e.value;

        return Tooltip(
          message: '${pillar.label}: ${(score * 100).toInt()}% - ${pillar.description}',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: pillar.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: pillar.color.withValues(alpha: 0.5 * score),
                width: 1.5,
              ),
              boxShadow: [
                if (score > 0.7)
                  BoxShadow(
                    color: pillar.color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(pillar.icon, size: 16, color: pillar.color),
                const SizedBox(width: 6),
                Text(
                  compact ? '' : pillar.label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(width: 4),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${(score * 100).toInt()}%',
                    style: TextStyle(
                      color: pillar.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Carte d'analyse IA pour la maturité
class IAMaturityAnalysisCard extends StatelessWidget {
  final Map<TechPillar, double> scores;

  const IAMaturityAnalysisCard({super.key, required this.scores});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorHelpers.surface,
            ColorHelpers.surfaceAlt.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorHelpers.cyan.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: ColorHelpers.cyan, size: 20),
              const SizedBox(width: 12),
              Text(
                'ANALYSE DE MATURITÉ (IA SOLUTION)',
                style: TextStyle(
                  color: ColorHelpers.cyan.withValues(alpha: 0.9),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TechMaturityRadar(scores: scores),
          const SizedBox(height: 12),
          Text(
            _generateAISummary(),
            style: const TextStyle(
              color: ColorHelpers.textSecondary,
              fontSize: 13,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _generateAISummary() {
    if (scores.isEmpty) return "Analyse en cours...";
    
    final topPillar = scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    
    return "Ce projet démontre une forte expertise en ${topPillar.label.toLowerCase()}. "
           "L'alignement avec les standards 'Flutter Production Readiness' garantit une solution scalable et maintenable.";
  }
}
