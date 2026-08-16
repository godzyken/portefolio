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
};

/// Ordre d'affichage préféré.
const List<String> kArtifactOrder = [
  'readme',
  'presentation',
  'vision',
  'workthrough',
  'implementation',
  'valuation',
  'securite',
];

/// Va chercher les fichiers .md d'artefacts d'un projet sur GitHub.
///
/// Convention : à la racine de chaque repo, un dossier `.artefacts/{id}/`
/// contient les fichiers (presentation.md, workthrough.md, valuation.md,
/// implementation.md, vision.md). Certains projets (ex: emap_services)
/// dérogent à la convention et utilisent readme.md/presentation.md/
/// securite.md — ces noms sont donc aussi tentés systématiquement.
class GithubArtifactsService {
  static const _candidateFilenames = [
    'presentation',
    'workthrough',
    'valuation',
    'implementation',
    'vision',
    'readme',
    'securite',
  ];

  /// [repoUrl] doit être de la forme https://github.com/{owner}/{repo}
  /// [projectId] est l'id utilisé pour le sous-dossier .artefacts/{projectId}/
  /// [token] optionnel : un token GitHub (PAT, scope public_repo suffit)
  /// fait passer la limite de 60 req/h (non-auth) à 5000 req/h.
  static Future<Map<String, String>> fetchArtifacts({
    required String repoUrl,
    required String projectId,
    String? token,
  }) async {
    final repoInfo = _parseRepoUrl(repoUrl);
    if (repoInfo == null) {
      developer.log('⚠️ URL de repo GitHub invalide: $repoUrl',
          name: 'GithubArtifactsService');
      return {};
    }

    final results = await Future.wait([
      // 1. Chercher le README à la racine
      _fetchSingleFile(
        owner: repoInfo.owner,
        repo: repoInfo.repo,
        path: 'README.md',
        token: token,
      ).then((content) => MapEntry('readme', content)),

      // 2. Chercher les autres artefacts dans .artefacts/{projectId}/
      ..._candidateFilenames
          .where((name) => name != 'readme')
          .map(
            (name) => _fetchSingleFile(
              owner: repoInfo.owner,
              repo: repoInfo.repo,
              path: '.artefacts/$projectId/$name.md',
              token: token,
            ).then((content) => MapEntry(name, content)),
          ),
    ]);

    final artifacts = <String, String>{
      for (final entry in results)
        if (entry.value != null) entry.key: entry.value!,
    };

    developer.log(
      artifacts.isEmpty
          ? 'ℹ️ Aucun artefact trouvé pour $projectId dans ${repoInfo.owner}/${repoInfo.repo}'
          : '✅ ${artifacts.length} artefact(s) trouvé(s) pour $projectId: ${artifacts.keys.join(", ")}',
      name: 'GithubArtifactsService',
    );

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
    final uri =
        Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 404) return null; // fichier absent, normal

      if (response.statusCode == 403 || response.statusCode == 429) {
        developer.log(
          '⚠️ GitHub API rate-limit atteint pour $path'
          '${token == null ? ' (pense à définir GITHUB_TOKEN)' : ''}',
          name: 'GithubArtifactsService',
        );
        return null;
      }

      if (response.statusCode != 200) {
        developer.log(
          '⚠️ GitHub API ${response.statusCode} pour $path',
          name: 'GithubArtifactsService',
        );
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final content = body['content'] as String?;
      if (content == null) return null;

      // Le contenu base64 renvoyé par GitHub est découpé en lignes de 60
      // caractères séparées par \n : on les retire avant de décoder.
      final cleaned = content.replaceAll('\n', '');
      return utf8.decode(base64.decode(cleaned));
    } catch (e) {
      developer.log(
        '❌ Erreur fetch $path: $e',
        name: 'GithubArtifactsService',
      );
      return null;
    }
  }

  static ({String owner, String repo})? _parseRepoUrl(String repoUrl) {
    try {
      final uri = Uri.parse(repoUrl);
      final segments =
          uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.length < 2) return null;
      final repo = segments[1].replaceAll('.git', '');
      return (owner: segments[0], repo: repo);
    } catch (_) {
      return null;
    }
  }
}
