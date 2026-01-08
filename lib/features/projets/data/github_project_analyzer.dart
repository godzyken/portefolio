import 'dart:convert';

import 'package:http/http.dart' as http;

class GithubProjectTechInfo {
  final List<String> languages;
  final List<String> frameworks;
  final List<String> platforms;
  final String summary;

  const GithubProjectTechInfo({
    required this.languages,
    required this.frameworks,
    required this.platforms,
    required this.summary,
  });
}

class GithubProjectAnalyzer {
  static Future<GithubProjectTechInfo> analyzeRepo(String repoUrl) async {
    try {
      final parts = repoUrl.split('/');
      final user = parts[3];
      final repo = parts[4];

      // === 1️⃣ Langages détectés par GitHub ===
      final langUrl =
          Uri.parse('https://api.github.com/repos/$user/$repo/languages');
      final langResponse = await http.get(langUrl);
      final langs =
          (jsonDecode(langResponse.body) as Map<String, dynamic>).keys.toList();

      // === 2️⃣ Analyse du README ===
      final readmeUrl =
          Uri.parse('https://api.github.com/repos/$user/$repo/readme');
      final readmeResponse = await http.get(readmeUrl);
      String decodedReadme = '';
      if (readmeResponse.statusCode == 200) {
        final body = jsonDecode(readmeResponse.body);
        decodedReadme = utf8.decode(base64.decode(body['content']));
      }

      // === 3️⃣ Déduction frameworks / plateformes ===
      final frameworks = <String>[];
      final platforms = <String>[];

      if (decodedReadme.contains('Flutter')) frameworks.add('Flutter');
      if (decodedReadme.contains('Firebase')) frameworks.add('Firebase');
      if (decodedReadme.contains('Riverpod')) frameworks.add('Riverpod');
      if (decodedReadme.contains('Unity')) frameworks.add('Unity');
      if (decodedReadme.contains('VR')) frameworks.add('VR/AR');
      if (decodedReadme.contains('Hive')) frameworks.add('Hive');

      if (decodedReadme.contains('Android')) platforms.add('Android');
      if (decodedReadme.contains('iOS')) platforms.add('iOS');
      if (decodedReadme.contains('Web')) platforms.add('Web');
      if (decodedReadme.contains('Windows')) platforms.add('Windows');
      if (decodedReadme.contains('Desktop')) platforms.add('Desktop');

      // === 4️⃣ Synthèse basique ===
      final summary = "Projet ${frameworks.join(', ')} "
          "(${langs.join(', ')}) ciblant ${platforms.join(', ')}.";

      return GithubProjectTechInfo(
        languages: langs,
        frameworks: frameworks,
        platforms: platforms,
        summary: summary,
      );
    } catch (e) {
      throw Exception("Erreur d'analyse GitHub : $e");
    }
  }
}
