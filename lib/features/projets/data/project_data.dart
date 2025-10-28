import 'dart:developer' as developer;

class ProjectInfo {
  final String id;
  final String title;
  final List<String> points;
  final List<String>? image;
  final String? youtubeVideoId;
  final String? lienProjet;
  final List<String>? platform;
  final List<String>? tags;
  final Duration? timeSpent;
  final Map<String, dynamic>? techDetails;
  final List<String>? results;

  ProjectInfo({
    required this.id,
    required this.title,
    required this.points,
    this.image,
    this.youtubeVideoId,
    this.lienProjet,
    this.platform,
    this.tags,
    this.timeSpent,
    this.techDetails,
    this.results,
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
    List<String>? platform,
    List<String>? tags,
    Duration? timeSpent,
    Map<String, dynamic>? techDetails,
    List<String>? results,
  }) {
    return ProjectInfo(
      id: id ?? this.id,
      title: title ?? this.title,
      points: points ?? this.points,
      image: image ?? this.image,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      lienProjet: lienProjet ?? this.lienProjet,
      platform: platform ?? this.platform,
      tags: tags ?? this.tags,
      timeSpent: timeSpent ?? this.timeSpent,
      techDetails: techDetails ?? this.techDetails,
      results: results ?? this.results,
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
      platform:
          json['platform'] != null ? List<String>.from(json['platform']) : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      techDetails: json['techDetails'] != null
          ? Map<String, dynamic>.from(json['techDetails'])
          : null,
      results:
          json['results'] != null ? List<String>.from(json['results']) : null,
    );
  }
}

final availableProjects = [
  ProjectInfo(
    id: '1',
    title: 'Développement Android',
    points: [
      'Material Design & UX',
      'SDK Android & Java',
      'Tests, déploiement Google Play',
      'Respect du RGPD',
    ],
    image: ['assets/images/android.png'],
    lienProjet: 'https://github.com/godzyken/android-app',
  ),
  ProjectInfo(
    id: '2',
    title: 'Développement Flutter',
    points: [
      'UI multiplateforme',
      'Flutter + Firebase + Riverpod',
      'Déploiement Android/iOS',
    ],
    image: ['assets/images/flutter.png'],
    lienProjet: 'https://github.com/godzyken/flutter-app',
  ),
  ProjectInfo(
    id: '3',
    title: 'Application pour entreprise du bâtiment',
    points: [
      'Suivi de chantier (IoT)',
      'Maquettes 3D + AR',
      'Modules RH et approvisionnement',
      'CRM et prospection intégrée',
    ],
    image: ['assets/images/construction.png'],
    lienProjet: 'https://github.com/godzyken/construction-app',
  ),
  ProjectInfo(
    id: '4',
    title: 'Rôles techniques : Architecte & Lead Dev',
    points: [
      '📐 Estimation des coûts et du temps de projet',
      '🧾 Définition des exigences et fonctionnalités',
      '📝 Rédaction du cahier des charges technique',
      '📅 Élaboration du planning des opérations',
      '🧪 Tests et mise en place des solutions techniques',
      '🔁 CI/CD, TDD, méthode agile',
      '💬 Analyse UX et retours utilisateurs en réunion',
    ],
    image: ['assets/images/roles.png'],
    lienProjet: 'https://github.com/godzyken/roles-techniques',
  ),
];

final iconByProjectTitle = {
  'SDK Android & Java': '📱',
  'Développement Flutter': '💡',
  'Application pour entreprise du bâtiment': '🛠',
  'Rôles techniques : Architecte & Lead Dev': '🧠',
  'Design /UX': '🎨',
  'Suivi de chantier (IoT)': '📈',
  'Maquettes 3D + AR': '🖼',
  'Modules RH et approvisionnement': '💼',
  'CRM et prospection intégrée': '📞',
  'Tests, déploiement Google Play': '🧪',
  'Backend / API': '🌐',
  'Securite': '🛡',
  'Respect du RGPD': '📄',
};
