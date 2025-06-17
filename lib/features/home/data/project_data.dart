class ProjectInfo {
  final String id;
  final String title;
  final List<String> points;
  final List<String>? image;
  final String? lienProjet;

  ProjectInfo({
    required this.id,
    required this.title,
    required this.points,
    this.image,
    this.lienProjet,
  });

  factory ProjectInfo.fromJson(Map<String, dynamic> json) {
    return ProjectInfo(
      id: json['id'],
      title: json['title'],
      points: List<String>.from(json['points']),
      image: json['image'] != null ? List<String>.from(json['image']) : null,
      lienProjet: json['lienProjet'],
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
