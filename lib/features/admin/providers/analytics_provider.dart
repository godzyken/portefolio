import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/service/supabase_service.dart';
import '../data/models/analytics_models.dart';

final analyticsProvider = FutureProvider<List<ProjectAnalytics>>((ref) async {
  if (!SupabaseService.isReady) return [];

  final response = await SupabaseService.client
      .from('portfolio_interactions')
      .select('project_id, project_name, action_type');

  final List<dynamic> data = response;

  // Grouping logic
  final Map<String, Map<String, dynamic>> grouped = {};

  for (final item in data) {
    final pid = item['project_id'] as String;
    final type = item['action_type'] as String;
    final name = item['project_name'] as String?;

    if (!grouped.containsKey(pid)) {
      grouped[pid] = {
        'id': pid,
        'name': name,
        'total': 0,
        'conversions': 0,
        'actions': <String, int>{},
      };
    }

    final entry = grouped[pid]!;
    entry['total'] = (entry['total'] as int) + 1;

    if (type == 'FORM_SUBMIT') {
      entry['conversions'] = (entry['conversions'] as int) + 1;
    }

    final actions = entry['actions'] as Map<String, int>;
    actions[type] = (actions[type] ?? 0) + 1;
  }

  return grouped.values
      .map((e) => ProjectAnalytics(
            projectId: e['id'] as String,
            projectName: e['name'] as String?,
            totalInteractions: e['total'] as int,
            totalConversions: e['conversions'] as int,
            actionsByType: e['actions'] as Map<String, int>,
          ))
      .toList();
});
