import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/emailjs_service.dart';

final emailJsProvider = Provider<EmailJsService>((ref) {
  const serviceId = String.fromEnvironment('EMAILJS_SERVICE_ID');
  const templateId = String.fromEnvironment('EMAILJS_TEMPLATE_ID');
  const publicKey = String.fromEnvironment('EMAILJS_PUBLIC_KEY');

  if ([serviceId, templateId, publicKey].any((v) => v.isEmpty)) {
    throw Exception('Variables EmailJS manquantes dans .env');
  }
  developer.log("EmailJS config:");
  developer.log("serviceId: $serviceId");
  developer.log("templateId: $templateId");
  developer.log("publicKey: $publicKey");

  return EmailJsService(
    serviceId: serviceId,
    templateId: templateId,
    publicKey: publicKey,
  );
});
