class AssetsConfig {
  // Configuration des assets selon l'environnement
  static const String githubUsername = 'godzyken';
  static const String repoName = 'portefolio';
  static const String branch = 'master';

  /// URL de base pour les assets sur GitHub
  static String get githubRawBaseUrl =>
      'https://raw.githubusercontent.com/$githubUsername/$repoName/$branch';

  /// URL du modèle 3D
  static String get characterModelUrl =>
      '$githubRawBaseUrl/assets_source/models/perso_samurail.glb';

  /// Chemin de l'avatar Rive
  static const String avatarRivePath = 'assets/images/animations/avatar_animate.riv';
}
