import 'package:equatable/equatable.dart';

/// Type d'origine d'une métrique
enum MetricStatus {
  real,
  calculated,
  estimated,
  unavailable,
}

/// Domaines de métriques pour classification
enum MetricDomain {
  event,
  googleAnalytics,
  searchConsole,
  seo,
  performance,
  accessibility,
  bestPractices,
  geo,
  kpi,
}

/// Modèle pour une métrique individuelle
class ProjectMetric extends Equatable {
  final String key;
  final String label;
  final dynamic value;
  final String unit;
  final String source;
  final MetricStatus status;
  final DateTime? timestamp;
  final Map<String, dynamic>? metadata;

  const ProjectMetric({
    required this.key,
    required this.label,
    required this.value,
    this.unit = '',
    required this.source,
    required this.status,
    this.timestamp,
    this.metadata,
  });

  @override
  List<Object?> get props =>
      [key, label, value, unit, source, status, timestamp, metadata];
}

/// Résultat d'un audit (SEO, Performance, etc.)
class AuditResult extends Equatable {
  final String title;
  final double score;
  final List<AuditItem> items;
  final MetricStatus status;
  final DateTime date;

  const AuditResult({
    required this.title,
    required this.score,
    required this.items,
    required this.status,
    required this.date,
  });

  @override
  List<Object?> get props => [title, score, items, status, date];
}

class AuditItem extends Equatable {
  final String label;
  final AuditStatus status;
  final String? message;

  const AuditItem({
    required this.label,
    required this.status,
    this.message,
  });

  @override
  List<Object?> get props => [label, status, message];
}

enum AuditStatus {
  pass,
  warning,
  fail,
  unavailable,
}

/// Snapshot de performance projet pour l'historique
class ProjectSnapshot extends Equatable {
  final String projectId;
  final DateTime date;
  final double? seoScore;
  final double? performanceScore;
  final double? accessibilityScore;
  final double? geoScore;
  final Map<String, dynamic>? metrics;

  const ProjectSnapshot({
    required this.projectId,
    required this.date,
    this.seoScore,
    this.performanceScore,
    this.accessibilityScore,
    this.geoScore,
    this.metrics,
  });

  @override
  List<Object?> get props => [
        projectId,
        date,
        seoScore,
        performanceScore,
        accessibilityScore,
        geoScore,
        metrics
      ];
}

/// Objet global regroupant toutes les analytics d'un projet
class ProjectAnalytics extends Equatable {
  final String projectId;
  final Map<MetricDomain, List<ProjectMetric>> metrics;
  final Map<MetricDomain, AuditResult> audits;
  final List<ProjectSnapshot> history;

  const ProjectAnalytics({
    required this.projectId,
    required this.metrics,
    required this.audits,
    required this.history,
  });

  @override
  List<Object?> get props => [projectId, metrics, audits, history];

  factory ProjectAnalytics.empty(String projectId) {
    return ProjectAnalytics(
      projectId: projectId,
      metrics: {},
      audits: {},
      history: [],
    );
  }
}
