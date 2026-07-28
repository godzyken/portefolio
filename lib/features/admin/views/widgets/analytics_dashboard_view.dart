import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/ui_widgets_extentions.dart';
import '../providers/analytics_provider.dart';
import '../data/models/analytics_models.dart';

class AnalyticsDashboardView extends ConsumerWidget {
  const AnalyticsDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);
    final theme = Theme.of(context);

    return analyticsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur analytics: $e')),
      data: (projects) {
        if (services_isEmpty(projects)) {
          return const Center(child: Text('Aucune donnée de tracking pour le moment.'));
        }

        return RefreshIndicator(
          onPressed: () => ref.refresh(analyticsProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) => _ProjectAnalyticsCard(analytics: projects[index]),
          ),
        );
      },
    );
  }

  bool services_isEmpty(List<ProjectAnalytics> projects) => projects.isEmpty;
}

class _ProjectAnalyticsCard extends StatelessWidget {
  final ProjectAnalytics analytics;

  const _ProjectAnalyticsCard({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    analytics.projectName ?? analytics.projectId,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ID: ${analytics.projectId}',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimaryContainer),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                _buildStatItem(
                  context,
                  'Interactions',
                  analytics.totalInteractions.toString(),
                  Icons.touch_app_outlined,
                  Colors.blue,
                ),
                _buildStatItem(
                  context,
                  'Conversions',
                  analytics.totalConversions.toString(),
                  Icons.check_circle_outline,
                  Colors.green,
                ),
                _buildStatItem(
                  context,
                  'Taux',
                  '${analytics.conversionRate.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Détails par canal', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: analytics.actionsByType.entries.map((e) {
                return Chip(
                  label: Text('${e.key}: ${e.value}'),
                  backgroundColor: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
