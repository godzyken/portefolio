import 'dart:convert';

import 'package:portefolio/features/home/data/services_data.dart'; // Pour 'compute'

class EnvConfigService {
  // EmailJS
  final String emailJsServiceId;
  final String emailJsTemplateId;
  final String emailJsPublicKey;

  // WhatsApp
  final String whatsappPhone;

  // OneDrive
  final String oneDriveUrl;

  // WakaTime (optionnel)
  final String? wakaTimeApiKey;

  // Google Calendar
  final String? googleCalendarClientId;

  // OpenAI
  final String? openaiApiKey;

  // Supabase (tarifs & formulaire admin)
  final String supabaseUrl;
  final String supabaseAnonKey;

  // Captcha Turnstile
  final String turnstileSiteKey;

  const EnvConfigService._({
    required this.emailJsServiceId,
    required this.emailJsTemplateId,
    required this.emailJsPublicKey,
    required this.whatsappPhone,
    required this.oneDriveUrl,
    required this.wakaTimeApiKey,
    required this.googleCalendarClientId,
    required this.openaiApiKey,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.turnstileSiteKey,
  });

  /// Factory qui charge depuis String.fromEnvironment
  /// ✅ Compatible avec --dart-define et GitHub Actions
  factory EnvConfigService.fromEnvironment() {
    const emailJsServiceId = String.fromEnvironment('EMAILJS_SERVICE_ID');

    const emailJsTemplateId = String.fromEnvironment('EMAILJS_TEMPLATE_ID');

    final emailJsPublicKey = const String.fromEnvironment('EMAILJS_PUBLIC_KEY');

    final whatsappPhone = const String.fromEnvironment('WHATSAPP_PHONE');

    final oneDriveUrl = const String.fromEnvironment('CV_ONEDRIVE_URL');

    final waka = const String.fromEnvironment('WAKATIME_API_KEY');

    final gcc = const String.fromEnvironment('GCC_CLIENT_ID');

    final openai = const String.fromEnvironment('OPENAI_API_KEY');

    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    const turnstileSiteKey = String.fromEnvironment('TURNSTILE_SITE_KEY');

    return EnvConfigService._(
      emailJsServiceId: emailJsServiceId,
      emailJsTemplateId: emailJsTemplateId,
      emailJsPublicKey: emailJsPublicKey,
      whatsappPhone: whatsappPhone,
      oneDriveUrl: oneDriveUrl,
      wakaTimeApiKey: waka.isEmpty ? null : waka,
      googleCalendarClientId: gcc.isEmpty ? null : gcc,
      openaiApiKey: openai.isEmpty ? null : openai,
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
      turnstileSiteKey: turnstileSiteKey,
    );
  }

  /// Validation des configs critiques
  List<String> validate() {
    final errors = <String>[];

    if (emailJsServiceId.isEmpty) {
      errors.add('EMAILJS_SERVICE_ID manquant');
    }
    if (emailJsTemplateId.isEmpty) {
      errors.add('EMAILJS_TEMPLATE_ID manquant');
    }
    if (emailJsPublicKey.isEmpty) {
      errors.add('EMAILJS_PUBLIC_KEY manquant');
    }
    if (whatsappPhone.isEmpty) {
      errors.add('WHATSAPP_PHONE manquant');
    }
    if (oneDriveUrl.isEmpty) {
      errors.add('CV_ONEDRIVE_URL manquant');
    }
    if ((wakaTimeApiKey ?? '').isEmpty) {
      errors.add('WAKATIME_API_KEY manquant');
    }

    if ((googleCalendarClientId ?? '').isEmpty) {
      errors.add('GCC_CLIENT_ID manquant');
    }

    if ((openaiApiKey ?? '').isEmpty) {
      errors.add('OPENAI_API_KEY manquant');
    }

    if (supabaseUrl.isEmpty) {
      errors.add('SUPABASE_URL manquant');
    }
    if (supabaseAnonKey.isEmpty) {
      errors.add('SUPABASE_ANON_KEY manquant');
    }
    if (turnstileSiteKey.isEmpty) {
      errors.add('TURNSTILE_SITE_KEY manquant');
    }

    return errors;
  }

  bool get isValid => validate().isEmpty;

  @override
  String toString() => '''
EnvConfigService(
  emailJsServiceId: ${emailJsServiceId.isNotEmpty ? '***' : 'MISSING'},
  emailJsTemplateId: ${emailJsTemplateId.isNotEmpty ? '***' : 'MISSING'},
  emailJsPublicKey: ${emailJsPublicKey.isNotEmpty ? '***' : 'MISSING'},
  whatsappPhone: ${whatsappPhone.isNotEmpty ? '***' : 'MISSING'},
  oneDriveUrl: ${oneDriveUrl.isNotEmpty ? '${oneDriveUrl.substring(0, 30)}...' : 'MISSING'},
  wakaTimeApiKey: ${wakaTimeApiKey != null ? '***' : 'MISSING'},
  googleCalendarClientId: ${googleCalendarClientId != null ? '***' : 'MISSING'},
  supabaseUrl: ${supabaseUrl.isNotEmpty ? '***' : 'MISSING'},
  supabaseAnonKey: ${supabaseAnonKey.isNotEmpty ? '***' : 'MISSING'},
  turnstileSiteKey: ${turnstileSiteKey.isNotEmpty ? '***' : 'MISSING'},
)''';
}

List<Service> parseServices(String responseBody) {
  final decoded = jsonDecode(responseBody);

  if (decoded is! List) {
    throw Exception('Format JSON invalide: attendu une liste');
  }

  return decoded
      .map<Service>((e) => Service.fromJson(e as Map<String, dynamic>))
      .toList();
}
