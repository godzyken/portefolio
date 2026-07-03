import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';

/// Source de données WakaTime "statique".
///
/// L'app ne peut pas appeler l'API WakaTime directement depuis le navigateur
/// (CORS + clé API exposée dans le bundle JS). À la place, un job planifié
/// GitHub Actions (`update_wakatime_stats.yml`) régénère régulièrement
/// `assets/data/wakatime_stats.json` côté serveur, et l'app se contente de
/// lire ce fichier embarqué dans les assets.
class WakaTimeStaticSource {
  WakaTimeStaticSource._();
  static const String _assetPath = 'assets/data/wakatime_stats.json';
  static WakaTimeStats? _cachedStats;
  static List<WakaTimeProjectDuration>? _cachedDurations;

  /// Charge et parse `wakatime_stats.json`. Le résultat est mis en cache
  /// pour la durée de vie de l'app (le fichier ne change qu'au build).
  static Future<WakaTimeStats?> loadStats() async {
    if (_cachedStats != null) {
      return _cachedStats!;
    }

    try {
      final jsonStr = await rootBundle.loadString(_assetPath);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>?;

      if (data == null) {
        developer.log('⚠️ [WakaTime] "data" absent de $_assetPath',
            name: 'WakaTime');
        return null;
      }

      final stats = WakaTimeStats.fromJson(data);
      _cachedStats = stats;
      developer.log(
          '✅ [WakaTime] Stats chargées depuis ${stats.projects.length} projets',
          name: 'WakaTime');

      return stats;
    } catch (e, st) {
      developer.log('❌ [WakaTime] Erreur de lecture de $_assetPath: $e',
          error: e, stackTrace: st, name: 'WakaTime');
      return null;
    }
  }

  /// Durées par projet, dérivées de `stats.projects` (déjà présent dans le
  /// JSON statique : pas besoin de l'ancien endpoint `/users/current/projects`).
  static Future<List<WakaTimeProjectDuration>> loadProjectDurations() async {
    if (_cachedDurations != null) {
      return _cachedDurations!;
    }

    final stats = await loadStats();
    if (stats == null) {
      return [];
    }

    final durations = stats.projects
        .map((p) => WakaTimeProjectDuration(
              name: p.name,
              totalSeconds: p.totalSeconds,
            ))
        .toList();

    _cachedDurations = durations;
    return durations;
  }

  /// Liste "simplifiée" de projets WakaTime, dérivée elle aussi du JSON
  /// statique. Les champs indisponibles hors-ligne (badge officiel, repo,
  /// dates de heartbeat) sont laissés à leurs valeurs par défaut : ils ne
  /// sont pas nécessaires pour le matching par nom ni pour générer l'URL de
  /// badge publique (voir `WakaTimeService.getBadgeUrl`).
  static Future<List<WakaTimeProject>> loadProjects() async {
    final stats = await loadStats();
    if (stats == null) {
      return [];
    }

    final now = DateTime.now();
    return stats.projects
        .map((p) => WakaTimeProject(
            id: p.name,
            name: p.name,
            createdAt: now,
            lastHeartbeatAt: null,
            hasPublicUrl: false))
        .toList();
  }
}
