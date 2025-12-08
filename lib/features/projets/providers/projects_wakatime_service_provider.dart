import 'dart:developer' as developer;

import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/parametres/themes/provider/theme_repository_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/provider/provider_extentions.dart';
import '../../generator/data/extention_models.dart';
import '../../generator/services/wakatime_service.dart';

/// Provider pour la clé API WakaTime (stockée localement)
final wakaTimeApiKeyProvider = FutureProvider<String?>((ref) async {
  // 1. Vérifier SharedPreferences (utilisateur a configuré)
  final prefs = ref.read(sharedPreferencesProvider);
  final storedKey = prefs.getString('wakatime_api_key');

  if (storedKey != null && storedKey.isNotEmpty) {
    return storedKey;
  }

  // 2. Fallback sur les variables d'environnement
  try {
    final envKey = ref.watch(wakaTimeApiKeyConfigProvider);
    return envKey;
  } catch (e) {
    developer.log('ℹ️ WakaTime non configuré (optionnel)');
    return null;
  }
});

/// Provider pour le service WakaTime
final wakaTimeServiceProvider = Provider<WakaTimeService?>((ref) {
  final apiKeyAsync = ref.watch(wakaTimeApiKeyProvider);
  return apiKeyAsync.maybeWhen(
    data: (key) {
      if (key == null || key.isEmpty) {
        return null;
      }
      return WakaTimeService(apiKey: key);
    },
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
    if (service == null || service.apiKey.isEmpty) return [];
    return await service.getProjects();
  },
);

final wakaTimeDurationsProvider =
    FutureProvider<List<WakaTimeProjectDuration>>((ref) async {
  final apiKey = await ref.watch(wakaTimeApiKeyProvider.future);
  if (apiKey == null || apiKey.isEmpty) return [];
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

final wakaTimeProjectProvider =
    Provider.family<WakaTimeProject?, String>((ref, projectTitle) {
  final wakaProjectsAsync = ref.watch(wakaTimeProjectsProvider);

  return wakaProjectsAsync.when(
    data: (wakaProjects) {
      return _findMatchingProject(projectTitle, wakaProjects);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

WakaTimeProject? _findMatchingProject(
  String projectTitle,
  List<WakaTimeProject> wakaProjects,
) {
  // Si pas de projets WakaTime, retourner null
  if (wakaProjects.isEmpty) return null;

  final titleLower = projectTitle.toLowerCase();

  // 1. Correspondance exacte
  try {
    final exactMatch = wakaProjects.firstWhere(
      (p) => p.name.toLowerCase() == titleLower,
    );
    return exactMatch;
  } catch (_) {
    // Pas de correspondance exacte, continuer
  }

  // 2. Correspondance partielle bidirectionnelle
  try {
    final partialMatch = wakaProjects.firstWhere(
      (p) {
        final wakaNameLower = p.name.toLowerCase();
        return wakaNameLower.contains(titleLower) ||
            titleLower.contains(wakaNameLower);
      },
    );
    return partialMatch;
  } catch (_) {
    // Pas de correspondance partielle, continuer
  }

  // 3. Correspondance par mots clés
  try {
    final keywords = titleLower.split(RegExp(r'[\s_-]'));
    final keywordMatch = wakaProjects.firstWhere(
      (p) {
        final wakaNameLower = p.name.toLowerCase();
        return keywords.any(
            (keyword) => keyword.length > 3 && wakaNameLower.contains(keyword));
      },
    );
    return keywordMatch;
  } catch (_) {
    // Pas de correspondance par mots-clés
  }

  // Aucune correspondance trouvée
  return null;
}

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

  // 4. Enrichir chaque projet JSON avec les données WakaTime
  final enrichedList = jsonProjects.map((project) {
    final projectNameLower = project.title.toLowerCase();
    Duration? timeSpent;

    for (var entry in durationMap.entries) {
      final wakaName = entry.key;
      if (wakaName.contains(projectNameLower) ||
          projectNameLower.contains(wakaName)) {
        timeSpent = entry.value;
        break;
      }
    }

    if (timeSpent != null) {
      return project.copyWith(timeSpent: timeSpent);
    }

    return project;
  }).toList();

  return enrichedList;
});

/// Provider pour vérifier si un projet est tracké sur WakaTime
final isProjectTrackedProvider =
    Provider.family<bool, String>((ref, projectTitle) {
  final wakaProjectsAsync = ref.watch(wakaTimeProjectsProvider);

  return wakaProjectsAsync.when(
    data: (wakaProjects) {
      if (wakaProjects.isEmpty) return false;
      final match = _findMatchingProject(projectTitle, wakaProjects);
      return match != null;
    },
    loading: () => false,
    error: (_, __) => false,
  );
});

final projectTrackingStatusProvider =
    FutureProvider.family<bool, String>((ref, projectTitle) async {
  try {
    final wakaProjects = await ref.watch(wakaTimeProjectsProvider.future);
    if (wakaProjects.isEmpty) return false;
    final match = _findMatchingProject(projectTitle, wakaProjects);
    return match != null;
  } catch (e) {
    developer.log('Erreur projectTrackingStatusProvider: $e');
    return false;
  }
});

/// Provider pour le temps total passé sur un projet
final projectTimeSpentProvider = FutureProvider.family<Duration?, String>(
  (ref, projectTitle) async {
    try {
      final durationsAsync = await ref.watch(
        wakaTimeProjectDurationsProvider('last_7_days').future,
      );

      if (durationsAsync.isEmpty) return null;

      final projectNameLower = projectTitle.toLowerCase();

      for (final entry in durationsAsync) {
        if (entry.name.toLowerCase().contains(projectNameLower) ||
            projectNameLower.contains(entry.name.toLowerCase())) {
          return Duration(seconds: entry.totalSeconds.round());
        }
      }

      return null;
    } catch (e) {
      developer.log('Erreur projectTimeSpentProvider: $e');
      return null;
    }
  },
);

final projectBadgeUrlProvider =
    Provider.family<String?, String>((ref, projectTitle) {
  final wakaProject = ref.watch(wakaTimeProjectProvider(projectTitle));

  if (wakaProject == null) return null;

  return WakaTimeService.getBadgeUrl(
    wakaProject.name,
    officialBadge: wakaProject.badge,
  );
});

/// Notifier pour gérer la clé API
class WakaTimeApiKeyNotifier extends Notifier<String?> {
  @override
  String? build() {
    _loadApiKey();
    return null;
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final storedKey = prefs.getString('wakatime_api_key');
    if (storedKey != null && storedKey.isNotEmpty) {
      developer
          .log('Charge la clé WakaTime depuis les préférences: $storedKey');

      SchedulerBinding.instance.addPostFrameCallback((_) {
        state = storedKey;
        ref.invalidate(wakaTimeServiceProvider);
      });
    }
  }

  Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wakatime_api_key', key);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      state = key;
      ref.invalidate(wakaTimeServiceProvider);
    });
  }

  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('wakatime_api_key');
    SchedulerBinding.instance.addPostFrameCallback((_) {
      state = null;
      ref.invalidate(wakaTimeServiceProvider);
    });
  }
}

final wakaTimeApiKeyNotifierProvider =
    NotifierProvider<WakaTimeApiKeyNotifier, String?>(
  WakaTimeApiKeyNotifier.new,
);
