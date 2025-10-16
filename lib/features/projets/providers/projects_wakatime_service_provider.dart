import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/parametres/themes/provider/theme_repository_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/provider/json_data_provider.dart';
import '../../generator/services/wakatime_service.dart';
import '../../projets/data/project_data.dart';

/// Provider pour la clé API WakaTime (stockée localement)
final wakaTimeApiKeyProvider = FutureProvider<String?>((ref) async {
  final prefs = ref.read(sharedPreferencesProvider);
  const apiKey = String.fromEnvironment('WAKATIME_API_KEY');
  return prefs.getString(apiKey);
});

/// Provider pour le service WakaTime
final wakaTimeServiceProvider = Provider<WakaTimeService?>((ref) {
  final apiKeyAsync = ref.watch(wakaTimeApiKeyProvider);
  return apiKeyAsync.maybeWhen(
    data: (key) => key != null ? WakaTimeService(apiKey: key) : null,
    orElse: () => null,
  );
});

/// Provider pour les statistiques WakaTime
final wakaTimeStatsProvider = FutureProvider.family<WakaTimeStats?, String>(
  (ref, range) async {
    final service = ref.watch(wakaTimeServiceProvider);
    if (service == null) return null;
    return await service.getStats(range: range);
  },
);

/// Provider pour les projets WakaTime
final wakaTimeProjectsProvider = FutureProvider<List<WakaTimeProject>>(
  (ref) async {
    final service = ref.watch(wakaTimeServiceProvider);
    if (service == null) return [];
    return await service.getProjects();
  },
);

final wakaTimeDurationsProvider =
    FutureProvider<List<WakaTimeProjectDuration>>((ref) async {
  final apiKey = await ref.watch(wakaTimeApiKeyProvider.future);
  if (apiKey == null) return [];
  final service = WakaTimeService(apiKey: apiKey);
  return service.getProjectDurations(range: 'last_7_days');
});

/// Provider pour les durées par projet
final wakaTimeProjectDurationsProvider =
    FutureProvider.family<List<WakaTimeProjectDuration>, String>(
        (ref, range) async {
  final service = ref.watch(wakaTimeServiceProvider);
  if (service == null) return [];
  return await service.getProjectDurations(range: range);
});

/// Provider combiné: fusionne projects.json avec données WakaTime
final enrichedProjectsProvider = FutureProvider<List<ProjectInfo>>((ref) async {
  // 1. Charger les projets depuis le JSON
  final jsonProjects = await ref.watch(projectsProvider.future);

  // 2. Récupérer les données WakaTime
  final wakaProjects = await ref.watch(wakaTimeProjectsProvider.future);
  final wakaDurations = await ref.watch(
    wakaTimeProjectDurationsProvider('last_7_days').future,
  );

  if (wakaDurations.isEmpty) {
    return jsonProjects;
  }

  // 3. Créer une map des projets WakaTime par nom
  final durationMap = <String, Duration>{};
  for (var durationEntry in wakaDurations) {
    durationMap[durationEntry.name.toLowerCase()] =
        Duration(seconds: durationEntry.totalSeconds.round());
  }
  final wakaProjectMap = {for (var p in wakaProjects) p.name.toLowerCase(): p};

  // 4. Enrichir chaque projet JSON avec les données WakaTime
  final enrichedList = jsonProjects.map((project) {
    final projectNameLower = project.title.toLowerCase();
    Duration? timeSpent;

    // Chercher une correspondance dans la map des durées.
    // Cette logique peut être aussi simple ou complexe que nécessaire.
    // Ici, on cherche une correspondance exacte ou partielle.
    for (var entry in durationMap.entries) {
      final wakaName = entry.key;
      if (wakaName.contains(projectNameLower) ||
          projectNameLower.contains(wakaName)) {
        timeSpent = entry.value;
        break; // On a trouvé une correspondance, on arrête la boucle.
      }
    }

    // Si on a trouvé une durée, on crée une copie enrichie du projet.
    if (timeSpent != null) {
      return project.copyWith(timeSpent: timeSpent);
    }

    // Si le projet existe dans WakaTime, on pourrait ajouter des métadonnées
    // Pour l'instant, on retourne tel quel
    return project;
  }).toList();

  return enrichedList;
});

/// Provider pour vérifier si un projet est tracké sur WakaTime
final isProjectTrackedProvider =
    Provider.family<bool, String>((ref, projectTitle) {
  final wakaProjectsAsync = ref.watch(wakaTimeProjectsProvider);

  return wakaProjectsAsync.maybeWhen(
    data: (wakaProjects) {
      final projectNameLower = projectTitle.toLowerCase();
      return wakaProjects.any(
        (p) =>
            p.name.toLowerCase().contains(projectNameLower) ||
            projectNameLower.contains(p.name.toLowerCase()),
      );
    },
    orElse: () => false,
  );
});

/// Provider pour le temps total passé sur un projet
final projectTimeSpentProvider = FutureProvider.family<Duration?, String>(
  (ref, projectTitle) async {
    final durationsAsync = await ref.watch(
      wakaTimeProjectDurationsProvider('last_7_days').future,
    );
    // Cherche le projet correspondant
    final projectNameLower = projectTitle.toLowerCase();

    for (final entry in durationsAsync) {
      if (entry.name.toLowerCase().contains(projectNameLower) ||
          projectNameLower.contains(entry.name.toLowerCase())) {
        // 🔹 Utilise totalSeconds pour une durée plus précise
        return Duration(seconds: entry.totalSeconds.round());
      }
    }

    return null;
  },
);

/// Notifier pour gérer la clé API
class WakaTimeApiKeyNotifier extends Notifier<String?> {
  @override
  String? build() {
    // Charge la clé depuis les préférences
    ref.watch(wakaTimeApiKeyProvider).whenData((key) {
      state = key;
    });
    return null;
  }

  Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wakatime_api_key', key);
    state = key;
    // Force le refresh des providers dépendants
    ref.invalidate(wakaTimeServiceProvider);
  }

  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('wakatime_api_key');
    state = null;
    ref.invalidate(wakaTimeServiceProvider);
  }
}

final wakaTimeApiKeyNotifierProvider =
    NotifierProvider<WakaTimeApiKeyNotifier, String?>(
  WakaTimeApiKeyNotifier.new,
);
