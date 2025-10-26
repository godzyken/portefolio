import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../service/config_env_service.dart';

/// Provider principal du service de configuration
final envConfigProvider = Provider<EnvConfigService>((ref) {
  final config = EnvConfigService.fromEnvironment();

  // Log de validation en debug
  final errors = config.validate();
  if (errors.isNotEmpty) {
    developer.log('⚠️ Configuration incomplète:');
    for (final error in errors) {
      developer.log('  - $error');
    }
  } else {
    developer.log('✅ Configuration chargée avec succès');
  }

  return config;
});

/// Providers spécifiques pour chaque service
/// ✅ Permet l'injection de dépendance fine

// EmailJS
final emailJsServiceIdProvider = Provider<String>((ref) {
  final config = ref.watch(envConfigProvider);
  if (config.emailJsServiceId.isEmpty) {
    throw Exception('EMAILJS_SERVICE_ID non configuré');
  }
  return config.emailJsServiceId;
});

final emailJsTemplateIdProvider = Provider<String>((ref) {
  final config = ref.watch(envConfigProvider);
  if (config.emailJsTemplateId.isEmpty) {
    throw Exception('EMAILJS_TEMPLATE_ID non configuré');
  }
  return config.emailJsTemplateId;
});

final emailJsPublicKeyProvider = Provider<String>((ref) {
  final config = ref.watch(envConfigProvider);
  if (config.emailJsPublicKey.isEmpty) {
    throw Exception('EMAILJS_PUBLIC_KEY non configuré');
  }
  return config.emailJsPublicKey;
});

// WhatsApp
final whatsappPhoneProvider = Provider<String>((ref) {
  final config = ref.watch(envConfigProvider);
  if (config.whatsappPhone.isEmpty) {
    throw Exception('WHATSAPP_PHONE non configuré');
  }
  return config.whatsappPhone;
});

// OneDrive
final cvOneDriveUrlProvider = Provider<String>((ref) {
  final config = ref.watch(envConfigProvider);
  if (config.oneDriveUrl.isEmpty) {
    throw Exception('CV_ONEDRIVE_URL non configuré');
  }
  return config.oneDriveUrl;
});

// WakaTime (optionnel)
final wakaTimeApiKeyConfigProvider = Provider<String?>((ref) {
  final config = ref.watch(envConfigProvider);
  return config.wakaTimeApiKey;
});

/// Provider de validation globale
final envConfigValidationProvider = Provider<EnvConfigValidation>((ref) {
  final config = ref.watch(envConfigProvider);
  final errors = config.validate();

  return EnvConfigValidation(
    isValid: errors.isEmpty,
    errors: errors,
    warnings: _generateWarnings(config),
  );
});

List<String> _generateWarnings(EnvConfigService config) {
  final warnings = <String>[];

  if (config.wakaTimeApiKey == null) {
    warnings.add('WakaTime non configuré (optionnel)');
  }

  // Validation format URL OneDrive
  if (config.oneDriveUrl.isNotEmpty && !config.oneDriveUrl.startsWith('http')) {
    warnings.add('CV_ONEDRIVE_URL ne semble pas être une URL valide');
  }

  // Validation format téléphone
  if (config.whatsappPhone.isNotEmpty &&
      !RegExp(r'^[1-9]\d{6,14}$').hasMatch(config.whatsappPhone)) {
    warnings
        .add('WHATSAPP_PHONE format invalide (doit être international sans +)');
  }

  return warnings;
}

class EnvConfigValidation {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const EnvConfigValidation({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  bool get hasWarnings => warnings.isNotEmpty;
}
