import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../data/avatar_message.dart';

class AvatarChatService {
  static const _openAiKey = String.fromEnvironment('OPENAI_API_KEY');

  Future<String> getResponse({
    required String systemContext,
    required List<AvatarMessage> history,
  }) async {
    if (_openAiKey.isEmpty) {
      return "Désolé, ma connexion au réseau neuronal est interrompue (clé API manquante).";
    }

    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final messages = [
      {"role": "system", "content": systemContext},
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
}
