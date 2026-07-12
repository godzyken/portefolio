import 'config_env.dart';

/// Petit wrapper autour de la clé Turnstile (captcha du login admin).
///
/// Le token n'est plus généré ici : le widget `CloudflareTurnstile` (mode
/// managed) reste monté dans `AdminLoginScreen` et fournit le token via son
/// callback `onTokenReceived`. Créer/détruire une instance invisible à
/// chaque tentative de connexion causait des courses ("Cannot find Widget")
/// et des échecs "300*" (comportement jugé suspect par Cloudflare).
class TurnstileService {
  TurnstileService._();

  static bool get isConfigured => Env.turnstileSiteKey.isNotEmpty;

  static String? get siteKey => Env.turnstileSiteKey;
}
