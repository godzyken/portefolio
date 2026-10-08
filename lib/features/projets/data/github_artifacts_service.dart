import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

/// Labels d'affichage pour chaque type d'artefact connu.
const Map<String, String> kArtifactLabels = {
  'readme': '📖 README',
  'presentation': 'Présentation',
  'workthrough': 'Démarche & process',
  'valuation': 'Valorisation',
  'implementation': 'Mise en œuvre',
  'vision': 'Vision',
  'securite': 'Sécurité',
  'offres': 'Offres commerciales',
  'offres_commerciales': 'Offres commerciales',
  'tarifs': 'Tarifs',
  'commercial': 'Offre commerciale',
  'offres-commerciales': 'Offres commerciales',
};

/// Ordre d'affichage préféré.
const List<String> kArtifactOrder = [
  'readme',
  'presentation',
  'offres',
  'offres_commerciales',
  'tarifs',
  'commercial',
  'offres-commerciales',
  'vision',
  'workthrough',
  'implementation',
  'valuation',
  'securite',
];

/// Va chercher les fichiers .md d'artefacts d'un projet sur GitHub.
///
/// Convention : à la racine de chaque repo, un dossier `.artefacts/{id}/`
/// ou `docs/` contient les fichiers (presentation.md, offres.md, tarifs.md, etc.).
class GithubArtifactsService {
  static const _candidateFilenames = [
    'presentation',
    'workthrough',
    'valuation',
    'implementation',
    'vision',
    'readme',
    'securite',
    'offres',
    'offres_commerciales',
    'tarifs',
    'commercial',
    'offres-commerciales',
    'implementation_plan.artifact',
    'analysis_results.artifact',
  ];

  /// Va chercher les fichiers .md d'artefacts d'un projet sur GitHub.
  ///
  /// Supporte les dossiers UUID temporaires, le format .artifact.md, et le dossier docs/
  static Future<Map<String, String>> fetchArtifacts({
    required String repoUrl,
    required String projectId,
    String? token,
    String? alternativeId,
  }) async {
    final repoInfo = _parseRepoUrl(repoUrl);
    if (repoInfo == null) {
      developer.log('⚠️ URL de repo GitHub invalide: $repoUrl',
          name: 'GithubArtifactsService');
      return {};
    }

    // On tente avec les dossiers .artifacts, .artefacts et docs
    final folderNames = ['.artifacts', '.artefacts', 'docs'];
    final ids = [projectId, if (alternativeId != null) alternativeId];

    final artifacts = <String, String>{};

    // 1. D'abord le README (toujours à la racine)
    final readme = await _fetchSingleFile(
      owner: repoInfo.owner,
      repo: repoInfo.repo,
      path: 'README.md',
      token: token,
    );
    if (readme != null) artifacts['readme'] = readme;

    // 2. Recherche itérative des fichiers dans .artifacts, .artefacts et docs
    for (final folder in folderNames) {
      for (final name in _candidateFilenames.where((n) => n != 'readme')) {
        if (artifacts.containsKey(name)) continue;

        for (final ext in ['.artifact.md', '.md']) {
          // Tenter avec l'ID (ex: .artifacts/projet_4/offres.md, docs/projet_4/offres.md)
          for (final id in ids) {
            final content = await _fetchSingleFile(
              owner: repoInfo.owner,
              repo: repoInfo.repo,
              path: '$folder/$id/$name$ext',
              token: token,
            );
            if (content != null) {
              artifacts[name] = content;
              break;
            }
          }
          if (artifacts.containsKey(name)) break;

          // Tenter à la racine du dossier (ex: docs/offres.md, .artifacts/offres.md)
          final rootContent = await _fetchSingleFile(
            owner: repoInfo.owner,
            repo: repoInfo.repo,
            path: '$folder/$name$ext',
            token: token,
          );
          if (rootContent != null) {
            artifacts[name] = rootContent;
            break;
          }
        }
      }
    }

    // Fallback spécial convention .ai/ (uniquement si présentation/vision/workthrough/implementation non trouvés)
    for (final name in [
      'presentation',
      'vision',
      'workthrough',
      'implementation'
    ]) {
      if (artifacts.containsKey(name)) continue;
      String? aiPath;
      switch (name) {
        case 'presentation':
          aiPath = 'PROJECT.md';
          break;
        case 'vision':
          aiPath = 'ARCHITECTURE.md';
          break;
        case 'workthrough':
          aiPath = 'ROADMAP.md';
          break;
        case 'implementation':
          aiPath = 'DECISIONS.md';
          break;
      }
      if (aiPath != null) {
        final aiContent = await _fetchSingleFile(
          owner: repoInfo.owner,
          repo: repoInfo.repo,
          path: '.ai/$aiPath',
          token: token,
        );
        if (aiContent != null) {
          artifacts[name] = aiContent;
        }
      }
    }

    // 3. Fallback ultime : si vraiment vide, on essaye de trouver PROJECT.md à la racine
    if (artifacts.isEmpty ||
        (artifacts.length == 1 && artifacts.containsKey('readme'))) {
      final projectMd = await _fetchSingleFile(
        owner: repoInfo.owner,
        repo: repoInfo.repo,
        path: 'PROJECT.md',
        token: token,
      );
      if (projectMd != null) artifacts['presentation'] = projectMd;
    }

    return artifacts;
  }

