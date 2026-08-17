import 'dart:developer' as developer;

class ProjectInfo {
  final String id;
  final String title;
  final List<String> points;
  final List<String>? image;
  final String? youtubeVideoId;
  final String? lienProjet;

  /// Accroche narrative du projet pour le mode Storytelling
  final String? storyline;

  /// URL du repo GitHub source (ex: https://github.com/godzyken/mon-projet).
  /// Sert à récupérer dynamiquement les artefacts .md (.artefacts/{id}/*.md)
  /// ainsi qu'aux analyseurs GitHub existants (langages, README).
  final String? githubRepoUrl;
  final List<String>? platform;
  final List<String>? tags;
  final Duration? timeSpent;
  final Map<String, dynamic>? techDetails;

  /// Résultats textuels classiques
  final List<String>? results;

  /// Résultats structurés pour KPI (ventes, clients, démonstrations…)
  final Map<String, dynamic>? resultsMap;

  /// Nouveau champ pour l'analyse de développement (économie, ROI, coûts, etc.)
  final Map<String, dynamic>? development;

  ProjectInfo({
    required this.id,
    required this.title,
    required this.points,
    this.image,
    this.youtubeVideoId,
    this.lienProjet,
    this.storyline,
    this.githubRepoUrl,
    this.platform,
    this.tags,
    this.timeSpent,
    this.techDetails,
    this.results,
    this.resultsMap,
    this.development,
  });

  // Getter qui retourne les images nettoyées
  List<String>? get cleanedImages {
    if (image == null) return null;
    return image!.map((img) {
      // Nettoyer "assets/https://..." -> "https://..."
      if (img.contains('assets/http')) {
        final httpIndex = img.indexOf('http');
        if (httpIndex != -1) {
          img = img.substring(httpIndex);
        }
      }
      // Décoder les URLs encodées
      if (img.contains('%')) {
        try {
          img = Uri.decodeFull(img);
        } catch (e) {
          developer.log('⚠️ Erreur décodage: $img');
        }
      }
      return img;
    }).toList();
  }

  ProjectInfo copyWith({
    String? id,
    String? title,
    List<String>? points,
    List<String>? image,
    String? youtubeVideoId,
    String? lienProjet,
    String? storyline,
    String? githubRepoUrl,
    List<String>? platform,
    List<String>? tags,
    Duration? timeSpent,
    Map<String, dynamic>? techDetails,
    List<String>? results,
    Map<String, dynamic>? resultsMap,
    Map<String, dynamic>? development,
  }) {
    return ProjectInfo(
      id: id ?? this.id,
      title: title ?? this.title,
      points: points ?? this.points,
      image: image ?? this.image,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      lienProjet: lienProjet ?? this.lienProjet,
      storyline: storyline ?? this.storyline,
      githubRepoUrl: githubRepoUrl ?? this.githubRepoUrl,
      platform: platform ?? this.platform,
      tags: tags ?? this.tags,
      timeSpent: timeSpent ?? this.timeSpent,
      techDetails: techDetails ?? this.techDetails,
      results: results ?? this.results,
      resultsMap: resultsMap ?? this.resultsMap,
      development: development ?? this.development,
    );
  }

  factory ProjectInfo.fromJson(Map<String, dynamic> json) {
    return ProjectInfo(
      id: json['id'],
      title: json['title'],
      points: List<String>.from(json['points']),
      image: json['image'] != null ? List<String>.from(json['image']) : null,
      youtubeVideoId: json['youtubeVideoId'],
      lienProjet: json['lienProjet'],
      storyline: json['storyline'],
      githubRepoUrl: json['githubRepoUrl'],
      platform:
          json['platform'] != null ? List<String>.from(json['platform']) : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      techDetails: json['techDetails'] != null
          ? Map<String, dynamic>.from(json['techDetails'])
          : null,
      results:
          json['results'] != null ? List<String>.from(json['results']) : null,
      resultsMap: json['resultsMap'] != null
          ? Map<String, dynamic>.from(json['resultsMap'])
          : null,
      development: json['development'] != null
          ? Map<String, dynamic>.from(json['development'])
          : null,
    );
  }
}
