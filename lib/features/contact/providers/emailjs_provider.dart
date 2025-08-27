import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/emailjs_service.dart';

final emailJsProvider = Provider<EmailJsService>((ref) {
  final serviceId = dotenv.env['EMAILJS_SERVICE_ID'] ?? '';
  final templateId = dotenv.env['EMAILJS_TEMPLATE_ID'] ?? '';
  final publicKey = dotenv.env['EMAILJS_PUBLIC_KEY'] ?? '';

  if ([serviceId, templateId, publicKey].any((v) => v.isEmpty)) {
    throw Exception('Variables EmailJS manquantes dans .env');
  }
  return EmailJsService(
    serviceId: serviceId,
    templateId: templateId,
    publicKey: publicKey,
  );
});
