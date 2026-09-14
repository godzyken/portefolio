import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/service/supabase_service.dart';
import '../data/analytics_models.dart';
import '../data/analytics_repository.dart';

/// Provider pour le repository analytics
final analyticsRepositoryProvider = Provider<ProjectAnalyticsRepository>((ref) {
  return ProjectAnalyticsRepository(SupabaseService.client);
});

/// Provider pour les analytics d'un projet spécifique
final projectAnalyticsProvider =
    FutureProvider.family<ProjectAnalytics, String>((ref, projectId) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getProjectAnalytics(projectId);
});

/// Provider pour vérifier si un projet a des analytics activées
final isAnalyticsEnabledProvider =
    Provider.family<bool, String>((ref, projectId) {
  // Pour l'instant, on active pour emap_services et si on a des données live
  // On pourrait étendre cela via une config dans ProjectInfo
  if (projectId == 'emap_services') return true;

  // On peut aussi vérifier si le projet a un analyticsId valide
  return true;
});
