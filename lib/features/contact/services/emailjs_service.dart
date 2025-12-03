import 'dart:convert';
import 'dart:developer' as developer;

import 'package:emailjs/emailjs.dart' as EmailJS;
import 'package:http/http.dart' as http;

class EmailJsService {
  final String serviceId;
  final String templateId;
  final String publicKey;

  EmailJsService({
    required this.serviceId,
    required this.templateId,
    required this.publicKey,
  });

  Future<void> sendEmail({
    required String name,
    required String email,
    required String message,
  }) async {
    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");

    final response = await http.post(
      url,
      headers: {
        "origin": "http://localhost", // ou ton domaine Flutter web
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "service_id": serviceId,
        "template_id": templateId,
        "user_id": publicKey,
        "template_params": {
          "from_name": name,
          "reply_to": email,
          "message": message,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("EmailJS error: ${response.body}");
    }

    final templateParams = {
      "from_name": name,
      "reply_to": email,
      "message": message,
    };

    try {
      await EmailJS.send(
        serviceId,
        templateId,
        templateParams,
        EmailJS.Options(
          publicKey: publicKey,
          limitRate: const EmailJS.LimitRate(id: 'portefolio', throttle: 250),
        ),
      );
      developer.log("✅ EmailJS sent successfully");
    } catch (e) {
      if (e is EmailJS.EmailJSResponseStatus) {
        developer.log("EmailJS error: ${e.status} ::: ${e.text}");
        throw Exception("Erreur EmailJS: ${e.text}");
      } else {
        developer.log("EmailJS error: $e");
        throw Exception("Erreur lors de l'envoi de l'email: $e");
      }
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

      // Vous pouvez ajouter une variable pour l'objet du mail
      "subject": "Confirmation de Rendez-vous avec votre Portfolio",
    };

    try {
      // Utilisation de la méthode EmailJS.send standard
      // Assurez-vous que cette méthode est disponible dans votre package EmailJS
      await EmailJS.send(
        serviceId,
        templateId,
        templateParams,
        EmailJS.Options(
          publicKey: publicKey,
          // Le limitRate est une bonne pratique
          limitRate:
              const EmailJS.LimitRate(id: 'portfolio_rdv', throttle: 250),
        ),
      );
      developer.log(
          "✅ EmailJS (Confirmation RDV) envoyé avec succès à ${appointmentDetails['email']}");
    } catch (e) {
      if (e is EmailJS.EmailJSResponseStatus) {
        developer.log("❌ EmailJS error: ${e.status} ::: ${e.text}");
        throw Exception("Erreur EmailJS lors de l'envoi : ${e.text}");
      } else {
        developer.log("❌ EmailJS error: $e");
        throw Exception("Erreur lors de l'envoi de l'email : $e");
      }
    }
  }
}
