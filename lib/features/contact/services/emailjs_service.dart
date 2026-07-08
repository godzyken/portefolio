import 'dart:developer' as developer;

import 'package:emailjs/emailjs.dart' as EmailJS;

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
    final templateParams = {
      "name": name,
      "email": email,
      "title": "Contact depuis le portfolio",
      "message": message,
      "time": DateTime.now().toString(),
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

      // Sujet du message
      "subject": "Confirmation de Rendez-vous avec votre Portfolio",
    };

    try {
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
