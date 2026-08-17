import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:portefolio/core/affichage/tech_maturity_framework.dart';
import '../data/avatar_message.dart';

class AvatarChatService {
  static const _openAiKey = String.fromEnvironment('OPENAI_API_KEY');

  Future<String> getResponse({
    required String systemContext,
    required List<AvatarMessage> history,
    required Map<TechPillar, int> engagementScores,
  }) async {
    if (_openAiKey.isEmpty) {
      return "Désolé, ma connexion au réseau neuronal est interrompue (clé API manquante).";
    }

    final depthInstructions = _buildDepthInstructions(engagementScores);
    final finalSystemPrompt = "$systemContext\n\n$depthInstructions";

    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final messages = [
      {"role": "system", "content": finalSystemPrompt},
      ...history.map((m) => {
            "role": m.role == MessageRole.user ? "user" : "assistant",
            "content": m.content,
          }),
    ];

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiKey',
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": messages,
          "temperature": 0.7,
          "max_tokens": 1000,
        }),
      );

      if (response.statusCode != 200) {
        developer.log("OpenAI error: ${response.body}", name: 'AvatarChatService');
        return "Une erreur technique s'est produite lors de la génération de ma réponse.";
      }

      final data = jsonDecode(response.body);
      final text = data["choices"]?[0]?["message"]?["content"] ?? "";
      return text.trim();
    } catch (e) {
      developer.log("Exception during chat: $e", name: 'AvatarChatService');
      return "Je rencontre des difficultés de transmission. Peux-tu reformuler ?";
    }
  }

  String _buildDepthInstructions(Map<TechPillar, int> scores) {
    final buffer = StringBuffer();
    buffer.writeln("### DIRECTIVES DE PROFONDEUR TECHNIQUE :");
    
    scores.forEach((pillar, count) {
      if (count < 2) {
        buffer.writeln("- Pour le pilier ${pillar.label} : Reste vulgarisé, donne une vue d'ensemble.");
      } else if (count >= 2 && count < 5) {
        buffer.writeln("- Pour le pilier ${pillar.label} : Entre dans les détails d'implémentation, cite des packages ou des patterns précis.");
      } else {
        buffer.writeln("- Pour le pilier ${pillar.label} : Niveau EXPERT. Donne des extraits de code, explique l'architecture en profondeur et suggère explicitement à l'utilisateur de consulter l'artefact .md correspondant (ex: implementation.md) pour voir les preuves techniques.");
      }
    });

    return buffer.toString();
  }
}
