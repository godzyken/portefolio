import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class EmailService {
  EmailService({required this.endpoint});
  final String endpoint;

  Future<void> send(String name, String email, String msg) async {
    final apiKey = dotenv.env['API_KEY'];
    final destMail = dotenv.env['DEST_MAIL'];
    final srcMail = dotenv.env['SRC_MAIL'];

    if ([apiKey, destMail, srcMail].any((v) => v == null || v.isEmpty)) {
      throw Exception(
        'Variables .env manquantes (API_KEY, SRC_MAIL, DEST_MAIL)',
      );
    }

    final res = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "personalizations": [
          {
            "to": [
              {"email": destMail},
            ],
            "subject": "Nouveau message de $name",
          },
        ],
        "from": {"email": srcMail},
        "reply_to": {"email": email, "name": name},
        "content": [
          {"type": "text/plain", "value": msg},
        ],
      }),
    );

    if (res.statusCode >= 300) {
      throw Exception('SendGrid error ${res.statusCode}: ${res.body}');
    }
  }
}

class WhatsAppService {
  final String phone;
  const WhatsAppService(this.phone);

  Future<void> send(String name, String email, String msg) async {
    final url = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent('''Bonjour, je suis $name
          Email : $email
          $msg''')}',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Impossible d’ouvrir WhatsApp');
    }
  }
}

final emailServiceProvider = Provider<EmailService>((ref) {
  const endpoint = 'https://api.sendgrid.com/v3/mail/send';
  return EmailService(endpoint: endpoint);
});

final whatsappServiceProvider = Provider<WhatsAppService>((ref) {
  final phone = dotenv.env['WHATSAPP_PHONE'] ?? '0000000000';
  return WhatsAppService(phone);
});
