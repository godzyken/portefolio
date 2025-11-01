import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

/// Service pour interagir avec l'API WakaTime
class WakaTimeService {
  static const String _baseUrl = 'https://wakatime.com/api/v1';
  final String apiKey;

  WakaTimeService({required this.apiKey});

  /// Headers pour les requêtes authentifiées
  Map<String, String> get _headers => {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:'))}',
        'Content-Type': 'application/json',
      };

  /// Récupère les statistiques de l'utilisateur
  /// [range] peut être: last_7_days, last_30_days, last_6_months, last_year
  Future<WakaTimeStats?> getStats({String range = 'last_7_days'}) async {
    try {
      final url = Uri.parse('$_baseUrl/users/current/stats/$range');
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
      final url = Uri.parse('$_baseUrl/users/current/projects');
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

  /// ✅ Récupère les durées cumulées par projet à partir des statistiques
  Future<List<WakaTimeProjectDuration>> getProjectDurations({
    String range = 'last_7_days',
  }) async {
    try {
      final stats = await getStats(range: range);
      if (stats == null) return [];

      final List<WakaTimeProjectDuration> durations = stats.projects
          .map((p) => WakaTimeProjectDuration(
                name: p.name,
                totalSeconds: p.totalSeconds.toDouble(),
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
  static String getBadgeUrl(String projectName) {
    final encodedName = Uri.encodeComponent(projectName);
    return 'https://wakatime.com/badge/github/$encodedName.svg';
  }
}

//
// ------------------ MODÈLES ------------------
//

class WakaTimeStats {
  final Duration totalSeconds;
  final List<WakaTimeProjectStat> projects;
  final List<WakaTimeLanguage> languages;
  final List<WakaTimeEditor> editors;
  final String range;

  WakaTimeStats({
    required this.totalSeconds,
    required this.projects,
    required this.languages,
    required this.editors,
    required this.range,
  });

  factory WakaTimeStats.fromJson(Map<String, dynamic> json) {
    return WakaTimeStats(
      totalSeconds: Duration(seconds: json['total_seconds'] ?? 0),
      projects: (json['projects'] as List?)
              ?.map((p) => WakaTimeProjectStat.fromJson(p))
              .toList() ??
          [],
      languages: (json['languages'] as List?)
              ?.map((l) => WakaTimeLanguage.fromJson(l))
              .toList() ??
          [],
      editors: (json['editors'] as List?)
              ?.map((e) => WakaTimeEditor.fromJson(e))
              .toList() ??
          [],
      range: json['range'] ?? '',
    );
  }
}

class WakaTimeProjectStat {
  final String name;
  final int totalSeconds;
  final double percent;
  final String digital;
  final String text;

  WakaTimeProjectStat({
    required this.name,
    required this.totalSeconds,
    required this.percent,
    required this.digital,
    required this.text,
  });

  factory WakaTimeProjectStat.fromJson(Map<String, dynamic> json) {
    return WakaTimeProjectStat(
      name: json['name'] ?? '',
      totalSeconds: json['total_seconds'] ?? 0,
      percent: (json['percent'] ?? 0).toDouble(),
      digital: json['digital'] ?? '0:00',
      text: json['text'] ?? '0 secs',
    );
  }
}

class WakaTimeProject {
  final String id;
  final String name;
  final String? repository;
  final DateTime createdAt;
  final DateTime lastHeartbeatAt;

  WakaTimeProject({
    required this.id,
    required this.name,
    this.repository,
    required this.createdAt,
    required this.lastHeartbeatAt,
  });

  factory WakaTimeProject.fromJson(Map<String, dynamic> json) {
    return WakaTimeProject(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      repository: json['repository'],
      createdAt: DateTime.parse(json['created_at']),
      lastHeartbeatAt: DateTime.parse(json['last_heartbeat_at']),
    );
  }
}

class WakaTimeLanguage {
  final String name;
  final int totalSeconds;
  final double percent;

  WakaTimeLanguage({
    required this.name,
    required this.totalSeconds,
    required this.percent,
  });

  factory WakaTimeLanguage.fromJson(Map<String, dynamic> json) {
    return WakaTimeLanguage(
      name: json['name'] ?? '',
      totalSeconds: json['total_seconds'] ?? 0,
      percent: (json['percent'] ?? 0).toDouble(),
    );
  }
}

class WakaTimeEditor {
  final String name;
  final int totalSeconds;
  final double percent;

  WakaTimeEditor({
    required this.name,
    required this.totalSeconds,
    required this.percent,
  });

  factory WakaTimeEditor.fromJson(Map<String, dynamic> json) {
    return WakaTimeEditor(
      name: json['name'] ?? '',
      totalSeconds: json['total_seconds'] ?? 0,
      percent: (json['percent'] ?? 0).toDouble(),
    );
  }
}

class WakaTimeProjectDuration {
  final String name;
  final double totalSeconds;

  WakaTimeProjectDuration({required this.name, required this.totalSeconds});

  double get totalHours => totalSeconds / 3600;
}