  /// Trie les clés trouvées selon [kArtifactOrder], le reste à la suite.
  static List<String> sortedKeys(Map<String, String> artifacts) {
    final ordered = kArtifactOrder.where(artifacts.containsKey).toList();
    final remaining = artifacts.keys.where((k) => !ordered.contains(k));
    return [...ordered, ...remaining];
  }

  static String labelFor(String key) {
    return kArtifactLabels[key] ??
        (key.isEmpty ? key : '${key[0].toUpperCase()}${key.substring(1)}');
  }

  static Future<String?> _fetchSingleFile({
    required String owner,
    required String repo,
    required String path,
    String? token,
  }) async {
    // 1. MÉTHODE PRIORITAIRE : GitHub Raw (Bypasse le rate-limit de l'API REST)
    // On tente 'main' puis 'master'
    for (final branch in ['main', 'master']) {
      final rawUri = Uri.parse(
          'https://raw.githubusercontent.com/$owner/$repo/$branch/$path');

      try {
        final response = await http.get(rawUri);
        if (response.statusCode == 200) {
          return response.body;
        }
        // Si c'est un 404, on continue la boucle (peut-être sur l'autre branche)
      } catch (e) {
        developer.log('⚠️ Erreur Raw fetch ($branch): $e',
            name: 'GithubArtifactsService');
      }
    }

    // 2. MÉTHODE FALLBACK : API REST (Uniquement si Token présent ou petit volume)
    // Si on a un token, l'API REST est fiable et permet des fichiers plus gros
    final apiUri =
        Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path');

    try {
      final response = await http.get(
        apiUri,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 404) return null;

      if (response.statusCode == 403 || response.statusCode == 429) {
        developer.log(
          '❌ GitHub API rate-limit atteint et Raw fallback a échoué.',
          name: 'GithubArtifactsService',
        );
        return null;
      }

      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final content = body['content'] as String?;
      if (content == null) return null;

      final cleaned = content.replaceAll('\n', '');
      return utf8.decode(base64.decode(cleaned));
    } catch (e) {
      developer.log('❌ Erreur API fetch: $e', name: 'GithubArtifactsService');
      return null;
    }
  }

  static ({String owner, String repo})? _parseRepoUrl(String repoUrl) {
    try {
      final uri = Uri.parse(repoUrl);
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.length < 2) return null;
      final repo = segments[1].replaceAll('.git', '');
      return (owner: segments[0], repo: repo);
    } catch (_) {
      return null;
    }
  }
}
