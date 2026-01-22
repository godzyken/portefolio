import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import 'github_project_analyzer.dart';

/// Résultat enrichi avec résumé IA
class GithubProjectAIInfo extends GithubProjectTechInfo {
  final String aiSummary;

  GithubProjectAIInfo({
    required super.languages,
    required super.frameworks,
    required super.platforms,
    required super.summary,
    required this.aiSummary,
  });
}

class GithubProjectAIAnalyzer {
  // 🔑 Met ta clé OpenAI ici ou dans ton système de config
  static const _openAiKey = String.fromEnvironment('OPENAI_API_KEY');

  /// Analyse GitHub + résumé IA
  static Future<GithubProjectAIInfo> analyzeRepoWithAI(String repoUrl) async {
    // On commence par l’analyse classique
    final techInfo = await GithubProjectAnalyzer.analyzeRepo(repoUrl);

    // LIRE README
    final readme = await _fetchReadme(repoUrl);

    // Construire le prompt IA
    final prompt = _buildPrompt(techInfo, readme);

    // Appel à OpenAI
    final aiSummary = await _callOpenAI(prompt);

    return GithubProjectAIInfo(
      languages: techInfo.languages,
      frameworks: techInfo.frameworks,
      platforms: techInfo.platforms,
      summary: techInfo.summary,
      aiSummary: aiSummary,
    );
  }

  static String _buildPrompt(GithubProjectTechInfo info, String readme) {
    return '''
Lire le README ci-dessous et générer une synthèse technique claire du projet.
Liste les langues, frameworks, plateformes cibles, et les objectifs principaux.

README :
$readme
''';
  }

  static Future<String> _fetchReadme(String repoUrl) async {
    final parts = repoUrl.split('/');
    final user = parts[3];
    final repo = parts[4];
    final readmeUrl =
        Uri.parse('https://api.github.com/repos/$user/$repo/readme');

    final readmeResponse = await http.get(readmeUrl);
    if (readmeResponse.statusCode != 200) return '';

    final body = jsonDecode(readmeResponse.body);
    return utf8.decode(base64.decode(body['content'] ?? ''));
  }

  static Future<String> _callOpenAI(String prompt) async {
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_openAiKey',
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content": "You are a helpful technical summarizer."
          },
          {"role": "user", "content": prompt},
        ],
        "temperature": 0.7,
        "max_tokens": 400,
      }),
    );

    if (response.statusCode != 200) {
      developer.log("OpenAI error: ${response.body}");
      return "Résumé IA non disponible.";
    }

    final data = jsonDecode(response.body);
    final text = data["choices"]?[0]?["message"]?["content"] ?? "";
    return text.trim();
  }
}
