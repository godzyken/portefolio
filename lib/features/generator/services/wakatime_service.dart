import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/extention_models.dart';

/// Service pour interagir avec l'API WakaTime
class WakaTimeService {
  static const String _baseUrl = 'https://wakatime.com/api/v1';
  static const String _corsProxy = 'https://api.allorigins.win/raw?url=';

  final String apiKey;

  WakaTimeService({required this.apiKey});

  String _buildUrl(String endpoint) {
    final fullUrl = '$_baseUrl$endpoint';

    // Sur le web, utiliser le proxy CORS
    if (kIsWeb) {
      return '$_corsProxy${Uri.encodeComponent(fullUrl)}';
    }

    return fullUrl;
  }

  /// Headers pour les requêtes authentifiées
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (!kIsWeb) {
      headers['Authorization'] =
          'Basic ${base64Encode(utf8.encode('$apiKey:'))}';
    }

    return headers;
  }

  Future<WakaTimeStats?> getStats({String range = 'last_7_days'}) async {
    try {
      String endpoint = '/users/current/stats/$range';
      if (kIsWeb) {
        endpoint += '?api_key=$apiKey';
      }

      final url = Uri.parse(_buildUrl(endpoint));
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WakaTimeStats.fromJson(data['data']);
      } else {
        developer.log('❌ Erreur WakaTime Stats: ${response.statusCode}');
        return null;
      }
    } catch (e, stack) {
      developer.log('❌ Exception WakaTime Stats', error: e, stackTrace: stack);
      return null;
    }
  }

  /// Récupère la liste des projets de l'utilisateur
  Future<List<WakaTimeProject>> getProjects() async {
    try {
      String endpoint = '/users/current/projects';
      if (kIsWeb) {
        endpoint += '?api_key=$apiKey';
      }

      final url = Uri.parse(_buildUrl(endpoint));
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> projects = data['data'] ?? [];
        return projects.map((json) => WakaTimeProject.fromJson(json)).toList();
      } else {
        developer.log('❌ Erreur WakaTime Projects: ${response.statusCode}');
        return [];
      }
    } catch (e, stack) {
      developer.log('❌ Exception WakaTime Projects',
          error: e, stackTrace: stack);
      return [];
    }
  }

  Future<List<WakaTimeProjectDuration>> getProjectDurations({
    String range = 'last_7_days',
  }) async {
    try {
      final stats = await getStats(range: range);
      if (stats == null) return [];
      final List<WakaTimeProjectDuration> durations = stats.projects
          .map((p) => WakaTimeProjectDuration(
                name: p.name,
                totalSeconds: p.totalSeconds,
              ))
          .toList();

      return durations;
    } catch (e, stack) {
      developer.log('❌ Erreur getProjectDurations',
          error: e, stackTrace: stack);
      return [];
    }
  }

  /// Récupère les langages utilisés par projet (simplifié)
  Future<Map<String, List<String>>> getProjectLanguages() async {
    try {
      final stats = await getStats(range: 'last_30_days');
      if (stats == null) return {};

      final Map<String, List<String>> projectLanguages = {};
      projectLanguages['global'] = stats.languages.map((l) => l.name).toList();

      return projectLanguages;
    } catch (e) {
      developer.log('❌ Erreur getProjectLanguages', error: e);
      return {};
    }
  }

  /// Génère l'URL du badge WakaTime pour un projet
  static String getBadgeUrl(String projectName,
      {WakaTimeBadge? officialBadge}) {
    if (officialBadge != null && officialBadge.url.isNotEmpty) {
      // Utiliser le badge officiel de l'API
      return kIsWeb
          ? '$_corsProxy${Uri.encodeComponent(officialBadge.url)}'
          : officialBadge.url;
    }

    // Fallback sur le badge générique GitHub
    final encodedName = Uri.encodeComponent(projectName);
    final badgeUrl = 'https://wakatime.com/badge/github/$encodedName.svg';

    return kIsWeb ? '$_corsProxy${Uri.encodeComponent(badgeUrl)}' : badgeUrl;
  }

  static String getUserBadgeUrl(String username) {
    final badgeUrl = 'https://wakatime.com/@$username.svg';

    if (kIsWeb) {
      return '$_corsProxy${Uri.encodeComponent(badgeUrl)}';
    }

    return badgeUrl;
  }
}

//
// ------------------ MODÈLES ------------------
//
