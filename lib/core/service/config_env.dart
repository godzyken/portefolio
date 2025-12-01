import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/config_env_provider.dart';
import 'config_env_service.dart';

class Env {
  static late EnvConfigService _instance;

  static void init(ProviderContainer container) {
    _instance = container.read(envConfigProvider);
  }

  static String get emailJsServiceId => _instance.emailJsServiceId;
  static String get emailJsTemplateId => _instance.emailJsTemplateId;
  static String get emailJsPublicKey => _instance.emailJsPublicKey;
  static String get whatsappPhone => _instance.whatsappPhone;
  static String get oneDriveUrl => _instance.oneDriveUrl;
  static String? get wakaTimeApiKey => _instance.wakaTimeApiKey;
  static String? get googleCalendarClientId => _instance.googleCalendarClientId;
}
