import 'dart:developer' as developer;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/service/native_config.dart';

Future<String> initializeService() async {
  return await NativeConfig.getSendGridKey();
}

class WhatsAppService {
  final String phone;

  WhatsAppService(this.phone)
    : assert(
        RegExp(r'^[1-9]\d{6,14}$').hasMatch(phone),
        'Numéro international invalide',
      );

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

final whatsappServiceProvider = Provider<WhatsAppService>((ref) {
  final phone = dotenv.env['WHATSAPP_PHONE'];
  if (phone == null || !RegExp(r'^[1-9]\d{6,14}$').hasMatch(phone)) {
    developer.log("⚠️ Numéro WhatsApp invalide ou manquant dans .env");
    return WhatsAppService("33600000000"); // fallback neutre
  }
  return WhatsAppService(phone);
});
