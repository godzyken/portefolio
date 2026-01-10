import 'dart:developer' as developer;

import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/parametres/themes/provider/theme_repository_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/provider/provider_extentions.dart';
import '../../generator/data/extention_models.dart';
import '../services/wakatime_service.dart';

/// Provider pour la clé API WakaTime (stockée localement)
final wakaTimeApiKeyProvider = FutureProvider<String?>((ref) async {
  developer.log('🔑 [WakaTime] Chargement de la clé API...', name: 'WakaTime');

  try {
    // 1. Vérifier SharedPreferences (utilisateur a configuré)
    final prefs = ref.read(sharedPreferencesProvider);
    final storedKey = prefs.getString('wakatime_api_key');

    if (storedKey != null && storedKey.isNotEmpty) {
      return storedKey;
    }

    // 2. Fallback sur les variables d'environnement
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
    developer.log('📊 [WakaTime] Récupération des stats pour: $range',
        name: 'WakaTime');

    final service = ref.watch(wakaTimeServiceProvider);
    if (service == null) {
      developer.log('❌ [WakaTime] Service non disponible', name: 'WakaTime');
      return null;
    }

    try {
      final stats = await service.getStats(range: range);

      if (stats == null) {
        developer.log('⚠️ [WakaTime] API retourne null pour $range',
            name: 'WakaTime');
        return null;
      }

      developer.log(
          '✅ [WakaTime] Stats reçues: ${stats.projects.length} projets, '
          '${stats.languages.length} langages',
          name: 'WakaTime');

      return stats;
    } catch (e, st) {
      developer.log('❌ [WakaTime] Erreur lors de la récupération des stats: $e',
          error: e, stackTrace: st, name: 'WakaTime');
      return null;
    }
  },
);

/// Provider pour les projets WakaTime
final wakaTimeProjectsProvider = FutureProvider<List<WakaTimeProject>>(
  (ref) async {
    developer.log('📂 [WakaTime] Récupération de la liste des projets...',
        name: 'WakaTime');

    final service = ref.watch(wakaTimeServiceProvider);

    if (service == null || service.apiKey.isEmpty) {
      developer.log('❌ [WakaTime] Service non disponible pour les projets',
          name: 'WakaTime');
      return [];
    }

    try {
      final projects = await service.getProjects();

      developer.log('✅ [WakaTime] ${projects.length} projets récupérés',
          name: 'WakaTime');

      if (projects.isNotEmpty) {
        developer.log(
            '📋 [WakaTime] Projets: ${projects.map((p) => p.name).join(", ")}',
            name: 'WakaTime');
      }

      return projects;
    } catch (e, st) {
      developer.log(
          '❌ [WakaTime] Erreur lors de la récupération des projets: $e',
          error: e,
          stackTrace: st,
          name: 'WakaTime');
      return [];
    }
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
  developer.log('⏱️ [WakaTime] Récupération des durées pour: $range',
      name: 'WakaTime');

  final service = ref.watch(wakaTimeServiceProvider);

  if (service == null) {
    developer.log('❌ [WakaTime] Service non disponible pour les durées',
        name: 'WakaTime');
    return [];
  }

  try {
    final durations = await service.getProjectDurations(range: range);

    developer.log('✅ [WakaTime] ${durations.length} durées récupérées',
        name: 'WakaTime');

    return durations;
  } catch (e, st) {
    developer.log('❌ [WakaTime] Erreur lors de la récupération des durées: $e',
        error: e, stackTrace: st, name: 'WakaTime');
    return [];
  }
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
  developer.log('🔍 [WakaTime] Recherche de match pour: "$projectTitle"',
      name: 'WakaTime');

  if (wakaProjects.isEmpty) {
    developer.log('⚠️ [WakaTime] Aucun projet WakaTime disponible',
        name: 'WakaTime');
    return null;
  }

  final titleLower = projectTitle.toLowerCase();
  final titleNormalized = titleLower.replaceAll(RegExp(r'[^a-z0-9]'), '');

  // 1. Correspondance exacte
  try {
    final exactMatch = wakaProjects.firstWhere(
      (p) => p.name.toLowerCase() == titleLower,
    );
    developer.log('✅ [WakaTime] Match exact trouvé: ${exactMatch.name}',
        name: 'WakaTime');
    return exactMatch;
  } catch (_) {}

  // 2. Correspondance normalisée
  try {
    final normalizedMatch = wakaProjects.firstWhere(
      (p) {
        final wakaNameNormalized =
            p.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        return wakaNameNormalized == titleNormalized;
      },
    );
    developer.log(
        '✅ [WakaTime] Match normalisé trouvé: ${normalizedMatch.name}',
        name: 'WakaTime');
    return normalizedMatch;
  } catch (_) {}

  // 3. Correspondance partielle bidirectionnelle
  try {
    final partialMatch = wakaProjects.firstWhere(
      (p) {
        final wakaNameLower = p.name.toLowerCase();
        final wakaNameNormalized =
            wakaNameLower.replaceAll(RegExp(r'[^a-z0-9]'), '');
        return wakaNameNormalized.contains(titleNormalized) ||
            titleNormalized.contains(wakaNameNormalized);
      },
    );
    developer.log('✅ [WakaTime] Match partiel trouvé: ${partialMatch.name}',
        name: 'WakaTime');
    return partialMatch;
  } catch (_) {}

  // 4. Correspondance par mots clés (minimum 4 caractères)
  try {
    final keywords = titleNormalized
        .split(RegExp(r'\s+'))
        .where((k) => k.length >= 4)
        .toList();

    if (keywords.isNotEmpty) {
      final keywordMatch = wakaProjects.firstWhere(
        (p) {
          final wakaNameNormalized =
              p.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
          return keywords
              .any((keyword) => wakaNameNormalized.contains(keyword));
        },
      );
      developer.log(
          '✅ [WakaTime] Match par mot-clé trouvé: ${keywordMatch.name}',
          name: 'WakaTime');
      return keywordMatch;
    }
  } catch (_) {}

  developer.log(
      '❌ [WakaTime] Aucun match trouvé pour "$projectTitle". '
      'Projets disponibles: ${wakaProjects.map((p) => p.name).join(", ")}',
      name: 'WakaTime');

  return null;
}

/// Provider combiné: fusionne projects.json avec données WakaTime
final enrichedProjectsProvider = FutureProvider<List<ProjectInfo>>((ref) async {
  developer.log('🔄 [WakaTime] Enrichissement des projets...',
      name: 'WakaTime');

  // 1. Charger les projets depuis le JSON
  final jsonProjects = await ref.watch(projectsProvider.future);
  developer.log('📂 [WakaTime] ${jsonProjects.length} projets JSON chargés',
      name: 'WakaTime');

  // 2. Récupérer les données WakaTime
  final wakaProjects = await ref.watch(wakaTimeProjectsProvider.future);
  final wakaDurations = await ref.watch(
    wakaTimeProjectDurationsProvider('last_7_days').future,
  );

  if (wakaDurations.isEmpty) {
    developer.log('⚠️ [WakaTime] Aucune durée WakaTime, projets non enrichis',
        name: 'WakaTime');
    return jsonProjects;
  }

  developer.log('✅ [WakaTime] ${wakaDurations.length} durées récupérées',
      name: 'WakaTime');

  // 3. Créer une map des durées par nom de projet
  final durationMap = <String, Duration>{};
  for (var durationEntry in wakaDurations) {
    durationMap[durationEntry.name.toLowerCase()] =
        Duration(seconds: durationEntry.totalSeconds.round());
  }

  // 4. Enrichir chaque projet
  int enrichedCount = 0;
  final enrichedList = jsonProjects.map((project) {
    final projectNameLower = project.title.toLowerCase();
    final projectNameNormalized =
        projectNameLower.replaceAll(RegExp(r'[^a-z0-9]'), '');
    Duration? timeSpent;

    for (var entry in durationMap.entries) {
      final wakaNameNormalized = entry.key.replaceAll(RegExp(r'[^a-z0-9]'), '');

      if (wakaNameNormalized.contains(projectNameNormalized) ||
          projectNameNormalized.contains(wakaNameNormalized)) {
        timeSpent = entry.value;
        enrichedCount++;
        developer.log(
            '✅ [WakaTime] Projet "${project.title}" enrichi avec ${entry.value}',
            name: 'WakaTime');
        break;
      }
    }

    return timeSpent != null ? project.copyWith(timeSpent: timeSpent) : project;
  }).toList();

  developer.log(
      '🎉 [WakaTime] Enrichissement terminé: $enrichedCount/${jsonProjects.length} projets enrichis',
      name: 'WakaTime');

  return enrichedList;
});

/// Provider pour vérifier si un projet est tracké sur WakaTime
final isProjectTrackedProvider =
    Provider.family<bool, String>((ref, projectTitle) {
  final wakaProjectsAsync = ref.watch(wakaTimeProjectsProvider);

  return wakaProjectsAsync.when(
    data: (wakaProjects) {
      if (wakaProjects.isEmpty) {
        developer.log('⚠️ [WakaTime] Aucun projet pour vérifier: $projectTitle',
            name: 'WakaTime');
        return false;
      }
      final match = _findMatchingProject(projectTitle, wakaProjects);
      final isTracked = match != null;

      developer.log(
          '${isTracked ? "✅" : "❌"} [WakaTime] Projet "$projectTitle" ${isTracked ? "est" : "n'est pas"} tracké',
          name: 'WakaTime');

      return isTracked;
    },
    loading: () {
      developer.log('⏳ [WakaTime] Vérification en cours pour: $projectTitle',
          name: 'WakaTime');
      return false;
    },
    error: (e, _) {
      developer.log('❌ [WakaTime] Erreur vérification tracking: $e',
          name: 'WakaTime');
      return false;
    },
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
    developer.log('❌ [WakaTime] Erreur projectTrackingStatusProvider: $e');
    return false;
  }
});

/// Provider pour le temps total passé sur un projet
final projectTimeSpentProvider = FutureProvider.family<Duration?, String>(
  (ref, projectTitle) async {
    developer.log('⏱️ [WakaTime] Calcul du temps pour: $projectTitle',
        name: 'WakaTime');

    try {
      final durationsAsync = await ref.watch(
        wakaTimeProjectDurationsProvider('last_7_days').future,
      );

      if (durationsAsync.isEmpty) {
        developer.log('⚠️ [WakaTime] Aucune durée disponible',
            name: 'WakaTime');
        return null;
      }

      final projectNameLower = projectTitle.toLowerCase();
      final projectNameNormalized =
          projectNameLower.replaceAll(RegExp(r'[^a-z0-9]'), '');

      for (final entry in durationsAsync) {
        final entryNameNormalized =
            entry.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

        if (entryNameNormalized.contains(projectNameNormalized) ||
            projectNameNormalized.contains(entryNameNormalized)) {
          final duration = Duration(seconds: entry.totalSeconds.round());
          developer.log(
              '✅ [WakaTime] Temps trouvé pour "$projectTitle": $duration',
              name: 'WakaTime');
          return duration;
        }
      }

      developer.log('⚠️ [WakaTime] Aucun temps trouvé pour: $projectTitle',
          name: 'WakaTime');
      return null;
    } catch (e, st) {
      developer.log('❌ [WakaTime] Erreur projectTimeSpentProvider: $e',
          error: e, stackTrace: st, name: 'WakaTime');
      return null;
    }
  },
);

final projectBadgeUrlProvider =
    Provider.family<String?, String>((ref, projectTitle) {
  final wakaProject = ref.watch(wakaTimeProjectProvider(projectTitle));

  if (wakaProject == null) {
    developer.log('⚠️ [WakaTime] Pas de badge pour: $projectTitle',
        name: 'WakaTime');
    return null;
  }

  final badgeUrl = WakaTimeService.getBadgeUrl(
    wakaProject.name,
    officialBadge: wakaProject.badge,
  );

  developer.log('🏷️ [WakaTime] Badge URL pour ${wakaProject.name}: $badgeUrl',
      name: 'WakaTime');

  return badgeUrl;
});

/// Notifier pour gérer la clé API
class WakaTimeApiKeyNotifier extends Notifier<String?> {
  @override
  String? build() {
    _loadApiKey();
    return null;
  }

  Future<void> _loadApiKey() async {
    developer.log(
        '🔑 [WakaTime] Chargement de la clé depuis SharedPreferences...',
        name: 'WakaTime');

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedKey = prefs.getString('wakatime_api_key');

      if (storedKey != null && storedKey.isNotEmpty) {
        developer.log('✅ [WakaTime] Clé chargée avec succès', name: 'WakaTime');

        SchedulerBinding.instance.addPostFrameCallback((_) {
          state = storedKey;
          ref.invalidate(wakaTimeServiceProvider);
        });
      } else {
        developer.log('⚠️ [WakaTime] Aucune clé dans SharedPreferences',
            name: 'WakaTime');
      }
    } catch (e) {
      developer.log('❌ [WakaTime] Erreur chargement clé: $e', name: 'WakaTime');
    }
  }

  Future<void> setApiKey(String key) async {
    developer.log('💾 [WakaTime] Sauvegarde de la nouvelle clé...',
        name: 'WakaTime');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('wakatime_api_key', key);

      SchedulerBinding.instance.addPostFrameCallback((_) {
        state = key;
        ref.invalidate(wakaTimeServiceProvider);
        developer.log('✅ [WakaTime] Clé sauvegardée et service réinitialisé',
            name: 'WakaTime');
      });
    } catch (e) {
      developer.log('❌ [WakaTime] Erreur sauvegarde clé: $e', name: 'WakaTime');
    }
  }

  Future<void> clearApiKey() async {
    developer.log('🗑️ [WakaTime] Suppression de la clé...', name: 'WakaTime');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('wakatime_api_key');

      SchedulerBinding.instance.addPostFrameCallback((_) {
        state = null;
        ref.invalidate(wakaTimeServiceProvider);
        developer.log('✅ [WakaTime] Clé supprimée', name: 'WakaTime');
      });
    } catch (e) {
      developer.log('❌ [WakaTime] Erreur suppression clé: $e',
          name: 'WakaTime');
    }
  }
}

final wakaTimeApiKeyNotifierProvider =
    NotifierProvider<WakaTimeApiKeyNotifier, String?>(
  WakaTimeApiKeyNotifier.new,
);
