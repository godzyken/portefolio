import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/service/supabase_service.dart';
import 'analytics_models.dart';

class ProjectAnalyticsRepository {
  final SupabaseClient _client;

  ProjectAnalyticsRepository(this._client);

  /// Récupère toutes les analytics pour un projet donné
  Future<ProjectAnalytics> getProjectAnalytics(String projectId) async {
    // Dans une version réelle, on appellerait plusieurs sources ou une API backend
    // Ici on agrège les données Supabase existantes et on mock le reste pour la démo

    final eventMetrics = await _fetchEventMetrics(projectId);
    final audits = _generateMockAudits(projectId);
    final history = _generateMockHistory(projectId);

    return ProjectAnalytics(
      projectId: projectId,
      metrics: {
        MetricDomain.event: eventMetrics,
        MetricDomain.kpi: _fetchKpiMetrics(projectId, eventMetrics),
      },
      audits: audits,
      history: history,
    );
  }

  Future<List<ProjectMetric>> _fetchEventMetrics(String projectId) async {
    if (!SupabaseService.isReady) return [];

    try {
      final response = await _client
          .from('app_analytics')
          .select()
          .eq('app_id', projectId)
          .order('created_at', ascending: false)
          .limit(100);

      final List<dynamic> data = response as List<dynamic>;

      // Grouper par type d'événement pour avoir des métriques agrégées
      final Map<String, int> counts = {};
      for (var item in data) {
        final type = item['event_type'] as String;
        counts[type] = (counts[type] ?? 0) + 1;
      }

      return counts.entries.map((e) {
        return ProjectMetric(
          key: 'event_${e.key}',
          label: _formatEventLabel(e.key),
          value: e.value,
          unit: 'actions',
          source: 'Supabase Live',
          status: MetricStatus.real,
          timestamp: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  List<ProjectMetric> _fetchKpiMetrics(
      String projectId, List<ProjectMetric> events) {
    // Calculer des KPIs à partir des événements réels
    final List<ProjectMetric> kpis = [];

    final phoneClicks = events.where((m) => m.key == 'event_call').firstOrNull;
    final emailClicks = events.where((m) => m.key == 'event_email').firstOrNull;

    if (phoneClicks != null || emailClicks != null) {
      final totalConversions =
          (phoneClicks?.value as int? ?? 0) + (emailClicks?.value as int? ?? 0);
      kpis.add(ProjectMetric(
        key: 'total_leads',
        label: 'Leads générés',
        value: totalConversions,
        unit: 'contacts',
        source: 'Portfolio Tracking',
        status: MetricStatus.calculated,
      ));
    }

    return kpis;
  }

  Map<MetricDomain, AuditResult> _generateMockAudits(String projectId) {
    // Pour la démo V2, on génère des audits si le projet est emap_services
    if (projectId != 'emap_services') return {};

    return {
      MetricDomain.seo: AuditResult(
        title: 'SEO Global',
        score: 84,
        status: MetricStatus.calculated,
        date: DateTime.now(),
        items: const [
          AuditItem(label: 'HTTPS', status: AuditStatus.pass),
          AuditItem(label: 'Sitemap', status: AuditStatus.pass),
          AuditItem(label: 'Metadata', status: AuditStatus.pass),
          AuditItem(
              label: 'Core Web Vitals',
              status: AuditStatus.warning,
              message: 'LCP légèrement élevé'),
        ],
      ),
      MetricDomain.performance: AuditResult(
        title: 'Performance',
        score: 96,
        status: MetricStatus.real,
        date: DateTime.now(),
        items: const [
          AuditItem(label: 'First Contentful Paint', status: AuditStatus.pass),
          AuditItem(label: 'Time to Interactive', status: AuditStatus.pass),
          AuditItem(label: 'Speed Index', status: AuditStatus.pass),
        ],
      ),
      MetricDomain.geo: AuditResult(
        title: 'AI Visibility (GEO)',
        score: 72,
        status: MetricStatus.calculated,
        date: DateTime.now(),
        items: const [
          AuditItem(label: 'Entity Clarity', status: AuditStatus.pass),
          AuditItem(label: 'Structured Data', status: AuditStatus.pass),
          AuditItem(label: 'AI Discoverability', status: AuditStatus.warning),
        ],
      ),
    };
  }

  List<ProjectSnapshot> _generateMockHistory(String projectId) {
    if (projectId != 'emap_services') return [];

    final now = DateTime.now();
    return [
      ProjectSnapshot(
        projectId: projectId,
        date: now.subtract(const Duration(days: 60)),
        seoScore: 61,
        performanceScore: 88,
      ),
      ProjectSnapshot(
        projectId: projectId,
        date: now.subtract(const Duration(days: 30)),
        seoScore: 74,
        performanceScore: 92,
      ),
      ProjectSnapshot(
        projectId: projectId,
        date: now,
        seoScore: 84,
        performanceScore: 96,
      ),
    ];
  }

  String _formatEventLabel(String key) {
    switch (key.toLowerCase()) {
      case 'call':
        return 'Clics Téléphone';
      case 'email':
        return 'Clics Email';
      case 'whatsapp':
        return 'Clics WhatsApp';
      case 'formsubmit':
        return 'Formulaires';
      default:
        return key[0].toUpperCase() + key.substring(1);
    }
  }
}
