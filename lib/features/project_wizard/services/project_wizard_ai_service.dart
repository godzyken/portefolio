import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../data/models/project_wizard_models.dart';

class ProjectWizardAiService {
  final String apiKey;

  ProjectWizardAiService(this.apiKey);

  Future<AIStrategicAdvice> getStrategicAdvice(
      ProjectDescription description) async {
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final prompt = _buildPrompt(description);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content":
                "You are a senior digital strategist and software architect. Analyze the project description and provide 3 strategic options in JSON format. The JSON should match the AIStrategicAdvice model structure."
          },
          {"role": "user", "content": prompt},
        ],
        "response_format": {"type": "json_object"},
        "temperature": 0.7,
      }),
    );

    if (response.statusCode != 200) {
      developer.log("OpenAI error: ${response.body}");
      final errorData = jsonDecode(response.body);
      final errorCode = errorData['error']?['code'];

      if (errorCode == 'insufficient_quota') {
        throw Exception(
            "Le quota de l'IA est épuisé. Vous pouvez quand même continuer sans l'analyse.");
      }

      throw Exception(
          "Erreur lors de l'analyse IA. Veuillez réessayer plus tard.");
    }

    final data = jsonDecode(response.body);
    final content = data["choices"]?[0]?["message"]?["content"];

    if (content == null) {
      throw Exception("Réponse IA vide");
    }

    return AIStrategicAdvice.fromJson(jsonDecode(content));
  }

  String _buildPrompt(ProjectDescription description) {
    return '''
Analyse ce projet et propose 3 stratégies différentes (ex: MVP Rapide, Scalabilité Totale, Low-Code/No-Code).

Contexte: ${description.context}
Cible: ${description.targetAudience}
Objectifs: ${description.goals}
Contraintes techniques: ${description.technicalConstraints}
Budget estimé: ${description.budgetRange}

Format attendu (JSON):
{
  "summary": "Résumé de l'analyse...",
  "options": [
    {
      "id": "mvp",
      "title": "MVP Focus",
      "description": "...",
      "pros": ["avantage 1", "..."],
      "cons": ["inconvénient 1", "..."]
    },
    ...
  ],
  "technicalRecommendation": "Recommandation sur la stack technique..."
}
''';
  }
}
