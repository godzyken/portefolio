import 'dart:developer' as developer;
import '../service/supabase_service.dart';

enum TrackingAction {
  whatsapp,
  call,
  email,
  formSubmit,
  linkClick,
  avatarQuestionAsked,
  avatarDepthMilestone,
  avatarLeadQualified
}

class TrackingService {
  Future<void> trackInteraction({
    required String projectId,
    String? projectName,
    required TrackingAction action,
    Map<String, dynamic>? details,
  }) async {
    if (!SupabaseService.isReady) {
      developer.log('⚠️ Tracking ignored: Supabase not ready',
          name: 'TrackingService');
      return;
    }

    try {
      final actionStr = action.name.toUpperCase();

      // 1. Log détaillé (Historique)
      await SupabaseService.client.from('portfolio_interactions').insert({
        'project_id': projectId,
        'project_name': projectName,
        'action_type': actionStr,
        'details': details,
      });

      // 2. Flux Live (Graphiques Artisan)
      // Si c'est une interaction sur le portfolio, on l'envoie aussi dans app_analytics
      try {
        await SupabaseService.client.from('app_analytics').insert({
          'app_id': projectId == 'portfolio' || projectId == 'portefolio'
              ? 'portfolio'
              : projectId,
          'event_type': actionStr.toLowerCase(),
          'value': 1.0,
        });
      } catch (_) {
        // Optionnel : ignorer si la table n'existe pas encore ou erreur de contrainte
      }

      developer.log('✅ Interaction tracked & Live event sent: $projectId',
          name: 'TrackingService');
    } catch (e, st) {
      developer.log('❌ Failed to track interaction',
          name: 'TrackingService', error: e, stackTrace: st);
    }
  }
}
