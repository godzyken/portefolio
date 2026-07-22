import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

/// Service d'envoi d'emails via l'API REST EmailJS.
///
/// ⚠️ Implémentation en appel HTTP direct plutôt que via le package
/// `emailjs` (^4.0.0) : ce dernier envoie systématiquement un champ
/// `"accessToken": null` dans le corps JSON même quand aucune clé privée
/// n'est configurée, ce que l'API EmailJS rejette avec l'erreur
/// "The parameters are invalid" (le SDK JS officiel, lui, omet
/// entièrement ce champ quand il n'est pas fourni). On reproduit donc
/// ici exactement le payload attendu par
/// https://www.emailjs.com/docs/rest-api/send/
class EmailJsService {
  static const _endpoint = 'https://api.emailjs.com/api/v1.0/email/send';

  final String serviceId;
  final String templateId;
  final String publicKey;

  EmailJsService({
    required this.serviceId,
    required this.templateId,
    required this.publicKey,
  });

  Future<void> _post(Map<String, dynamic> templateParams) async {
    final body = <String, dynamic>{
      'service_id': serviceId,
      'template_id': templateId,
      'user_id': publicKey,
      'template_params': templateParams,
    };

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      developer.log(
          "❌ EmailJS error: ${response.statusCode} ::: ${response.body}");
      throw Exception(
          "Erreur EmailJS (${response.statusCode}): ${response.body}");
    }
  }

  Future<void> sendEmail({
    required String name,
    required String email,
    required String message,
  }) async {
    final templateParams = {
      "name": name,
      "email": email,
      "title": "Contact depuis le portfolio",
      "message": message,
      "time": DateTime.now().toString(),
    };

    try {
      await _post(templateParams);
      developer.log("✅ EmailJS sent successfully");
    } catch (e) {
      developer.log("EmailJS error: $e");
      rethrow;
    }
  }

  Future<void> sendAppointmentConfirmation({
    required Map<String, dynamic> appointmentDetails,
  }) async {
    // Les clés ici doivent ABSOLUMENT correspondre aux variables de votre template EmailJS.
    final templateParams = {
      // Données du contact
      "user_name": appointmentDetails['attendee'],
      "user_email": appointmentDetails['email'],
      "user_message": appointmentDetails['message'],

      // Détails du rendez-vous
      "appointment_date": appointmentDetails['date'],
      "appointment_time": appointmentDetails['time'],
      "appointment_type": appointmentDetails['type'],
      "appointment_location": appointmentDetails['location'],

      // Sujet du message
      "subject": "Confirmation de Rendez-vous avec votre Portfolio",
    };

    try {
      await _post(templateParams);
      developer.log(
          "✅ EmailJS (Confirmation RDV) envoyé avec succès à ${appointmentDetails['email']}");
    } catch (e) {
      developer.log("❌ EmailJS error: $e");
      throw Exception("Erreur EmailJS lors de l'envoi : $e");
    }
  }
}