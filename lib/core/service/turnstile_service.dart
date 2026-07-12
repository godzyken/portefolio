import 'dart:developer' as developer;

import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';

import 'config_env.dart';

/// Récupère un token Cloudflare Turnstile en mode invisible, à passer à
/// `Supabase.auth.signInWithPassword(captchaToken: ...)`.
///
/// Nécessite que le domaine courant (localhost en dev, ton domaine en prod)
/// soit ajouté à la liste des domaines autorisés du widget Turnstile,
/// dans le dashboard Cloudflare.
class TurnstileService {
  TurnstileService._();

  static bool get isConfigured => Env.turnstileSiteKey.isNotEmpty;

  static Future<String?> getToken() async {
    if (!isConfigured) {
      developer.log(
        '⚠️ TURNSTILE_SITE_KEY manquant : impossible de générer un token captcha.',
        name: 'TurnstileService',
      );
      return null;
    }

    final turnstile = CloudflareTurnstile.invisible(
      siteKey: Env.turnstileSiteKey,
      baseUrl: Uri.base.origin,
    );

    try {
      final token = await turnstile.getToken();
      return token;
    } on TurnstileException catch (e) {
      developer.log('❌ Échec captcha Turnstile: ${e.message}',
          name: 'TurnstileService');
      return null;
    } finally {
      turnstile.dispose();
    }
  }
}
