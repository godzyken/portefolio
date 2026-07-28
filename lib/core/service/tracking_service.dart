import 'dart:developer' as developer;
import '../service/supabase_service.dart';

enum TrackingAction { whatsapp, call, email, formSubmit, linkClick }

class TrackingService {
  Future<void> trackInteraction({
    required String projectId,
    String? projectName,
    required TrackingAction action,
    Map<String, dynamic>? details,
  }) async {
    if (!SupabaseService.isReady) {
      developer.log('⚠️ Tracking ignored: Supabase not ready', name: 'TrackingService');
      return;
    }

    try {
      final actionStr = action.name.toUpperCase();
      await SupabaseService.client.from('portfolio_interactions').insert({
        'project_id': projectId,
        'project_name': projectName,
        'action_type': actionStr,
        'details': details,
      });
      developer.log('✅ Interaction tracked: $projectId -> $actionStr', name: 'TrackingService');
    } catch (e, st) {
      developer.log('❌ Failed to track interaction', name: 'TrackingService', error: e, stackTrace: st);
    }
  }
}
