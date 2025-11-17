// DANS : lib/features/projects/models/wakatime_stats.dart

import 'dart:convert';

// Fonction utilitaire pour décoder la chaîne JSON principale
FullWakatimeStats fullWakatimeStatsFromJson(String str) =>
    FullWakatimeStats.fromJson(json.decode(str));

// Classe qui représente la racine de l'objet JSON (la clé "data")
class FullWakatimeStats {
  final WakatimeData data;

  FullWakatimeStats({required this.data});

  factory FullWakatimeStats.fromJson(Map<String, dynamic> json) =>
      FullWakatimeStats(
        data: WakatimeData.fromJson(json["data"]),
      );
}

// Classe principale qui contient toutes les listes et les champs de statistiques
class WakatimeData {
  final String humanReadableTotal;
  final List<Language> languages;
  final List<Project> projects;
  final List<Editor> editors;
  final String humanReadableDailyAverage;
  final BestDay bestDay;

  WakatimeData({
    required this.humanReadableTotal,
    required this.languages,
    required this.projects,
    required this.editors,
    required this.humanReadableDailyAverage,
    required this.bestDay,
  });

  factory WakatimeData.fromJson(Map<String, dynamic> json) => WakatimeData(
        humanReadableTotal: json["human_readable_total"] ?? '',
        languages: json["languages"] == null
            ? []
            : List<Language>.from(
                json["languages"]!.map((x) => Language.fromJson(x))),
        projects: json["projects"] == null
            ? []
            : List<Project>.from(
                json["projects"]!.map((x) => Project.fromJson(x))),
        editors: json["editors"] == null
            ? []
            : List<Editor>.from(
                json["editors"]!.map((x) => Editor.fromJson(x))),
        humanReadableDailyAverage: json["human_readable_daily_average"] ?? '',
        bestDay: BestDay.fromJson(json["best_day"] ?? {}),
      );
}

// Classe pour une entrée générique (utilisée par Language, Project, Editor)
class StatItem {
  final String name;
  final double percent;
  final String text;

  StatItem({
    required this.name,
    required this.percent,
    required this.text,
  });

  // Factory générique pour éviter la répétition
  factory StatItem.fromJson(Map<String, dynamic> json) => StatItem(
        name: json["name"] ?? 'Unknown',
        percent: (json["percent"] ?? 0.0).toDouble(),
        text: json["text"] ?? '',
      );
}

// Classes spécifiques qui héritent ou utilisent StatItem
class Language extends StatItem {
  Language({
    required super.name,
    required super.percent,
    required super.text,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    final item = StatItem.fromJson(json);
    return Language(name: item.name, percent: item.percent, text: item.text);
  }
}

class Project extends StatItem {
  Project({
    required super.name,
    required super.percent,
    required super.text,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    final item = StatItem.fromJson(json);
    return Project(name: item.name, percent: item.percent, text: item.text);
  }
}

class Editor extends StatItem {
  Editor({
    required super.name,
    required super.percent,
    required super.text,
  });

  factory Editor.fromJson(Map<String, dynamic> json) {
    final item = StatItem.fromJson(json);
    return Editor(name: item.name, percent: item.percent, text: item.text);
  }
}

// Classe pour le "Meilleur jour"
class BestDay {
  final DateTime date;
  final String text;
  final double totalSeconds;

  BestDay({
    required this.date,
    required this.text,
    required this.totalSeconds,
  });

  factory BestDay.fromJson(Map<String, dynamic> json) => BestDay(
        date: json["date"] == null
            ? DateTime.now()
            : DateTime.parse(json["date"]),
        text: json["text"] ?? '',
        totalSeconds: (json["total_seconds"] ?? 0.0).toDouble(),
      );
}
