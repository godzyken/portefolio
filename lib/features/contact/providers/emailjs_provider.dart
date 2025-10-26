import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/provider/config_env_provider.dart';
import '../services/emailjs_service.dart';

final emailJsProvider = Provider<EmailJsService>((ref) {
  final serviceId = ref.watch(emailJsServiceIdProvider);
  final templateId = ref.watch(emailJsTemplateIdProvider);
  final publicKey = ref.watch(emailJsPublicKeyProvider);

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
