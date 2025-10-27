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

  const EnvConfigService({
    required this.emailJsServiceId,
    required this.emailJsTemplateId,
    required this.emailJsPublicKey,
    required this.whatsappPhone,
    required this.oneDriveUrl,
    this.wakaTimeApiKey,
  });

  /// Factory qui charge depuis String.fromEnvironment
  /// ✅ Compatible avec --dart-define et GitHub Actions
  factory EnvConfigService.fromEnvironment() {
    return EnvConfigService(
      emailJsServiceId: const String.fromEnvironment(
        'EMAILJS_SERVICE_ID',
        defaultValue: '',
      ),
      emailJsTemplateId: const String.fromEnvironment(
        'EMAILJS_TEMPLATE_ID',
        defaultValue: '',
      ),
      emailJsPublicKey: const String.fromEnvironment(
        'EMAILJS_PUBLIC_KEY',
        defaultValue: '',
      ),
      whatsappPhone: const String.fromEnvironment(
        'WHATSAPP_PHONE',
        defaultValue: '',
      ),
      oneDriveUrl: const String.fromEnvironment(
        'CV_ONEDRIVE_URL',
        defaultValue: '',
      ),
      wakaTimeApiKey: const String.fromEnvironment(
        'WAKATIME_API_KEY',
        defaultValue: '',
      ).isNotEmpty
          ? const String.fromEnvironment('WAKATIME_API_KEY')
          : null,
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
  wakaTimeApiKey: ${wakaTimeApiKey != null ? '***' : 'null'},
)''';
}
